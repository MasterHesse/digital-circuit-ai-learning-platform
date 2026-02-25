package dev.masterhesse.diglearn.classroom;

import dev.masterhesse.diglearn.auth.UserPrincipal;
import dev.masterhesse.diglearn.classroom.persistence.ClassMembershipEntity;
import dev.masterhesse.diglearn.classroom.persistence.ClassMembershipRepository;
import dev.masterhesse.diglearn.classroom.persistence.ClassMembershipStatus;
import dev.masterhesse.diglearn.classroom.persistence.ClassroomEntity;
import dev.masterhesse.diglearn.classroom.persistence.ClassroomRepository;
import dev.masterhesse.diglearn.practice.persistence.UserQuestionStateRepository;
import dev.masterhesse.diglearn.user.persistence.AppUserEntity;
import dev.masterhesse.diglearn.user.persistence.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClassroomService {

    private final ClassroomRepository classRepo;
    private final ClassMembershipRepository membershipRepo;
    private final AppUserRepository userRepo;
    private final UserQuestionStateRepository uqsRepo;

    // =========================
    // TEACHER: 创建/列表
    // =========================

    @Transactional
    public ClassApiModels.ClassResponse createClass(String teacherId, ClassApiModels.CreateClassRequest req) {
        String name = (req.name() == null) ? "" : req.name().trim();
        if (name.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "class name is required");
        }

        ClassroomEntity c = new ClassroomEntity();
        c.setTeacherId(teacherId);
        c.setName(name);
        c = classRepo.save(c);

        return toClassResponse(c);
    }

    @Transactional(readOnly = true)
    public List<ClassApiModels.ClassResponse> listTeachingClasses(String teacherId) {
        return classRepo.findByTeacherIdOrderByCreatedAtDesc(teacherId).stream()
                .map(this::toClassResponse)
                .toList();
    }

    // =========================
    // NEW: 班级详情（通用）
    // =========================

    @Transactional(readOnly = true)
    public ClassApiModels.ClassDetailResponse getClassDetail(String viewerUserId, UUID classId) {
        ClassroomEntity c = classRepo.findById(classId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "class not found: " + classId));

        AppUserEntity teacher = userRepo.findById(c.getTeacherId()).orElse(null);

        ClassApiModels.MembershipSummary my = membershipRepo.findByClassIdAndStudentId(c.getId(), viewerUserId)
                .map(this::toMembershipSummary)
                .orElse(null);

        return new ClassApiModels.ClassDetailResponse(
                toClassResponse(c),
                toUserProfile(teacher, c.getTeacherId()),
                my
        );
    }

    // =========================
    // NEW: STUDENT 我的班级列表（含 PENDING/APPROVED/REJECTED）
    // =========================

    @Transactional(readOnly = true)
    public List<ClassApiModels.MyClassResponse> listJoinedClasses(String studentId) {
        List<ClassMembershipEntity> ms = membershipRepo.findByStudentIdOrderByRequestedAtDesc(studentId);
        if (ms.isEmpty()) return List.of();

        // 批量查班级
        List<UUID> classIds = ms.stream().map(ClassMembershipEntity::getClassId).distinct().toList();
        Map<UUID, ClassroomEntity> classById = classRepo.findAllById(classIds).stream()
                .collect(Collectors.toMap(ClassroomEntity::getId, Function.identity()));

        // 批量查 teacher profiles
        List<String> teacherIds = classById.values().stream().map(ClassroomEntity::getTeacherId).distinct().toList();
        Map<String, AppUserEntity> teacherById = userRepo.findAllById(teacherIds).stream()
                .collect(Collectors.toMap(AppUserEntity::getUserId, Function.identity()));

        List<ClassApiModels.MyClassResponse> out = new ArrayList<>();
        for (ClassMembershipEntity m : ms) {
            ClassroomEntity c = classById.get(m.getClassId());
            if (c == null) continue; // 班级被删了就跳过，避免整页 500

            AppUserEntity t = teacherById.get(c.getTeacherId());

            out.add(new ClassApiModels.MyClassResponse(
                    c.getId(),
                    c.getName(),
                    c.getTeacherId(),
                    c.getCreatedAt(),
                    toUserProfile(t, c.getTeacherId()),
                    toMembershipSummary(m)
            ));
        }
        return out;
    }

    // =========================
    // NEW: STUDENT 退出/取消申请（删除 membership，幂等）
    // =========================

    @Transactional
    public void leaveOrCancel(String studentId, UUID classId) {
        // 幂等：删不到也当成功
        membershipRepo.deleteByClassIdAndStudentId(classId, studentId);
    }

    // =========================
    // NEW: TEACHER 修改班级信息（目前只改 name）
    // =========================

    @Transactional
    public ClassApiModels.ClassResponse updateClass(UserPrincipal p, UUID classId, ClassApiModels.UpdateClassRequest req) {
        // 目前按“必须是班级 owner”处理（与你现有 requireOwnedClass 一致）
        return updateClass(p.userId(), classId, req);
    }

    @Transactional
    public ClassApiModels.ClassResponse updateClass(String teacherId, UUID classId, ClassApiModels.UpdateClassRequest req) {
        ClassroomEntity c = requireOwnedClass(classId, teacherId);

        String name = (req.name() == null) ? "" : req.name().trim();
        if (name.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "class name is required");
        }

        c.setName(name);
        c = classRepo.save(c);

        return toClassResponse(c);
    }

    // =========================
    // NEW: TEACHER 删除班级（连同 membership 一起删）
    // =========================

    @Transactional
    public void deleteClass(UserPrincipal p, UUID classId) {
        deleteClass(p.userId(), classId);
    }

    @Transactional
    public void deleteClass(String teacherId, UUID classId) {
        ClassroomEntity c = requireOwnedClass(classId, teacherId);

        // 先删 membership，避免外键约束（若你有 FK）
        membershipRepo.deleteByClassId(c.getId());
        classRepo.delete(c);
    }

    // =========================
    // STUDENT: 申请加入（你原有，已支持 REJECTED -> PENDING）
    // =========================

    @Transactional
    public ClassApiModels.MembershipResponse applyToClass(String studentId, UUID classId) {
        ClassroomEntity c = classRepo.findById(classId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "class not found: " + classId));

        // 幂等：重复申请返回现有；被拒绝允许重新申请（回到 PENDING）
        Optional<ClassMembershipEntity> existingOpt = membershipRepo.findByClassIdAndStudentId(c.getId(), studentId);
        if (existingOpt.isPresent()) {
            ClassMembershipEntity m = existingOpt.get();
            if (m.getStatus() == ClassMembershipStatus.REJECTED) {
                m.setStatus(ClassMembershipStatus.PENDING);
                m.setRequestedAt(Instant.now());
                m.setDecidedAt(null);
                m.setDecidedBy(null);
                m = membershipRepo.save(m);
            }
            return toMembershipResponse(m);
        }

        ClassMembershipEntity m = new ClassMembershipEntity();
        m.setClassId(c.getId());
        m.setStudentId(studentId);
        m.setStatus(ClassMembershipStatus.PENDING);

        try {
            m = membershipRepo.save(m);
        } catch (DataIntegrityViolationException ex) {
            // 并发兜底：唯一约束(class_id, student_id)
            ClassMembershipEntity again = membershipRepo.findByClassIdAndStudentId(c.getId(), studentId)
                    .orElseThrow(() -> ex);
            return toMembershipResponse(again);
        }

        return toMembershipResponse(m);
    }

    // =========================
    // TEACHER: 待审核列表/审批/驳回（你原有）
    // =========================

    @Transactional(readOnly = true)
    public List<ClassApiModels.JoinRequestResponse> listPendingJoinRequests(String teacherId, UUID classId) {
        ClassroomEntity c = requireOwnedClass(classId, teacherId);

        List<ClassMembershipEntity> pending = membershipRepo
                .findByClassIdAndStatusOrderByRequestedAtAsc(c.getId(), ClassMembershipStatus.PENDING);

        if (pending.isEmpty()) return List.of();

        List<String> studentIds = pending.stream().map(ClassMembershipEntity::getStudentId).distinct().toList();
        Map<String, AppUserEntity> userById = userRepo.findAllById(studentIds).stream()
                .collect(Collectors.toMap(AppUserEntity::getUserId, Function.identity()));

        return pending.stream()
                .map(m -> new ClassApiModels.JoinRequestResponse(
                        m.getId(),
                        m.getClassId(),
                        m.getRequestedAt(),
                        toUserProfile(userById.get(m.getStudentId()), m.getStudentId())
                ))
                .toList();
    }

    @Transactional
    public void approveJoinRequest(String teacherId, UUID classId, UUID membershipId) {
        decideJoinRequest(teacherId, classId, membershipId, true);
    }

    @Transactional
    public void rejectJoinRequest(String teacherId, UUID classId, UUID membershipId) {
        decideJoinRequest(teacherId, classId, membershipId, false);
    }

    // =========================
    // TEACHER: 学生进度/推荐（你原有）
    // =========================

    @Transactional(readOnly = true)
    public List<ClassApiModels.StudentProgressResponse> listStudentsWithProgress(String teacherId, UUID classId) {
        ClassroomEntity c = requireOwnedClass(classId, teacherId);

        List<ClassMembershipEntity> approved =
                membershipRepo.findByClassIdAndStatus(c.getId(), ClassMembershipStatus.APPROVED);

        if (approved.isEmpty()) return List.of();

        List<String> studentIds = approved.stream().map(ClassMembershipEntity::getStudentId).distinct().toList();

        Map<String, AppUserEntity> userById = userRepo.findAllById(studentIds).stream()
                .collect(Collectors.toMap(AppUserEntity::getUserId, Function.identity()));

        Map<String, UserQuestionStateRepository.ProgressRow> progressByUserId = new HashMap<>();
        if (!studentIds.isEmpty()) {
            for (var row : uqsRepo.findProgressByUserIds(studentIds)) {
                progressByUserId.put(row.getUserId(), row);
            }
        }

        List<ClassApiModels.StudentProgressResponse> result = new ArrayList<>();
        for (ClassMembershipEntity m : approved) {
            String sid = m.getStudentId();
            AppUserEntity u = userById.get(sid);
            var row = progressByUserId.get(sid);

            ClassApiModels.ProgressResponse progress = new ClassApiModels.ProgressResponse(
                    (row == null) ? 0 : row.getAttemptedCount(),
                    (row == null) ? 0 : row.getMasteredCount(),
                    (row == null) ? 0 : row.getUnmasteredWrongCount(),
                    (row == null) ? 0 : row.getTotalWrongCount(),
                    (row == null) ? null : row.getLastAttemptAt()
            );

            result.add(new ClassApiModels.StudentProgressResponse(
                    m.getId(),
                    m.getClassId(),
                    m.getDecidedAt(), // approvedAt
                    toUserProfile(u, sid),
                    progress
            ));
        }

        // 按学生姓名排序（为空则靠后），再按 userId
        result.sort(Comparator
                .comparing((ClassApiModels.StudentProgressResponse r) -> {
                    String name = (r.student() == null) ? null : r.student().name();
                    if (name == null) return null;
                    String t = name.trim();
                    return t.isBlank() ? null : t;
                }, Comparator.nullsLast(String::compareToIgnoreCase))
                .thenComparing(r -> r.student().userId())
        );

        return result;
    }

    @Transactional(readOnly = true)
    public List<ClassApiModels.RecommendedQuestionResponse> recommendedForStudent(
            String teacherId,
            UUID classId,
            String studentId
    ) {
        ClassroomEntity c = requireOwnedClass(classId, teacherId);

        ClassMembershipEntity m = membershipRepo.findByClassIdAndStudentId(c.getId(), studentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "student not in class"));

        if (m.getStatus() != ClassMembershipStatus.APPROVED) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "student is not approved in this class");
        }

        return uqsRepo.findRecommended(studentId).stream()
                .map(r -> new ClassApiModels.RecommendedQuestionResponse(
                        r.getQuestionId(),
                        r.getWrongCount(),
                        r.getLastWrongAt(),
                        r.getStem(),
                        r.getType(),
                        r.getDifficulty()
                ))
                .toList();
    }

    // ---- helpers ----

    private ClassroomEntity requireOwnedClass(UUID classId, String teacherId) {
        // 返回 404，避免泄露“存在但不是你的班级”
        return classRepo.findByIdAndTeacherId(classId, teacherId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "class not found: " + classId));
    }

    private void decideJoinRequest(String teacherId, UUID classId, UUID membershipId, boolean approve) {
        ClassroomEntity c = requireOwnedClass(classId, teacherId);

        ClassMembershipEntity m = membershipRepo.findById(membershipId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "join request not found: " + membershipId));

        if (!m.getClassId().equals(c.getId())) {
            // 防止用其它班级的 membershipId 越权
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "join request not found: " + membershipId);
        }

        if (approve) {
            if (m.getStatus() == ClassMembershipStatus.APPROVED) return;
            if (m.getStatus() == ClassMembershipStatus.REJECTED) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "request already rejected");
            }
            m.setStatus(ClassMembershipStatus.APPROVED);
        } else {
            if (m.getStatus() == ClassMembershipStatus.REJECTED) return;
            if (m.getStatus() == ClassMembershipStatus.APPROVED) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "request already approved");
            }
            m.setStatus(ClassMembershipStatus.REJECTED);
        }

        m.setDecidedAt(Instant.now());
        m.setDecidedBy(teacherId);
        membershipRepo.save(m);
    }

    private ClassApiModels.ClassResponse toClassResponse(ClassroomEntity c) {
        return new ClassApiModels.ClassResponse(c.getId(), c.getName(), c.getTeacherId(), c.getCreatedAt());
    }

    private ClassApiModels.MembershipResponse toMembershipResponse(ClassMembershipEntity m) {
        return new ClassApiModels.MembershipResponse(
                m.getId(),
                m.getClassId(),
                m.getStudentId(),
                m.getStatus(),
                m.getRequestedAt(),
                m.getDecidedAt(),
                m.getDecidedBy()
        );
    }

    private ClassApiModels.MembershipSummary toMembershipSummary(ClassMembershipEntity m) {
        return new ClassApiModels.MembershipSummary(
                m.getId(),
                m.getStatus(),
                m.getRequestedAt(),
                m.getDecidedAt()
        );
    }

    private ClassApiModels.UserProfileResponse toUserProfile(AppUserEntity u, String fallbackUserId) {
        if (u == null) {
            // 兜底，避免整页 500
            return new ClassApiModels.UserProfileResponse(fallbackUserId, null, null, null);
        }
        return new ClassApiModels.UserProfileResponse(
                u.getUserId(),
                u.getUsername(),
                u.getEmail(),
                u.getName()
        );
    }

    @Transactional
    public void removeMember(String teacherId, UUID classId, UUID membershipId) {
        ClassroomEntity c = requireOwnedClass(classId, teacherId);

        ClassMembershipEntity m = membershipRepo.findById(membershipId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "membership not found: " + membershipId));

        if (!m.getClassId().equals(c.getId())) {
            // 防止拿其他班级的 membershipId 越权
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "membership not found: " + membershipId);
        }

        // 直接删除即可：对 APPROVED 相当于“移出班级”；对 PENDING 相当于“撤销该申请记录”
        membershipRepo.delete(m);
    }

}
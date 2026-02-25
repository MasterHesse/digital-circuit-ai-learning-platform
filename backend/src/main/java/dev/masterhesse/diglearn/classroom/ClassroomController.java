package dev.masterhesse.diglearn.classroom;

import dev.masterhesse.diglearn.auth.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/classes")
public class ClassroomController {

    private final ClassroomService classroomService;

    // ========== TEACHER: 创建/列表/改/删 ==========

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public ClassApiModels.ClassResponse create(
            @AuthenticationPrincipal UserPrincipal p,
            @Valid @RequestBody ClassApiModels.CreateClassRequest req
    ) {
        return classroomService.createClass(p.userId(), req);
    }

    @GetMapping("/teaching")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public List<ClassApiModels.ClassResponse> listTeaching(@AuthenticationPrincipal UserPrincipal p) {
        return classroomService.listTeachingClasses(p.userId());
    }

    @PutMapping("/{classId}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ClassApiModels.ClassResponse update(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId,
            @Valid @RequestBody ClassApiModels.UpdateClassRequest req
    ) {
        return classroomService.updateClass(p, classId, req);
    }

    @DeleteMapping("/{classId}")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId
    ) {
        classroomService.deleteClass(p, classId);
    }

    // ========== 通用：班级详情（用于展示 name/teacher/ID + 学生我的加入状态） ==========

    @GetMapping("/{classId}")
    @PreAuthorize("isAuthenticated()")
    public ClassApiModels.ClassDetailResponse detail(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId
    ) {
        return classroomService.getClassDetail(p.userId(), classId);
    }

    @DeleteMapping("/api/classes/{classId}/memberships/{membershipId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeMember(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId,
            @PathVariable UUID membershipId
    ) {
        classroomService.removeMember(p.userId(), classId, membershipId);
    }

    // ========== STUDENT: 我的班级列表（含 PENDING/APPROVED/REJECTED） ==========

    @GetMapping("/joined")
    @PreAuthorize("hasRole('STUDENT')")
    public List<ClassApiModels.MyClassResponse> joined(@AuthenticationPrincipal UserPrincipal p) {
        return classroomService.listJoinedClasses(p.userId());
    }

    // STUDENT: 退出班级/取消申请（直接删除 membership，简单干净）
    @DeleteMapping("/{classId}/membership")
    @PreAuthorize("hasRole('STUDENT')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void leave(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId
    ) {
        classroomService.leaveOrCancel(p.userId(), classId);
    }

    // ========== 你原有的接口：申请/审核/学生列表/推荐 ==========

    @PostMapping("/{classId}/apply")
    @PreAuthorize("hasRole('STUDENT')")
    public ClassApiModels.MembershipResponse apply(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId
    ) {
        return classroomService.applyToClass(p.userId(), classId);
    }

    @GetMapping("/{classId}/join-requests")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public List<ClassApiModels.JoinRequestResponse> joinRequests(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId
    ) {
        return classroomService.listPendingJoinRequests(p.userId(), classId);
    }

    @PostMapping("/{classId}/join-requests/{membershipId}/approve")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void approve(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId,
            @PathVariable UUID membershipId
    ) {
        classroomService.approveJoinRequest(p.userId(), classId, membershipId);
    }

    @PostMapping("/{classId}/join-requests/{membershipId}/reject")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reject(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId,
            @PathVariable UUID membershipId
    ) {
        classroomService.rejectJoinRequest(p.userId(), classId, membershipId);
    }

    @GetMapping("/{classId}/students")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public List<ClassApiModels.StudentProgressResponse> students(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId
    ) {
        return classroomService.listStudentsWithProgress(p.userId(), classId);
    }

    @GetMapping("/{classId}/students/{studentId}/recommended")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public List<ClassApiModels.RecommendedQuestionResponse> recommended(
            @AuthenticationPrincipal UserPrincipal p,
            @PathVariable UUID classId,
            @PathVariable String studentId
    ) {
        return classroomService.recommendedForStudent(p.userId(), classId, studentId);
    }
}
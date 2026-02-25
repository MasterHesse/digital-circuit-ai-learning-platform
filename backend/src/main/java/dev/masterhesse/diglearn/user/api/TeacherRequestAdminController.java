package dev.masterhesse.diglearn.user.api;

import dev.masterhesse.diglearn.user.UserRole;
import dev.masterhesse.diglearn.user.persistence.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import org.springframework.transaction.annotation.Transactional;
import java.time.Instant;
import java.util.List;
import java.util.NoSuchElementException;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users/teacher-requests")
public class TeacherRequestAdminController {

    private final TeacherRequestRepository teacherRequestRepo;
    private final AppUserRepository userRepo;

    public record TeacherRequestRow(
            String userId,
            String username,
            String email,
            String name,
            Instant requestedAt
    ) {}

    @GetMapping
    public List<TeacherRequestRow> pending() {
        var reqs = teacherRequestRepo.findByStatusOrderByRequestedAtAsc(TeacherRequestStatus.PENDING);

        // 这里为了简单：逐个取 user（PENDING 数量通常不大）
        return reqs.stream().map(r -> {
            var u = userRepo.findById(r.getUserId()).orElse(null);
            return new TeacherRequestRow(
                    r.getUserId(),
                    u == null ? "(missing)" : u.getUsername(),
                    u == null ? "(missing)" : u.getEmail(),
                    u == null ? "(missing)" : u.getName(),
                    r.getRequestedAt()
            );
        }).toList();
    }

    @PostMapping("/{userId}/approve")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Transactional
    public void approve(@PathVariable String userId) {
        var req = teacherRequestRepo.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("teacher request not found: " + userId));

        if (req.getStatus() != TeacherRequestStatus.PENDING) return;

        var u = userRepo.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("user not found: " + userId));

        u.setRole(UserRole.TEACHER);
        u.setEnabled(true);
        userRepo.save(u);

        req.setStatus(TeacherRequestStatus.APPROVED);
        req.setDecidedAt(Instant.now());
        teacherRequestRepo.save(req);
    }

    @PostMapping("/{userId}/reject")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Transactional
    public void reject(@PathVariable String userId) {
        var req = teacherRequestRepo.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("teacher request not found: " + userId));

        if (req.getStatus() != TeacherRequestStatus.PENDING) return;

        // ✅ 先标记 REJECTED（满足“标记申请”）
        req.setStatus(TeacherRequestStatus.REJECTED);
        req.setDecidedAt(Instant.now());
        teacherRequestRepo.save(req);

        // ✅ 再删除用户（满足“删除该用户”）
        // 注意：若你的系统还有其它表用 FK 引用 app_users.user_id，这里可能会因为约束删除失败
        userRepo.deleteById(userId);

        // 如果你更想“删除申请”而不是“标记申请”，改成：
        // teacherRequestRepo.deleteById(userId);
        // userRepo.deleteById(userId);
    }
}
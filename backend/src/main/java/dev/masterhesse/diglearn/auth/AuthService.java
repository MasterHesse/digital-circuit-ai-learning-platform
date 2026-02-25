package dev.masterhesse.diglearn.auth;

import dev.masterhesse.diglearn.user.UserRole;
import dev.masterhesse.diglearn.user.persistence.*;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AppUserRepository repo;
    private final PasswordEncoder passwordEncoder;

    // ✅ 新增：教师申请收件箱
    private final TeacherRequestRepository teacherRequestRepo;

    public AuthApiModels.MeResponse register(AuthApiModels.RegisterRequest req) {
        String username = AuthNormalization.normalizeUsername(req.username());
        String email = AuthNormalization.normalizeEmail(req.email());
        String name = (req.name() == null) ? "" : req.name().trim();
        if (name.isBlank()) name = username;

        // desiredRole 允许为空，默认 STUDENT
        String desiredRole = (req.desiredRole() == null) ? "STUDENT" : req.desiredRole().trim().toUpperCase();
        boolean wantTeacher = "TEACHER".equals(desiredRole);

        if (!username.matches("^[a-z0-9_]{3,20}$")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "username must match ^[a-z0-9_]{3,20}$");
        }

        if (repo.existsByUsername(username)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "username already exists: " + username);
        }
        if (repo.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "email already exists: " + email);
        }

        AppUserEntity e = new AppUserEntity();
        e.setUserId(UUID.randomUUID().toString());
        e.setUsername(username);
        e.setEmail(email);
        e.setPasswordHash(passwordEncoder.encode(req.password()));
        e.setRole(UserRole.STUDENT);

        // ✅ 关键：教师申请注册 -> 账号先禁用（无法登录）
        e.setEnabled(!wantTeacher);

        e.setName(name);

        try {
            repo.save(e);
        } catch (DataIntegrityViolationException ex) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "username/email already exists");
        }

        // ✅ 关键：写入 teacher_requests 收件箱
        if (wantTeacher) {
            TeacherRequestEntity tr = new TeacherRequestEntity();
            tr.setUserId(e.getUserId());
            tr.setStatus(TeacherRequestStatus.PENDING);
            tr.setRequestedAt(Instant.now());
            teacherRequestRepo.save(tr);
        }

        return new AuthApiModels.MeResponse(
                e.getUserId(),
                e.getUsername(),
                e.getEmail(),
                e.getName(),
                e.getRole().name()
        );
    }
}
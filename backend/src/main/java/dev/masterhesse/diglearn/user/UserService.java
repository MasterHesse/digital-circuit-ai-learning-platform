package dev.masterhesse.diglearn.user;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.transaction.annotation.Transactional;

import dev.masterhesse.diglearn.user.persistence.AppUserEntity;
import dev.masterhesse.diglearn.user.persistence.AppUserRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final AppUserRepository repo;

    public List<UserApiModels.UserResponse> list() {
        return repo.findAll(Sort.by("name").ascending()).stream()
                .map(u -> new UserApiModels.UserResponse(u.getUserId(), u.getName()))
                .toList();
    }

    public UserApiModels.UserResponse create(UserApiModels.UserCreateRequest req) {
        String name = (req.name() == null) ? "" : req.name().trim();
        if (name.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "name is required");
        }

        String userId = (req.userId() == null || req.userId().isBlank())
                ? UUID.randomUUID().toString()
                : req.userId().trim();

        if (repo.existsById(userId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "user already exists: " + userId);
        }

        AppUserEntity e = new AppUserEntity();
        e.setUserId(userId);
        e.setName(name);
        repo.save(e);

        return new UserApiModels.UserResponse(e.getUserId(), e.getName());
    }

    @Transactional
    public void promoteStudentToTeacher(String userId) {
        AppUserEntity u = repo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "user not found: " + userId));

        if (u.getRole() == UserRole.ADMIN) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cannot change ADMIN");
        }
        if (u.getRole() == UserRole.TEACHER) {
            return; // 幂等
        }
        if (u.getRole() != UserRole.STUDENT) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "only STUDENT can be promoted");
        }

        u.setRole(UserRole.TEACHER);
        repo.save(u);
    }
}
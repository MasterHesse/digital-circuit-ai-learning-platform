package dev.masterhesse.diglearn.user.api;

import dev.masterhesse.diglearn.user.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {

    private final AppUserRepository repo;

    public record UserCreateRequest(String userId, @NotBlank String name) {}
    public record UserResponse(String userId, String name) {}

    @GetMapping
    public List<UserResponse> list() {
        return repo.findAll().stream()
                .sorted(Comparator.comparing(AppUserEntity::getName))
                .map(u -> new UserResponse(u.getUserId(), u.getName()))
                .toList();
    }

    @PostMapping
    public UserResponse create(@RequestBody UserCreateRequest req) {
        String name = req.name() == null ? "" : req.name().trim();
        if (name.isBlank()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "name is required");

        String userId = (req.userId() == null || req.userId().isBlank())
                ? UUID.randomUUID().toString()
                : req.userId().trim();

        if (repo.existsById(userId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "user exists: " + userId);
        }

        AppUserEntity e = new AppUserEntity();
        e.setUserId(userId);
        e.setName(name);
        repo.save(e);
        return new UserResponse(e.getUserId(), e.getName());
    }
}
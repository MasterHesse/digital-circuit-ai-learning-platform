// src/main/java/dev/masterhesse/diglearn/shared/application/UserGuard.java
package dev.masterhesse.diglearn.shared.application;

import dev.masterhesse.diglearn.user.persistence.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
@RequiredArgsConstructor
public class UserGuard {

    private final AppUserRepository appUserRepository;

    public String requireValidUserId(String userId) {
        if (userId == null || userId.trim().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "X-User-Id is required");
        }
        String uid = userId.trim();
        if (!appUserRepository.existsById(uid)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "user not found: " + uid);
        }
        return uid;
    }
}
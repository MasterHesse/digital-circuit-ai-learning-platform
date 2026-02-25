package dev.masterhesse.diglearn.user.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AppUserRepository extends JpaRepository<AppUserEntity, String> {
    Optional<AppUserEntity> findByUsername(String username);
    Optional<AppUserEntity> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
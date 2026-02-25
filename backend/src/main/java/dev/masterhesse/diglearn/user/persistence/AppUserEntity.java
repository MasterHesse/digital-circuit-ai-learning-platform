package dev.masterhesse.diglearn.user.persistence;

import dev.masterhesse.diglearn.user.UserRole;
import jakarta.persistence.*;

@Entity
@Table(
        name = "app_users",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_app_users_username", columnNames = "username"),
                @UniqueConstraint(name = "uk_app_users_email", columnNames = "email")
        }
)
public class AppUserEntity {
    @Id
    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    @Column(name = "username", nullable = false, length = 64)
    private String username; // 存规范化后的（小写、去掉前导@）

    @Column(name = "email", nullable = false, length = 254)
    private String email;    // 建议存小写

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, length = 20)
    private UserRole role;

    @Column(name = "name", nullable = false, length = 128)
    private String name;

    @Column(nullable = false)
    private boolean enabled = true;

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public UserRole getRole() { return role; }
    public void setRole(UserRole role) { this.role = role; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
}
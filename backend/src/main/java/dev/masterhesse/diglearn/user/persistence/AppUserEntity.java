package dev.masterhesse.diglearn.user.persistence;

import jakarta.persistence.*;

@Entity
@Table(name = "app_users")
public class AppUserEntity {
    @Id
    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    @Column(name = "name", nullable = false, length = 128)
    private String name;

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
}
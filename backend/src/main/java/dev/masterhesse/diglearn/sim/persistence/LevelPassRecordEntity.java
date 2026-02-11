package dev.masterhesse.diglearn.sim.persistence;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(
    name = "level_pass_records",
    uniqueConstraints = @UniqueConstraint(
        name = "uk_level_pass_user_level",
        columnNames = {"user_id", "level_code"}
    )
)
public class LevelPassRecordEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    @Column(name = "level_code", nullable = false, length = 64)
    private String levelCode;

    @Column(name = "first_passed_at", nullable = false)
    private Instant firstPassedAt;

    @Column(name = "last_passed_at", nullable = false)
    private Instant lastPassedAt;

    @Column(name = "pass_count", nullable = false)
    private int passCount;

    public Long getId() { return id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getLevelCode() { return levelCode; }
    public void setLevelCode(String levelCode) { this.levelCode = levelCode; }

    public Instant getFirstPassedAt() { return firstPassedAt; }
    public void setFirstPassedAt(Instant firstPassedAt) { this.firstPassedAt = firstPassedAt; }

    public Instant getLastPassedAt() { return lastPassedAt; }
    public void setLastPassedAt(Instant lastPassedAt) { this.lastPassedAt = lastPassedAt; }

    public int getPassCount() { return passCount; }
    public void setPassCount(int passCount) { this.passCount = passCount; }
}
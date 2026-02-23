// src/main/java/dev/masterhesse/diglearn/practice/persistence/UserQuestionStateEntity.java
package dev.masterhesse.diglearn.practice.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(
        name = "user_question_state",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_user_question_state", columnNames = {"user_id", "question_id"})
        },
        indexes = {
                @Index(name = "idx_uqs_user_mastered", columnList = "user_id,mastered")
        }
)
public class UserQuestionStateEntity {

    @Id
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    @Column(name = "question_id", nullable = false)
    private UUID questionId;

    @Column(name = "mastered", nullable = false)
    private boolean mastered = false;

    @Column(name = "wrong_count", nullable = false)
    private int wrongCount = 0;

    @Column(name = "last_wrong_at")
    private Instant lastWrongAt;

    @Column(name = "last_attempt_at")
    private Instant lastAttemptAt;

    @PrePersist
    void prePersist() {
        if (id == null) id = UUID.randomUUID();
    }
}
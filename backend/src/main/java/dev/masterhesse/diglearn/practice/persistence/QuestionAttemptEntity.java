// src/main/java/dev/masterhesse/diglearn/practice/persistence/QuestionAttemptEntity.java
package dev.masterhesse.diglearn.practice.persistence;

import dev.masterhesse.diglearn.practice.domain.PracticeMode;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(
        name = "question_attempts",
        indexes = {
                @Index(name = "idx_attempt_user_question", columnList = "user_id,question_id"),
                @Index(name = "idx_attempt_user_mode", columnList = "user_id,mode")
        }
)
public class QuestionAttemptEntity {

    @Id
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    @Column(name = "question_id", nullable = false)
    private UUID questionId;

    @Enumerated(EnumType.STRING)
    @Column(name = "mode", nullable = false, length = 20)
    private PracticeMode mode;

    // 章节练习上下文（用于统计/展示）
    @Column(name = "context_kp_id", length = 64)
    private String contextKpId;

    // 巩固练习：由哪一道错题触发
    @Column(name = "source_question_id")
    private UUID sourceQuestionId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "user_answer", nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> userAnswer;

    @Column(name = "is_correct")
    private Boolean isCorrect;

    @Column(name = "submitted_at", nullable = false)
    private Instant submittedAt;

    @PrePersist
    void prePersist() {
        if (id == null) id = UUID.randomUUID();
        if (submittedAt == null) submittedAt = Instant.now();
    }
}
// src/main/java/dev/masterhesse/diglearn/question/persistence/QuestionTagMapEntity.java
package dev.masterhesse.diglearn.question.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(
        name = "question_tag_map",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_question_tag", columnNames = {"question_id", "tag_id"})
        },
        indexes = {
                @Index(name = "idx_qtm_tag_id", columnList = "tag_id")
        }
)
public class QuestionTagMapEntity {

    @EmbeddedId
    private QuestionTagMapId id;

    @Column(name = "weight", nullable = false)
    private int weight = 1;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null) createdAt = Instant.now();
        if (weight <= 0) weight = 1;
    }

    public static QuestionTagMapEntity of(QuestionTagMapId id, int weight) {
        var e = new QuestionTagMapEntity();
        e.setId(id);
        e.setWeight(weight);
        return e;
    }
}
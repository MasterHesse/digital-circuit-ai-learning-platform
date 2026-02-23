// src/main/java/dev/masterhesse/diglearn/question/persistence/QuestionTagMapId.java
package dev.masterhesse.diglearn.question.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@EqualsAndHashCode
@Embeddable
public class QuestionTagMapId implements Serializable {

    @Column(name = "question_id", nullable = false)
    private UUID questionId;

    @Column(name = "tag_id", nullable = false)
    private UUID tagId;

    public QuestionTagMapId(UUID questionId, UUID tagId) {
        this.questionId = questionId;
        this.tagId = tagId;
    }
}
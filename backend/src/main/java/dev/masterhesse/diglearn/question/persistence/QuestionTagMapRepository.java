// src/main/java/dev/masterhesse/diglearn/question/persistence/QuestionTagMapRepository.java
package dev.masterhesse.diglearn.question.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface QuestionTagMapRepository extends JpaRepository<QuestionTagMapEntity, QuestionTagMapId> {

    @Modifying
    @Query(value = "delete from question_tag_map where question_id = :questionId", nativeQuery = true)
    void deleteAllByQuestionId(UUID questionId);

    @Query(value = "select tag_id from question_tag_map where question_id = :questionId", nativeQuery = true)
    List<UUID> findTagIdsByQuestionId(UUID questionId);
}
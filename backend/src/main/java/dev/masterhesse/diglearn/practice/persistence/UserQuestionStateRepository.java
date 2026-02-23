// src/main/java/dev/masterhesse/diglearn/practice/persistence/UserQuestionStateRepository.java
package dev.masterhesse.diglearn.practice.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserQuestionStateRepository extends JpaRepository<UserQuestionStateEntity, UUID> {

    Optional<UserQuestionStateEntity> findByUserIdAndQuestionId(String userId, UUID questionId);

    interface RecommendedRow {
        UUID getQuestionId();
        int getWrongCount();
        Instant getLastWrongAt();
        String getStem();
        String getType();
        short getDifficulty();
    }

    @Query(value = """
        select
            uqs.question_id as questionId,
            uqs.wrong_count as wrongCount,
            uqs.last_wrong_at as lastWrongAt,
            q.stem as stem,
            q.type as type,
            q.difficulty as difficulty
        from user_question_state uqs
        join questions q on q.id = uqs.question_id
        where uqs.user_id = :userId
          and uqs.mastered = false
          and uqs.wrong_count > 0
          and q.status = 'PUBLISHED'
        order by uqs.last_wrong_at desc nulls last
        """, nativeQuery = true)
    List<RecommendedRow> findRecommended(String userId);
}
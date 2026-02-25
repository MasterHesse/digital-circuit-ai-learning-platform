// src/main/java/dev/masterhesse/diglearn/practice/persistence/UserQuestionStateRepository.java
package dev.masterhesse.diglearn.practice.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

    interface ProgressRow {
        String getUserId();
        long getAttemptedCount();
        long getMasteredCount();
        long getUnmasteredWrongCount();
        long getTotalWrongCount();
        Instant getLastAttemptAt();
    }

    @Query(value = """
        select
            uqs.user_id as userId,
            coalesce(sum(case when uqs.last_attempt_at is not null then 1 else 0 end), 0) as attemptedCount,
            coalesce(sum(case when uqs.mastered = true then 1 else 0 end), 0) as masteredCount,
            coalesce(sum(case when uqs.mastered = false and uqs.wrong_count > 0 then 1 else 0 end), 0) as unmasteredWrongCount,
            coalesce(sum(uqs.wrong_count), 0) as totalWrongCount,
            max(uqs.last_attempt_at) as lastAttemptAt
        from user_question_state uqs
        where uqs.user_id in (:userIds)
        group by uqs.user_id
        """, nativeQuery = true)
    List<ProgressRow> findProgressByUserIds(@Param("userIds") List<String> userIds);    

    long countByUserIdAndMasteredFalseAndWrongCountGreaterThan(String userId, int wrongCount);
}
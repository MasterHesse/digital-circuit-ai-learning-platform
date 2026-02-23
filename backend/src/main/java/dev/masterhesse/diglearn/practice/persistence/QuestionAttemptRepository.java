// src/main/java/dev/masterhesse/diglearn/practice/persistence/QuestionAttemptRepository.java
package dev.masterhesse.diglearn.practice.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface QuestionAttemptRepository extends JpaRepository<QuestionAttemptEntity, UUID> {

    boolean existsByUserIdAndQuestionId(String userId, UUID questionId);

    /**
     * 查询用户已作答的题目 ID 集合。
     *
     * 调用方（PracticeService.listChapterQuestions）传入的 questionIds
     * 已由 findPublishedByKpId 限定为 CHAPTER 池，
     * 因此本查询无需再额外过滤 question_pool。
     */
    @Query(value = """
        select distinct a.question_id
        from question_attempts a
        where a.user_id = :userId
          and a.question_id in (:questionIds)
        """, nativeQuery = true)
    List<UUID> findAttemptedQuestionIds(String userId, Collection<UUID> questionIds);

    /**
     * 统计用户在某 KP 下已作答的【章节练习题】去重数量。
     *
     * 修复说明：
     *   原查询未过滤 question_pool，导致用户做过 SUPPLEMENT 补充题后，
     *   其作答数被计入章节进度，可能使 attempted >= total 提前成立，
     *   章节状态虚假变为"完成"。
     *
     *   修复方式：JOIN questions 表并强制过滤 question_pool = 'CHAPTER'，
     *   与 countPublishedByKpId 的统计口径严格对齐，保证进度计算一致。
     */
    @Query(value = """
        select count(distinct a.question_id)
        from question_attempts a
        join questions          q   on q.id          = a.question_id
        join question_tag_map   qtm on qtm.question_id = a.question_id
        join tag_kp_map         tkm on tkm.tag_id      = qtm.tag_id
        where a.user_id        = :userId
          and tkm.kp_id        = :kpId
          and q.question_pool  = 'CHAPTER'
        """, nativeQuery = true)
    long countAttemptedDistinctByUserAndKpId(String userId, String kpId);
}
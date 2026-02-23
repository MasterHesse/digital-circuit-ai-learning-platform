// src/main/java/dev/masterhesse/diglearn/question/persistence/QuestionRepository.java
package dev.masterhesse.diglearn.question.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface QuestionRepository extends JpaRepository<QuestionEntity, UUID> {

    /**
     * 统计某 KP 下已发布的【章节练习题】数量（question_pool = 'CHAPTER'）。
     *
     * 用于 PracticeService.listChapters() 中计算 totalQuestions，
     * 只统计 CHAPTER 池题目，确保章节完成进度不被 SUPPLEMENT 题干扰。
     */
    @Query(nativeQuery = true, value = """
            SELECT COUNT(DISTINCT q.id)
            FROM questions q
            JOIN question_tag_map qtm ON q.id = qtm.question_id
            JOIN tags             t   ON qtm.tag_id = t.id
            JOIN tag_kp_map       tkm ON t.id = tkm.tag_id
            WHERE tkm.kp_id         = :kpId
              AND q.status          = 'PUBLISHED'
              AND q.question_pool   = 'CHAPTER'
            """)
    long countPublishedByKpId(@Param("kpId") String kpId);

    /**
     * 查询某 KP 下已发布的【章节练习题】列表（question_pool = 'CHAPTER'）。
     *
     * 用于 PracticeService.listChapterQuestions()，
     * 章节练习页面只展示 CHAPTER 池，不混入 SUPPLEMENT 补充题。
     * 按难度升序 + 入库时间升序排列，保证题目顺序稳定。
     */
    @Query(nativeQuery = true, value = """
            SELECT DISTINCT q.*
            FROM questions q
            JOIN question_tag_map qtm ON q.id = qtm.question_id
            JOIN tags             t   ON qtm.tag_id = t.id
            JOIN tag_kp_map       tkm ON t.id = tkm.tag_id
            WHERE tkm.kp_id         = :kpId
              AND q.status          = 'PUBLISHED'
              AND q.question_pool   = 'CHAPTER'
            ORDER BY q.difficulty ASC, q.created_at ASC
            """)
    List<QuestionEntity> findPublishedByKpId(@Param("kpId") String kpId);

    /**
     * 查询用户已尝试过的题目 ID 集合（用于前端标记"已做"状态）。
     *
     * 接受显式传入的题目 ID 列表，与 pool 无关，
     * 在 listChapterQuestions 中仅会传入 CHAPTER 题的 ID，
     * 因此结果不会污染章节进度展示。
     */
    @Query("""
            SELECT qa.questionId
            FROM QuestionAttemptEntity qa
            WHERE qa.userId = :userId
              AND qa.questionId IN :questionIds
            """)
    List<UUID> findAttemptedQuestionIds(
            @Param("userId")      String     userId,
            @Param("questionIds") List<UUID> questionIds
    );

    /**
     * 巩固推荐题查询（核心推荐逻辑）。
     *
     * <h4>筛选规则（四层过滤）</h4>
     * <ol>
     *   <li><b>仅 SUPPLEMENT 池</b>：从根本上保证不会把同 KP 的 CHAPTER 题推回给用户。</li>
     *   <li><b>Tag 权重 ≥ 70 匹配</b>：仅匹配 KP 精确标签（weight=100）和跨 KP 溯源标签
     *       （weight=70），跳过纯主题分类标签（weight=50），保证推荐题与错题在知识点层面
     *       真正相关。溯源链路示例：BOOL-06 错题 → 推 BOOL-05 补充题（via weight=70 tag）
     *       → 推 BOOL-04 补充题，沿知识图谱 PREREQ 边逐级向前。</li>
     *   <li><b>排除已掌握题目</b>：跳过 user_question_state.mastered = TRUE 的题，
     *       避免重复推送用户已消化的内容。</li>
     *   <li><b>排除题源自身</b>：不把 sourceQuestion 本身推回。</li>
     * </ol>
     *
     * <p>结果使用 RANDOM() 随机排序（Demo 合理，生产环境可改为按
     * 错误次数或遗忘曲线排序）。</p>
     */
    @Query(nativeQuery = true, value = """
            SELECT *
            FROM (
                SELECT DISTINCT q.*
                FROM questions        q
                JOIN question_tag_map q_match ON q.id = q_match.question_id
                WHERE q.question_pool = 'SUPPLEMENT'
                  AND q.status        = 'PUBLISHED'
                  AND q.id           <> :sourceQuestionId
                  -- Tag 权重 ≥ 70：精确 KP 匹配 + 跨 KP 溯源，排除纯主题 tag
                  AND q_match.tag_id IN (
                          SELECT src.tag_id
                          FROM   question_tag_map src
                          WHERE  src.question_id = :sourceQuestionId
                            AND  src.weight     >= 70
                  )
                  -- 排除用户已掌握的题目
                  AND q.id NOT IN (
                          SELECT uqs.question_id
                          FROM   user_question_state uqs
                          WHERE  uqs.user_id  = :userId
                            AND  uqs.mastered = TRUE
                  )
            ) candidate
            ORDER BY RANDOM()
            LIMIT :limit
            """)
    List<QuestionEntity> findReinforcement(
            @Param("sourceQuestionId") UUID   sourceQuestionId,
            @Param("userId")           String userId,
            @Param("limit")            int    limit
    );

        @Query(value = """
        select distinct tkm.kp_id
        from question_tag_map qtm
        join tag_kp_map tkm on tkm.tag_id = qtm.tag_id
        where qtm.question_id = :questionId
        """, nativeQuery = true)
    List<String> findKpIdsByQuestionId(UUID questionId);
}
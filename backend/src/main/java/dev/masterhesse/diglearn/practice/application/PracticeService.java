// src/main/java/dev/masterhesse/diglearn/practice/application/PracticeService.java
package dev.masterhesse.diglearn.practice.application;

import dev.masterhesse.diglearn.knowledgepoint.application.KpGraphService;
import dev.masterhesse.diglearn.practice.persistence.QuestionAttemptRepository;
import dev.masterhesse.diglearn.practice.persistence.UserQuestionStateRepository;
import dev.masterhesse.diglearn.question.domain.QuestionType;
import dev.masterhesse.diglearn.question.persistence.QuestionEntity;
import dev.masterhesse.diglearn.question.persistence.QuestionRepository;
import dev.masterhesse.diglearn.shared.application.UserGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Service
@RequiredArgsConstructor
public class PracticeService {

    private final UserGuard                  userGuard;
    private final KpGraphService             kpGraphService;
    private final QuestionRepository         questionRepository;
    private final QuestionAttemptRepository  attemptRepository;
    private final UserQuestionStateRepository stateRepository;

    // ---- DTOs ----

    public record ChapterRow(
            String  kpId,
            String  title,
            int     difficulty,
            long    totalQuestions,   // 仅统计 CHAPTER 池题目
            long    attempted,        // 仅统计 CHAPTER 池的作答数
            boolean done
    ) {}

    public record QuestionRow(
            UUID                 id,
            QuestionType         type,
            String               stem,
            short                difficulty,
            Map<String, Object>  content,
            boolean              attempted
    ) {}

    public record RecommendedRow(
            UUID   questionId,
            int    wrongCount,
            Object lastWrongAt,
            String stem,
            String type,
            short  difficulty
    ) {}

    // ---- 章节列表 ----

    public List<ChapterRow> listChapters(String userIdHeader, String category) {
        String userId = userGuard.requireValidUserId(userIdHeader);

        String cat = (category == null || category.isBlank()) ? "BOOL" : category.trim();
        var kps = kpGraphService.listByCategory(cat);

        List<ChapterRow> out = new ArrayList<>();
        for (var kp : kps) {
            // countPublishedByKpId 已限定 question_pool = 'CHAPTER'
            long total = questionRepository.countPublishedByKpId(kp.kpId());

            // countAttemptedDistinctByUserAndKpId 也应限定 CHAPTER 池
            // ⚠️ 见文末 QuestionAttemptRepository 改动说明
            long attempted = attemptRepository.countAttemptedDistinctByUserAndKpId(userId, kp.kpId());

            boolean done = (total > 0) && (attempted >= total);
            out.add(new ChapterRow(kp.kpId(), kp.title(), kp.difficulty(), total, attempted, done));
        }
        return out;
    }

    // ---- 章节题列表 ----

    public List<QuestionRow> listChapterQuestions(String userIdHeader, String kpId) {
        String userId = userGuard.requireValidUserId(userIdHeader);
        if (kpId == null || kpId.isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "kpId is required");

        // findPublishedByKpId 已限定 question_pool = 'CHAPTER'
        List<QuestionEntity> qs = questionRepository.findPublishedByKpId(kpId.trim());
        List<UUID> ids = qs.stream().map(QuestionEntity::getId).toList();
        Set<UUID> attemptedSet = new HashSet<>(attemptRepository.findAttemptedQuestionIds(userId, ids));

        return qs.stream()
                .map(q -> new QuestionRow(
                        q.getId(),
                        q.getType(),
                        q.getStem(),
                        q.getDifficulty(),
                        q.getContent(),
                        attemptedSet.contains(q.getId())
                ))
                .toList();
    }

    // ---- 错题推荐列表 ----

    public List<RecommendedRow> listRecommended(String userIdHeader) {
        String userId = userGuard.requireValidUserId(userIdHeader);
        return stateRepository.findRecommended(userId).stream()
                .map(r -> new RecommendedRow(
                        r.getQuestionId(),
                        r.getWrongCount(),
                        r.getLastWrongAt(),
                        r.getStem(),
                        r.getType(),
                        r.getDifficulty()
                ))
                .toList();
    }

    // ---- 标记已掌握 ----

    @Transactional
    public void markMastered(String userIdHeader, UUID questionId) {
        String userId = userGuard.requireValidUserId(userIdHeader);
        if (questionId == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "questionId is required");

        var st = stateRepository.findByUserIdAndQuestionId(userId, questionId)
                .orElseGet(() -> {
                    var e = new dev.masterhesse.diglearn.practice.persistence.UserQuestionStateEntity();
                    e.setUserId(userId);
                    e.setQuestionId(questionId);
                    return e;
                });
        st.setMastered(true);
        stateRepository.save(st);
    }

    // ---- 巩固推荐题 ----

    /**
     * 从错题（sourceQuestion）出发，推荐相关的 SUPPLEMENT 补充题。
     *
     * <p>核心改动（相较旧版）：</p>
     * <ul>
     *   <li>正确捕获 userId，用于排除用户已掌握的题目。</li>
     *   <li>委托给 {@code findReinforcement} 查询，该查询强制
     *       {@code question_pool = 'SUPPLEMENT'}，从根本上避免把
     *       同 KP 的其他章节练习题（CHAPTER）推回给用户。</li>
     *   <li>通过 tag weight ≥ 70 实现跨 KP 知识溯源推荐
     *       （例如答错 BOOL-06 冒险题 → 推 BOOL-05 K-map 补充题）。</li>
     * </ul>
     */
    public List<QuestionRow> reinforcement(String userIdHeader, UUID sourceQuestionId, int count) {
        // 修复旧版：必须捕获 userId，用于排除已掌握题目
        String userId = userGuard.requireValidUserId(userIdHeader);

        if (sourceQuestionId == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sourceQuestionId is required");

        int n = Math.max(1, Math.min(count, 10));

        // 旧版：findReinforcement(sourceQuestionId, n)          ← 不区分 pool，可能推回章节题
        // 新版：findReinforcement(sourceQuestionId, userId, n)  ← 仅 SUPPLEMENT，排除已掌握
        List<QuestionEntity> qs = questionRepository.findReinforcement(sourceQuestionId, userId, n);

        return qs.stream()
                .map(q -> new QuestionRow(
                        q.getId(),
                        q.getType(),
                        q.getStem(),
                        q.getDifficulty(),
                        q.getContent(),
                        false   // 巩固题首次呈现不标记"已做"
                ))
                .toList();
    }
}
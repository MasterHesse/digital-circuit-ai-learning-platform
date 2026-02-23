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

    private final UserGuard                   userGuard;
    private final KpGraphService              kpGraphService;
    private final QuestionRepository          questionRepository;
    private final QuestionAttemptRepository   attemptRepository;
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

    // ✅ 新增：给前端“先学哪些知识点”
    public record RecoKpRow(
            String  kpId,
            String  title,
            Integer difficulty,
            Integer depth
    ) {}

    // ✅ 新增：reinforcement 的统一返回结构
    public record ReinforcementResponse(
            List<QuestionRow> questions,
            List<RecoKpRow> knowledgePoints
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

    // ---- 巩固推荐（题目 or 前置知识点） ----

    /**
     * 从错题（sourceQuestionId）出发：
     * - 若候选 SUPPLEMENT 题的 prereq（depth<=3）都已掌握：返回 questions
     * - 否则：返回 knowledgePoints（建议先学）
     */
    public ReinforcementResponse reinforcement(String userIdHeader, UUID sourceQuestionId, int count) {
        String userId = userGuard.requireValidUserId(userIdHeader);

        if (sourceQuestionId == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sourceQuestionId is required");

        int n = Math.max(1, Math.min(count, 10));

        // 为了“过滤掉缺前置的题”后仍能凑够 n，道数做一点 oversample
        int oversample = Math.min(50, n * 10);

        // 只召回 SUPPLEMENT，且排除已 mastered（你现有 findReinforcement 已做）
        List<QuestionEntity> candidates = questionRepository.findReinforcement(sourceQuestionId, userId, oversample);

        List<QuestionRow> okQuestions = new ArrayList<>(n);

        // missing prereq 聚合：kpId -> minDepth / meta / hitCount
        Map<String, Integer> missingMinDepth = new HashMap<>();
        Map<String, KpGraphService.PrereqRow> missingMeta = new HashMap<>();
        Map<String, Integer> missingHits = new HashMap<>();

        // kp 掌握缓存：kpId -> mastered?
        Map<String, Boolean> masteredCache = new HashMap<>();

        for (QuestionEntity q : candidates) {
            if (okQuestions.size() >= n) break;

            // 目标题对应的知识点（用已有 findKpIdsByQuestionId）
            String targetKpId = pickTargetKpId(q.getId());

            // 如果这个题根本拿不到 kpId（数据没绑 kp），那就不做 prereq gating，直接放行
            if (targetKpId == null || targetKpId.isBlank()) {
                okQuestions.add(toReinforcementRow(q));
                continue;
            }

            // prereq depth<=3
            List<KpGraphService.PrereqRow> prereqs = kpGraphService.listPrereqs(targetKpId, 3);

            // 过滤出未掌握的 prereq
            List<KpGraphService.PrereqRow> missing = prereqs.stream()
                    .filter(p -> !isKpMastered(userId, p.kpId(), masteredCache))
                    .toList();

            if (!missing.isEmpty()) {
                for (var p : missing) {
                    missingMinDepth.merge(p.kpId(), p.depth(), Math::min);
                    missingHits.merge(p.kpId(), 1, Integer::sum);

                    var cur = missingMeta.get(p.kpId());
                    if (cur == null || p.depth() < cur.depth()) missingMeta.put(p.kpId(), p);
                }
                // 该题缺前置：不推荐题，改为推荐知识点
                continue;
            }

            okQuestions.add(toReinforcementRow(q));
        }

        List<RecoKpRow> kps = buildRecoKps(missingMinDepth, missingHits, missingMeta, 5);

        return new ReinforcementResponse(okQuestions, kps);
    }

    // ---- helpers ----

    private QuestionRow toReinforcementRow(QuestionEntity q) {
        return new QuestionRow(
                q.getId(),
                q.getType(),
                q.getStem(),
                q.getDifficulty(),
                q.getContent(),
                false // 巩固题首次呈现不标记"已做"
        );
    }

    /**
     * 选择“题目主 kpId”
     * 当前实现：取 findKpIdsByQuestionId 的第一个
     * （如果你后面要做“按 tag 权重聚合出主 kp”，再升级这里即可）
     */
    private String pickTargetKpId(UUID questionId) {
        List<String> kpIds = questionRepository.findKpIdsByQuestionId(questionId);
        if (kpIds == null || kpIds.isEmpty()) return null;
        return kpIds.get(0);
    }

    /**
     * 判断某个 kp 是否掌握：基于章节题（CHAPTER 池）完成度近似
     */
    private boolean isKpMastered(String userId, String kpId, Map<String, Boolean> cache) {
        return cache.computeIfAbsent(kpId, id -> {
            long total = questionRepository.countPublishedByKpId(id); // CHAPTER only

            // 策略 A（当前）：没有章节题 => 视为未掌握（会推荐先学该 kp）
            if (total <= 0) return false;

            // 策略 B（可选）：没有章节题 => 不挡住（视为掌握）
            // if (total <= 0) return true;

            long attempted = attemptRepository.countAttemptedDistinctByUserAndKpId(userId, id);
            return attempted >= total;
        });
    }

    private List<RecoKpRow> buildRecoKps(
            Map<String, Integer> minDepth,
            Map<String, Integer> hits,
            Map<String, KpGraphService.PrereqRow> meta,
            int limit
    ) {
        if (minDepth == null || minDepth.isEmpty()) return List.of();
        int lim = Math.max(0, limit);

        Comparator<String> cmp = Comparator
                .comparingInt((String kpId) -> minDepth.getOrDefault(kpId, 999))
                // 同 depth 下：被“卡住”的次数多的优先
                .thenComparing((String kpId) -> -hits.getOrDefault(kpId, 0))
                .thenComparing(kpId -> kpId);

        return minDepth.keySet().stream()
                .sorted(cmp)
                .limit(lim)
                .map(kpId -> {
                    var m = meta.get(kpId);
                    Integer depth = minDepth.get(kpId);
                    return new RecoKpRow(
                            kpId,
                            m == null ? null : m.title(),
                            m == null ? null : m.difficulty(),
                            depth
                    );
                })
                .toList();
    }
}
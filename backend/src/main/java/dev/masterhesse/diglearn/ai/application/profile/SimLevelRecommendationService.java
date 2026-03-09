package dev.masterhesse.diglearn.ai.application.profile;

import dev.masterhesse.diglearn.sim.persistence.LevelEntity;
import dev.masterhesse.diglearn.sim.persistence.LevelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class SimLevelRecommendationService {

    private final LevelRepository levelRepository;
    private final SimPracticeProfileService simPracticeProfileService;

    @Transactional(readOnly = true)
    public List<RecommendedSimLevel> recommend(String userId, int limit) {
        int safeLimit = Math.max(1, Math.min(limit, 10));

        List<LevelEntity> allLevels = levelRepository.findAllByOrderByCodeAsc();
        if (allLevels.isEmpty()) {
            return List.of();
        }

        SimPracticeProfile profile = simPracticeProfileService.buildProfile(userId);
        Set<String> passed = profile.passedLevelCodes();

        List<LevelEntity> unpassedLevels = allLevels.stream()
                .filter(level -> level.getCode() != null && !passed.contains(level.getCode()))
                .toList();

        if (unpassedLevels.isEmpty()) {
            return List.of();
        }

        if (profile.passedLevelCount() == 0) {
            return unpassedLevels.stream()
                    .limit(safeLimit)
                    .map(level -> new RecommendedSimLevel(
                            level.getCode(),
                            nullToDefault(level.getTitle(), level.getCode()),
                            "按关卡顺序推荐，适合作为入门练习。"
                    ))
                    .toList();
        }

        Map<String, Integer> topicPassCounts = profile.topicPassCounts();

        return unpassedLevels.stream()
                .map(level -> score(level, topicPassCounts))
                .sorted(Comparator
                        .comparingDouble(ScoredLevel::score).reversed()
                        .thenComparing(ScoredLevel::code))
                .limit(safeLimit)
                .map(x -> new RecommendedSimLevel(x.code(), x.title(), x.reason()))
                .toList();
    }

    private ScoredLevel score(LevelEntity level, Map<String, Integer> topicPassCounts) {
        List<String> kpIds = new ArrayList<>(safeStrings(level.getKpIds()));

        double score = 0.0;
        List<String> unseenTopics = new ArrayList<>();
        List<String> lightTopics = new ArrayList<>();
        List<String> familiarTopics = new ArrayList<>();

        for (String kp : kpIds) {
            int cnt = topicPassCounts.getOrDefault(kp, 0);
            if (cnt == 0) {
                score += 3.0;
                unseenTopics.add(kp);
            } else if (cnt == 1) {
                score += 2.0;
                lightTopics.add(kp);
            } else if (cnt == 2) {
                score += 1.25;
                familiarTopics.add(kp);
            } else {
                score += 0.5;
                familiarTopics.add(kp);
            }
        }

        if (kpIds.isEmpty()) {
            score += 0.2;
        }

        String reason;
        if (!unseenTopics.isEmpty()) {
            reason = "可补足尚未练过的知识点：" + joinTop(unseenTopics, 3) + "。";
        } else if (!lightTopics.isEmpty()) {
            reason = "与当前已练内容衔接，适合继续巩固：" + joinTop(lightTopics, 3) + "。";
        } else if (!familiarTopics.isEmpty()) {
            reason = "适合作为相关知识点的进阶复练：" + joinTop(familiarTopics, 3) + "。";
        } else {
            reason = "适合作为下一步练习。";
        }

        return new ScoredLevel(
                level.getCode(),
                nullToDefault(level.getTitle(), level.getCode()),
                score,
                reason
        );
    }

    private Collection<String> safeStrings(Collection<String> raw) {
        if (raw == null || raw.isEmpty()) return List.of();

        List<String> out = new ArrayList<>();
        for (String s : raw) {
            if (s == null) continue;
            String t = s.trim();
            if (!t.isBlank()) {
                out.add(t);
            }
        }
        return out;
    }

    private String joinTop(List<String> items, int limit) {
        return items.stream().limit(limit).toList().stream().reduce((a, b) -> a + "、" + b).orElse("");
    }

    private String nullToDefault(String value, String fallback) {
        return (value == null || value.isBlank()) ? fallback : value;
    }

    private record ScoredLevel(
            String code,
            String title,
            double score,
            String reason
    ) {
    }
}
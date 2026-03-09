package dev.masterhesse.diglearn.ai.application.profile;

import dev.masterhesse.diglearn.sim.persistence.LevelEntity;
import dev.masterhesse.diglearn.sim.persistence.LevelPassRecordEntity;
import dev.masterhesse.diglearn.sim.persistence.LevelPassRecordRepository;
import dev.masterhesse.diglearn.sim.persistence.LevelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SimPracticeProfileService {

    private final LevelPassRecordRepository passRecordRepository;
    private final LevelRepository levelRepository;

    @Transactional(readOnly = true)
    public SimPracticeProfile buildProfile(String userId) {
        if (userId == null || userId.isBlank()) {
            return SimPracticeProfile.empty();
        }

        List<LevelPassRecordEntity> records = passRecordRepository.findAllByUserIdOrderByLastPassedAtDesc(userId.trim());
        if (records.isEmpty()) {
            return SimPracticeProfile.empty();
        }

        List<String> levelCodes = records.stream()
                .map(LevelPassRecordEntity::getLevelCode)
                .filter(Objects::nonNull)
                .distinct()
                .toList();

        Map<String, LevelEntity> levelMap = levelRepository.findAllByCodeIn(levelCodes)
                .stream()
                .collect(Collectors.toMap(LevelEntity::getCode, x -> x));

        Map<String, TopicAgg> topicAggMap = new LinkedHashMap<>();
        Set<String> passedLevelCodes = new LinkedHashSet<>();

        int totalPassCount = 0;

        for (LevelPassRecordEntity record : records) {
            if (record.getLevelCode() != null) {
                passedLevelCodes.add(record.getLevelCode());
            }
            totalPassCount += record.getPassCount();

            LevelEntity level = levelMap.get(record.getLevelCode());
            if (level == null) {
                continue;
            }

            Collection<String> kpIds = safeStrings(level.getKpIds());
            for (String kp : kpIds) {
                TopicAgg agg = topicAggMap.computeIfAbsent(kp, k -> new TopicAgg());
                agg.uniquePassedLevels += 1;
                agg.totalPassCount += record.getPassCount();
            }
        }

        LevelPassRecordEntity mostRecent = records.get(0);

        List<SimTopicMastery> strongTopics = topicAggMap.entrySet().stream()
                .map(e -> new SimTopicMastery(e.getKey(), e.getValue().uniquePassedLevels, e.getValue().totalPassCount))
                .sorted(Comparator
                        .comparingInt(SimTopicMastery::uniquePassedLevels).reversed()
                        .thenComparing(Comparator.comparingInt(SimTopicMastery::totalPassCount).reversed())
                        .thenComparing(SimTopicMastery::topic))
                .limit(5)
                .toList();

        List<SimTopicMastery> weakTopics = topicAggMap.entrySet().stream()
                .map(e -> new SimTopicMastery(e.getKey(), e.getValue().uniquePassedLevels, e.getValue().totalPassCount))
                .sorted(Comparator
                        .comparingInt(SimTopicMastery::uniquePassedLevels)
                        .thenComparingInt(SimTopicMastery::totalPassCount)
                        .thenComparing(SimTopicMastery::topic))
                .limit(5)
                .toList();

        Map<String, Integer> topicPassCounts = topicAggMap.entrySet().stream()
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        e -> e.getValue().totalPassCount,
                        (a, b) -> a,
                        LinkedHashMap::new
                ));

        List<String> recentlyPassedLevels = records.stream()
                .map(LevelPassRecordEntity::getLevelCode)
                .filter(Objects::nonNull)
                .distinct()
                .limit(10)
                .toList();

        return new SimPracticeProfile(
                passedLevelCodes.size(),
                totalPassCount,
                mostRecent.getLevelCode(),
                mostRecent.getLastPassedAt(),
                strongTopics,
                weakTopics,
                recentlyPassedLevels,
                passedLevelCodes,
                topicPassCounts
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

    private static class TopicAgg {
        int uniquePassedLevels;
        int totalPassCount;
    }
}
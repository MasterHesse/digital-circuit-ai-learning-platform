package dev.masterhesse.diglearn.ai.application.profile;

import java.time.Instant;
import java.util.*;

public record SimPracticeProfile(
        int passedLevelCount,
        int totalPassCount,
        String mostRecentlyPassedLevelCode,
        Instant mostRecentlyPassedAt,
        List<SimTopicMastery> strongTopics,
        List<SimTopicMastery> weakTopics,
        List<String> recentlyPassedLevels,
        Set<String> passedLevelCodes,
        Map<String, Integer> topicPassCounts
) {
    public SimPracticeProfile {
        strongTopics = Collections.unmodifiableList(new ArrayList<>(strongTopics == null ? List.of() : strongTopics));
        weakTopics = Collections.unmodifiableList(new ArrayList<>(weakTopics == null ? List.of() : weakTopics));
        recentlyPassedLevels = Collections.unmodifiableList(new ArrayList<>(recentlyPassedLevels == null ? List.of() : recentlyPassedLevels));
        passedLevelCodes = Collections.unmodifiableSet(new LinkedHashSet<>(passedLevelCodes == null ? Set.of() : passedLevelCodes));
        topicPassCounts = Collections.unmodifiableMap(new LinkedHashMap<>(topicPassCounts == null ? Map.of() : topicPassCounts));
    }

    public static SimPracticeProfile empty() {
        return new SimPracticeProfile(
                0,
                0,
                null,
                null,
                List.of(),
                List.of(),
                List.of(),
                Set.of(),
                Map.of()
        );
    }
}
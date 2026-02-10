package dev.masterhesse.diglearn.level.api;

import com.fasterxml.jackson.databind.JsonNode;

import java.util.List;
import java.util.Set;

/**
 * API models (response DTOs) for /api/levels
 * 集中放在一个文件里，避免 dto 目录碎片化。
 */
public final class LevelApiModels {
    private LevelApiModels() {}

    public record LevelSummary(
            String code,
            String title
    ) {}

    public record LevelDetail(
            String code,
            String title,
            String description,
            Set<String> allowedComponents,
            Set<String> kpIds,
            JsonNode templateCircuit,
            JsonNode devices,
            List<TestCase> testCases
    ) {}

    public record TestCase(
            Integer orderIndex,
            String name,
            List<TestStep> steps
    ) {}

    public record TestStep(
            Integer stepIndex,
            JsonNode inputs,
            JsonNode expected
    ) {}
}
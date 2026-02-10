package dev.masterhesse.diglearn.level.importing;

import com.fasterxml.jackson.databind.JsonNode;

import java.util.List;
import java.util.Set;

public final class LevelImportModels {
    private LevelImportModels() {}

    public record LevelFile(
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
            String name,
            Integer orderIndex,
            List<TestStep> steps
    ) {}

    public record TestStep(
            Integer stepIndex,
            JsonNode inputs,
            JsonNode expected
    ) {}

    public record ImportReport(
            int importedOrUpdated,
            int deleted,
            List<String> warnings
    ) {}
}
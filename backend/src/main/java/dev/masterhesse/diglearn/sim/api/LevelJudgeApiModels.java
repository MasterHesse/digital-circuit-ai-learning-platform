package dev.masterhesse.diglearn.sim.api;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public final class LevelJudgeApiModels {
    private LevelJudgeApiModels() {}

    public record JudgeRequest(
            String userId,
            @NotNull JsonNode circuit
    ) {}

    public record JudgeResponse(
            String levelCode,
            String userId,
            boolean passed,
            String message,
            Failure failure,
            PassRecord passRecord
    ) {}

    public record Failure(
            Integer testCaseOrderIndex,
            Integer stepIndex,
            JsonNode inputs,
            JsonNode expected,
            JsonNode actual
    ) {}

    public record PassRecord(
            String userId,
            String levelCode,
            Instant firstPassedAt,
            Instant lastPassedAt,
            int passCount
    ) {}

    public record PassStatusResponse(
            String levelCode,
            String userId,
            boolean passed,
            PassRecord passRecord
    ) {}
}
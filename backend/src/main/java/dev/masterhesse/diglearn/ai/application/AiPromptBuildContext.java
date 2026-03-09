package dev.masterhesse.diglearn.ai.application;

public record AiPromptBuildContext(
        String userId,
        String scene,
        String levelCode,
        String userMessage
) {
}
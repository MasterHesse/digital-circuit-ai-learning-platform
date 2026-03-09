package dev.masterhesse.diglearn.ai.provider;

public record LlmPrompt(
        String systemPrompt,
        String userPrompt
) {
}
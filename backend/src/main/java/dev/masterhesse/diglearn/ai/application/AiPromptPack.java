package dev.masterhesse.diglearn.ai.application;

import java.util.List;

public record AiPromptPack(
        String systemPrompt,
        List<String> usedContexts
) {
}
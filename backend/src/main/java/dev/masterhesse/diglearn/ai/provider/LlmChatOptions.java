package dev.masterhesse.diglearn.ai.provider;

import java.util.Map;

public record LlmChatOptions(
        String model,
        Boolean thinking,
        String thinkingEffort,
        Double temperature,
        Integer maxTokens,
        Map<String, Object> extraBody
) {

    public LlmChatOptions {
        extraBody = extraBody == null ? Map.of() : Map.copyOf(extraBody);
    }

    public LlmChatOptions(String model, Boolean thinking, Double temperature, Integer maxTokens) {
        this(model, thinking, null, temperature, maxTokens, Map.of());
    }

    public LlmChatOptions(String model, Boolean thinking, String thinkingEffort, Double temperature, Integer maxTokens) {
        this(model, thinking, thinkingEffort, temperature, maxTokens, Map.of());
    }

    public static LlmChatOptions defaults() {
        return new LlmChatOptions(null, false, null, null, null, Map.of());
    }

    public String resolvedThinkingEffort() {
        if (!Boolean.TRUE.equals(thinking)) {
            return null;
        }
        if (thinkingEffort == null || thinkingEffort.isBlank()) {
            return "medium";
        }
        return thinkingEffort.trim();
    }
}
package dev.masterhesse.diglearn.ai.provider;

public interface LlmGateway {

    record LlmPrompt(
            String systemPrompt,
            String userPrompt
    ) {
    }

    record LlmChatOptions(
            String model,
            boolean thinking,
            Integer thinkingBudget
    ) {
    }

    record LlmAnswer(
            String content,
            String reasoning,
            boolean fallback,
            String provider
    ) {
    }

    LlmAnswer chat(LlmPrompt prompt, LlmChatOptions options);
}
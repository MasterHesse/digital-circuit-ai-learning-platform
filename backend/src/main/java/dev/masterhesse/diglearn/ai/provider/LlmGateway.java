package dev.masterhesse.diglearn.ai.provider;

public interface LlmGateway {

    LlmAnswer chat(LlmPrompt prompt, LlmChatOptions options);
}
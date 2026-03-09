package dev.masterhesse.diglearn.ai.provider;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

@Service
@ConditionalOnProperty(prefix = "diglearn.ai", name = "mode", havingValue = "disabled")
public class DisabledLlmGateway implements LlmGateway {

    @Override
    public LlmAnswer chat(LlmPrompt prompt, LlmChatOptions options) {
        return new LlmAnswer(
                "AI 功能当前已禁用。",
                null,
                true,
                "disabled"
        );
    }
}
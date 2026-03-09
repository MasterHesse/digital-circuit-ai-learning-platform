package dev.masterhesse.diglearn.ai.provider;

import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "diglearn.ai", name = "mode", havingValue = "live")
public class SpringAiLlmGateway implements LlmGateway {

    private final ChatClient.Builder chatClientBuilder;

    @Override
    public LlmAnswer chat(LlmPrompt prompt, LlmChatOptions options) {
        String content = chatClientBuilder.build()
                .prompt()
                .system(prompt.systemPrompt())
                .user(prompt.userPrompt())
                .call()
                .content();

        return new LlmAnswer(
                content == null || content.isBlank() ? "模型返回了空内容。" : content,
                null,
                false,
                "spring-ai-openai"
        );
    }
}
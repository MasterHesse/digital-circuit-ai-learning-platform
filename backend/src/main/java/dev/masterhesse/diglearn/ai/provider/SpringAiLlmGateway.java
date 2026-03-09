package dev.masterhesse.diglearn.ai.provider;

import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.lang.reflect.Method;
import java.util.Map;

@Service
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "diglearn.ai", name = "mode", havingValue = "live")
public class SpringAiLlmGateway implements LlmGateway {

    private static final String PROVIDER_NAME = "spring-ai-openai";

    private final ChatClient.Builder chatClientBuilder;

    @Override
    public LlmAnswer chat(LlmPrompt prompt, LlmChatOptions options) {
        LlmChatOptions safeOptions = options == null ? LlmChatOptions.defaults() : options;

        String systemPrompt = enrichSystemPromptForThinking(prompt == null ? null : prompt.systemPrompt(), safeOptions);
        OpenAiChatOptions chatOptions = buildOpenAiChatOptions(safeOptions);

        ChatResponse response = chatClientBuilder.build()
                .prompt()
                .options(chatOptions)
                .system(systemPrompt == null ? "" : systemPrompt)
                .user(prompt == null || prompt.userPrompt() == null ? "" : prompt.userPrompt())
                .call()
                .chatResponse();

        String content = extractContent(response);
        String reasoning = extractReasoning(response);

        String safeContent = (content == null || content.isBlank())
                ? "模型返回了空内容。"
                : content;

        return new LlmAnswer(
                safeContent,
                reasoning,
                false,
                PROVIDER_NAME,
                blankToNull(safeOptions.model())
        );
    }

    private OpenAiChatOptions buildOpenAiChatOptions(LlmChatOptions options) {
        Object builder = OpenAiChatOptions.builder();

        if (hasText(options.model())) {
            invokeIfPresent(builder, "model", String.class, options.model().trim());
        }

        if (options.temperature() != null) {
            invokeIfPresent(builder, "temperature", Double.class, options.temperature());
        }

        if (options.maxTokens() != null) {
            boolean setAsCompletion = false;

            if (Boolean.TRUE.equals(options.thinking())) {
                setAsCompletion = invokeIfPresent(builder, "maxCompletionTokens", Integer.class, options.maxTokens());
            }

            if (!setAsCompletion) {
                invokeIfPresent(builder, "maxTokens", Integer.class, options.maxTokens());
            }
        }

        if (hasText(options.resolvedThinkingEffort())) {
            invokeIfPresent(builder, "reasoningEffort", String.class, options.resolvedThinkingEffort());
        }

        if (options.extraBody() != null && !options.extraBody().isEmpty()) {
            invokeIfPresent(builder, "extraBody", Map.class, options.extraBody());
        }

        Object built = invoke(builder, "build");
        return (OpenAiChatOptions) built;
    }

    private String enrichSystemPromptForThinking(String base, LlmChatOptions options) {
        if (!Boolean.TRUE.equals(options.thinking())) {
            return base;
        }

        String extra = """
                请先充分分析，再给出最终回答。
                如果底层模型支持 reasoning / thinking / reasoning effort，请启用中等强度推理。
                最终输出保持清晰、结构化、适合学生理解。
                除非上层明确要求，否则不要暴露“内部推理”“思维链”等措辞。
                """;

        if (base == null || base.isBlank()) {
            return extra.trim();
        }
        return base.trim() + "\n\n" + extra.trim();
    }

    private String extractContent(ChatResponse response) {
        AssistantMessage message = extractAssistantMessage(response);
        if (message == null) {
            return null;
        }

        String content = tryInvokeString(message, "getContent");
        if (!hasText(content)) {
            content = tryInvokeString(message, "getText");
        }

        return content == null ? null : content.trim();
    }

    private String extractReasoning(ChatResponse response) {
        AssistantMessage message = extractAssistantMessage(response);
        if (message == null || message.getMetadata() == null) {
            return null;
        }

        Object reasoning = message.getMetadata().get("reasoningContent");
        if (reasoning == null) {
            return null;
        }

        String s = String.valueOf(reasoning).trim();
        return s.isBlank() ? null : s;
    }

    private AssistantMessage extractAssistantMessage(ChatResponse response) {
        if (response == null) return null;
        if (response.getResult() == null) return null;
        if (response.getResult().getOutput() == null) return null;
        return response.getResult().getOutput();
    }

    private boolean invokeIfPresent(Object target, String methodName, Class<?> paramType, Object arg) {
        try {
            Method method = target.getClass().getMethod(methodName, paramType);
            method.invoke(target, arg);
            return true;
        } catch (NoSuchMethodException e) {
            return false;
        } catch (Exception e) {
            throw new IllegalStateException("Failed to invoke method: " + methodName, e);
        }
    }

    private Object invoke(Object target, String methodName) {
        try {
            Method method = target.getClass().getMethod(methodName);
            return method.invoke(target);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to invoke method: " + methodName, e);
        }
    }

    private String tryInvokeString(Object target, String methodName) {
        try {
            Method method = target.getClass().getMethod(methodName);
            Object value = method.invoke(target);
            return value == null ? null : String.valueOf(value);
        } catch (NoSuchMethodException e) {
            return null;
        } catch (Exception e) {
            throw new IllegalStateException("Failed to invoke method: " + methodName, e);
        }
    }

    private boolean hasText(String s) {
        return s != null && !s.isBlank();
    }

    private String blankToNull(String s) {
        return hasText(s) ? s.trim() : null;
    }
}
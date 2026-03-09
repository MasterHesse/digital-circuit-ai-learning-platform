package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.api.AiApiModels;
import dev.masterhesse.diglearn.ai.domain.AiMessageRole;
import dev.masterhesse.diglearn.ai.domain.AiScene;
import dev.masterhesse.diglearn.ai.domain.RetrievedChunk;
import dev.masterhesse.diglearn.ai.persistence.AiConversationEntity;
import dev.masterhesse.diglearn.ai.persistence.AiConversationMessageEntity;
import dev.masterhesse.diglearn.ai.provider.LlmAnswer;
import dev.masterhesse.diglearn.ai.provider.LlmChatOptions;
import dev.masterhesse.diglearn.ai.provider.LlmGateway;
import dev.masterhesse.diglearn.ai.provider.LlmPrompt;
import lombok.RequiredArgsConstructor;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.*;

@Service
@RequiredArgsConstructor
public class AiChatService {

    private static final int MAX_PROMPT_HISTORY_MESSAGES = 8;

    private final RagRetrievalService ragRetrievalService;
    private final LearningContextAssembler learningContextAssembler;
    private final PromptFactory promptFactory;
    private final LlmGateway llmGateway;
    private final Environment environment;
    private final AiConversationService aiConversationService;

    public AiApiModels.AiChatResponse chat(String userId, AiApiModels.AiChatRequest request) {
        AiScene scene = request.scene() == null ? AiScene.GENERAL_QA : request.scene();
        boolean useProfileContext = Boolean.TRUE.equals(request.useProfileContext());

        AiConversationEntity conversation = aiConversationService.requireOrCreateForChat(userId, request);

        List<AiConversationMessageEntity> history = aiConversationService.loadRecentMessages(
                userId,
                conversation.getConversationId(),
                MAX_PROMPT_HISTORY_MESSAGES
        );

        List<RetrievedChunk> chunks = ragRetrievalService.retrieve(request.message());

        LearningContextAssembler.LearningContextPayload learningContext =
                learningContextAssembler.build(userId, useProfileContext);

        String conversationContext = buildConversationContext(history);

        LlmPrompt prompt = new LlmPrompt(
                promptFactory.buildSystemPrompt(scene),
                promptFactory.buildUserPrompt(
                        request,
                        learningContext.promptText(),
                        conversationContext,
                        chunks
                )
        );

        String model = resolveModel(request.model());
        boolean thinking = resolveThinking(model, request.thinking());
        Integer maxTokens = resolveThinkingBudget(thinking, request.thinkingBudget());

        LlmChatOptions options = new LlmChatOptions(
                model,
                thinking,
                null,
                maxTokens
        );

        LlmAnswer answer = llmGateway.chat(prompt, options);

        List<AiApiModels.AiSourceRef> allSources = chunks.stream().map(this::toSourceRef).toList();
        List<AiApiModels.AiSourceRef> responseSources = Boolean.FALSE.equals(request.includeSources())
                ? List.of()
                : allSources;

        String reasoning = Boolean.TRUE.equals(request.showReasoning())
                ? blankToNull(answer.reasoning())
                : null;

        LinkedHashSet<String> usedContexts = new LinkedHashSet<>(learningContext.usedContexts());
        if (!history.isEmpty()) usedContexts.add("HISTORY");
        if (!chunks.isEmpty()) usedContexts.add("MATERIAL");

        List<String> usedContextList = new ArrayList<>(usedContexts);

        aiConversationService.appendExchange(
                userId,
                conversation.getConversationId(),
                request.message(),
                answer.content(),
                reasoning,
                model,
                answer.provider(),
                answer.fallback(),
                responseSources,
                usedContextList
        );

        return new AiApiModels.AiChatResponse(
                conversation.getConversationId(),
                answer.content(),
                reasoning,
                model,
                thinking,
                responseSources,
                List.of(
                        "继续追问一个更具体的问题",
                        "请求讲解相关前置知识点",
                        "请求生成下一步学习建议"
                ),
                answer.fallback(),
                answer.provider(),
                usedContextList
        );
    }

    private String buildConversationContext(List<AiConversationMessageEntity> history) {
        if (history == null || history.isEmpty()) {
            return "";
        }

        StringBuilder sb = new StringBuilder();
        for (AiConversationMessageEntity msg : history) {
            String speaker = msg.getRole() == AiMessageRole.USER ? "用户" : "助教";
            sb.append("[").append(speaker).append("]\n")
                    .append(msg.getContent() == null ? "" : msg.getContent().trim())
                    .append("\n\n");
        }
        return sb.toString().trim();
    }

    private String resolveModel(String requestedModel) {
        String model = StringUtils.hasText(requestedModel)
                ? requestedModel.trim()
                : getRequiredProperty("diglearn.ai.default-chat-model", "qwen-turbo");

        if (!allowedChatModels().contains(model)) {
            throw new IllegalArgumentException("Unsupported model: " + model);
        }
        return model;
    }

    private boolean resolveThinking(String model, Boolean requestedThinking) {
        boolean thinking = requestedThinking != null
                ? requestedThinking
                : Boolean.parseBoolean(getRequiredProperty("diglearn.ai.default-thinking", "false"));

        if (thinking && !reasoningCapableModels().contains(model)) {
            throw new IllegalArgumentException("Model does not support thinking mode: " + model);
        }
        return thinking;
    }

    /**
     * 兼容旧 API 字段命名：request.thinkingBudget()
     * 内部统一映射为 LlmChatOptions.maxTokens。
     */
    private Integer resolveThinkingBudget(boolean thinking, Integer requestedThinkingBudget) {
        if (!thinking) {
            return null;
        }

        int budget = requestedThinkingBudget != null
                ? requestedThinkingBudget
                : Integer.parseInt(getRequiredProperty("diglearn.ai.default-thinking-budget", "1024"));

        if (budget < 1) {
            throw new IllegalArgumentException("thinkingBudget must be >= 1");
        }
        return budget;
    }

    private Set<String> allowedChatModels() {
        return csvToSet(getRequiredProperty(
                "diglearn.ai.allowed-chat-models-csv",
                "qwen-turbo,qwen-plus,qwen-flash"
        ));
    }

    private Set<String> reasoningCapableModels() {
        return csvToSet(getRequiredProperty(
                "diglearn.ai.reasoning-capable-models-csv",
                "qwen-turbo,qwen-plus,qwen-flash"
        ));
    }

    private Set<String> csvToSet(String csv) {
        LinkedHashSet<String> values = new LinkedHashSet<>();
        Arrays.stream(csv.split(","))
                .map(String::trim)
                .filter(StringUtils::hasText)
                .forEach(values::add);
        return values;
    }

    private String getRequiredProperty(String key, String defaultValue) {
        return environment.getProperty(key, defaultValue);
    }

    private String blankToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private AiApiModels.AiSourceRef toSourceRef(RetrievedChunk chunk) {
        return new AiApiModels.AiSourceRef(
                chunk.id(),
                chunk.sourceType(),
                chunk.sourceId(),
                chunk.title(),
                chunk.snippet()
        );
    }
}
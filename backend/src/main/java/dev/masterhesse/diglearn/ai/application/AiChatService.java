package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.api.AiApiModels;
import dev.masterhesse.diglearn.ai.domain.AiScene;
import dev.masterhesse.diglearn.ai.domain.RetrievedChunk;
import dev.masterhesse.diglearn.ai.provider.LlmGateway;
import lombok.RequiredArgsConstructor;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AiChatService {

    private final RagRetrievalService ragRetrievalService;
    private final LearningContextAssembler learningContextAssembler;
    private final PromptFactory promptFactory;
    private final LlmGateway llmGateway;
    private final Environment environment;

    public AiApiModels.AiChatResponse chat(String userId, AiApiModels.AiChatRequest request) {
        AiScene scene = request.scene() == null ? AiScene.GENERAL_QA : request.scene();

        List<RetrievedChunk> chunks = ragRetrievalService.retrieve(request.message());
        String learningContext = learningContextAssembler.build(userId);

        LlmGateway.LlmPrompt prompt = new LlmGateway.LlmPrompt(
                promptFactory.buildSystemPrompt(scene),
                promptFactory.buildUserPrompt(request, learningContext, chunks)
        );

        String model = resolveModel(request.model());
        boolean thinking = resolveThinking(model, request.thinking());
        Integer thinkingBudget = resolveThinkingBudget(thinking, request.thinkingBudget());

        LlmGateway.LlmChatOptions options = new LlmGateway.LlmChatOptions(
                model,
                thinking,
                thinkingBudget
        );

        LlmGateway.LlmAnswer answer = llmGateway.chat(prompt, options);

        List<AiApiModels.AiSourceRef> sources = Boolean.FALSE.equals(request.includeSources())
                ? List.of()
                : chunks.stream().map(this::toSourceRef).toList();

        String reasoning = Boolean.TRUE.equals(request.showReasoning())
                ? blankToNull(answer.reasoning())
                : null;

        return new AiApiModels.AiChatResponse(
                normalizeConversationId(request.conversationId()),
                answer.content(),
                reasoning,
                model,
                thinking,
                sources,
                List.of(
                        "继续追问一个更具体的问题",
                        "请求讲解相关前置知识点",
                        "请求生成下一步学习建议"
                ),
                answer.fallback(),
                answer.provider()
        );
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

    private String normalizeConversationId(String conversationId) {
        if (!StringUtils.hasText(conversationId)) {
            return UUID.randomUUID().toString();
        }
        return conversationId.trim();
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
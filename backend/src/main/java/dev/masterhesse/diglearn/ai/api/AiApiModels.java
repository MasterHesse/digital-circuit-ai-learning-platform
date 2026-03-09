package dev.masterhesse.diglearn.ai.api;

import dev.masterhesse.diglearn.ai.domain.AiScene;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import java.util.List;

public final class AiApiModels {

    private AiApiModels() {
    }

    public record AiChatRequest(
            String conversationId,

            @NotBlank(message = "message must not be blank")
            String message,

            AiScene scene,
            Boolean includeSources,

            // 动态模型选择
            String model,            // qwen-turbo / qwen-plus / qwen-flash
            Boolean thinking,        // true / false
            @Min(value = 1, message = "thinkingBudget must be >= 1")
            Integer thinkingBudget,  // 可选
            Boolean showReasoning    // 是否把 reasoning 返回给前端
    ) {
    }

    public record AiSourceRef(
            String id,
            String sourceType,
            String sourceId,
            String title,
            String snippet
    ) {
    }

    public record AiChatResponse(
            String conversationId,
            String answer,
            String reasoning,
            String model,
            boolean thinking,
            List<AiSourceRef> sources,
            List<String> nextActions,
            boolean fallback,
            String provider
    ) {
    }

    public record ReindexResponse(
            String status,
            int requestedDocuments,
            int indexedDocuments,
            boolean vectorStoreAvailable,
            String message
    ) {
    }
}
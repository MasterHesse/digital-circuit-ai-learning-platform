package dev.masterhesse.diglearn.ai.api;

import dev.masterhesse.diglearn.ai.application.AiChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiChatService aiChatService;

    @PostMapping("/chat")
    public AiApiModels.AiChatResponse chat(
            @RequestHeader(name = "X-User-Id", required = false) String userId,
            @Valid @RequestBody AiApiModels.AiChatRequest request
    ) {
        return aiChatService.chat(userId, request);
    }
}
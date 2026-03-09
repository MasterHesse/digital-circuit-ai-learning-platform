package dev.masterhesse.diglearn.ai.api;

import dev.masterhesse.diglearn.ai.application.AiChatService;
import dev.masterhesse.diglearn.auth.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiChatService aiChatService;

    @PostMapping("/chat")
    public AiApiModels.AiChatResponse chat(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody AiApiModels.AiChatRequest request
    ) {
        String userId = principal == null ? null : principal.userId();
        return aiChatService.chat(userId, request);
    }
}
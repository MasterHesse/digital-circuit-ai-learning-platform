package dev.masterhesse.diglearn.ai.api;

import dev.masterhesse.diglearn.ai.application.AiConversationService;
import dev.masterhesse.diglearn.auth.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ai/conversations")
@RequiredArgsConstructor
public class AiConversationController {

    private final AiConversationService aiConversationService;

    @GetMapping
    public List<AiApiModels.AiConversationSummary> list(
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        String userId = principal == null ? null : principal.userId();
        return aiConversationService.listConversations(userId);
    }

    @PostMapping
    public AiApiModels.AiConversationSummary create(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody(required = false) AiApiModels.CreateConversationRequest request
    ) {
        String userId = principal == null ? null : principal.userId();
        return aiConversationService.createConversation(userId, request);
    }

    @GetMapping("/{conversationId}")
    public AiApiModels.AiConversationDetail detail(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable String conversationId
    ) {
        String userId = principal == null ? null : principal.userId();
        return aiConversationService.getConversationDetail(userId, conversationId);
    }

    @DeleteMapping("/{conversationId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable String conversationId
    ) {
        String userId = principal == null ? null : principal.userId();
        aiConversationService.deleteConversation(userId, conversationId);
    }
}
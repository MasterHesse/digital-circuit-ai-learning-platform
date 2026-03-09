package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.application.profile.SimPromptContextService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Order(300)
@RequiredArgsConstructor
public class SimPromptSectionContributor implements AiPromptSectionContributor {

    public static final String CONTEXT_KEY = "SIM_PRACTICE";

    private final SimPromptContextService simPromptContextService;

    @Override
    public boolean supports(AiPromptBuildContext context) {
        if (context == null) return false;
        return hasText(context.userId()) || hasText(context.levelCode());
    }

    @Override
    public AiPromptSection contribute(AiPromptBuildContext context) {
        String content = simPromptContextService.buildCombinedPrompt(
                context.userId(),
                context.levelCode()
        );

        if (!hasText(content)) {
            return null;
        }

        return new AiPromptSection(CONTEXT_KEY, content);
    }

    private boolean hasText(String s) {
        return s != null && !s.isBlank();
    }
}
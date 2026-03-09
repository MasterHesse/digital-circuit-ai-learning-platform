package dev.masterhesse.diglearn.ai.application;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AiPromptContextAssembler {

    private final List<AiPromptSectionContributor> contributors;

    public AiPromptPack assemble(String baseSystemPrompt, AiPromptBuildContext context) {
        StringBuilder sb = new StringBuilder();
        List<String> usedContexts = new ArrayList<>();

        if (baseSystemPrompt != null && !baseSystemPrompt.isBlank()) {
            sb.append(baseSystemPrompt.trim());
        }

        for (AiPromptSectionContributor contributor : contributors) {
            if (contributor == null || !contributor.supports(context)) {
                continue;
            }

            AiPromptSection section = contributor.contribute(context);
            if (section == null || section.content() == null || section.content().isBlank()) {
                continue;
            }

            if (sb.length() > 0) {
                sb.append("\n\n");
            }
            sb.append(section.content().trim());

            if (section.key() != null && !section.key().isBlank()) {
                usedContexts.add(section.key().trim());
            }
        }

        return new AiPromptPack(sb.toString(), List.copyOf(usedContexts));
    }
}
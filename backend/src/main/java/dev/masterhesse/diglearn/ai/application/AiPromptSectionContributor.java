package dev.masterhesse.diglearn.ai.application;

public interface AiPromptSectionContributor {

    boolean supports(AiPromptBuildContext context);

    AiPromptSection contribute(AiPromptBuildContext context);
}
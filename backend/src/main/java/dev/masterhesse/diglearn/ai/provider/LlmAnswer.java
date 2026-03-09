package dev.masterhesse.diglearn.ai.provider;

public record LlmAnswer(
        String content,
        String reasoning,
        boolean fallback,
        String provider,
        String model
) {

    public LlmAnswer(String content, String reasoning, boolean fallback, String provider) {
        this(content, reasoning, fallback, provider, null);
    }
}
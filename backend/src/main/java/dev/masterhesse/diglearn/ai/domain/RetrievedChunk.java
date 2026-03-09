package dev.masterhesse.diglearn.ai.domain;

import java.util.Map;

public record RetrievedChunk(
        String id,
        String text,
        Map<String, Object> metadata
) {

    public String sourceType() {
        return stringMeta("sourceType", "unknown");
    }

    public String sourceId() {
        return stringMeta("sourceId", id);
    }

    public String title() {
        return stringMeta("title", sourceId());
    }

    public String snippet() {
        if (text == null || text.isBlank()) {
            return "";
        }
        return text.length() <= 180 ? text : text.substring(0, 180) + "...";
    }

    private String stringMeta(String key, String defaultValue) {
        Object value = metadata == null ? null : metadata.get(key);
        return value == null ? defaultValue : String.valueOf(value);
    }
}
package dev.masterhesse.diglearn.ai.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "diglearn.ai")
public class AiProperties {

    private boolean enabled = true;
    private Mode mode = Mode.STUB;
    private Rag rag = new Rag();

    public enum Mode {
        LIVE,
        STUB,
        DISABLED
    }

    @Getter
    @Setter
    public static class Rag {
        private int topK = 6;
        private double similarityThreshold = 0.70;
        private String corpus = "learning";
        private boolean reindexOnStartup = false;
    }
}
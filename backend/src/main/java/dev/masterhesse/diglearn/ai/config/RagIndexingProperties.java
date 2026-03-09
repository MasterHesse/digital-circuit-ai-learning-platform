package dev.masterhesse.diglearn.ai.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "diglearn.ai.rag")
@Getter
@Setter
public class RagIndexingProperties {

    private Corpus corpus = new Corpus();
    private Indexing indexing = new Indexing();

    @Getter
    @Setter
    public static class Corpus {
        /**
         * seed | db
         */
        private String mode = "seed";
    }

    @Getter
    @Setter
    public static class Indexing {
        /**
         * 单 chunk 目标 token 数
         */
        private int chunkSize = 350;

        /**
         * 最小 chunk 字符数
         */
        private int minChunkSizeChars = 120;

        /**
         * 太短的 chunk 不入向量库
         */
        private int minChunkLengthToEmbed = 20;

        /**
         * 防止极端长文生成过多 chunk
         */
        private int maxNumChunks = 10_000;

        /**
         * 是否保留换行等分隔符
         */
        private boolean keepSeparator = true;
    }
}
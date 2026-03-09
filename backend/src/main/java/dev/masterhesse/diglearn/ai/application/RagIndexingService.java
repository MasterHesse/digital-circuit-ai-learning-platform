package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.api.AiApiModels;
import dev.masterhesse.diglearn.ai.config.RagIndexingProperties;
import dev.masterhesse.diglearn.ai.rag.TeachingCorpusProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.document.Document;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RagIndexingService {

    private static final String LEARNING_CORPUS = "learning";
    private static final int EMBEDDING_BATCH_SIZE = 10;

    private final ObjectProvider<VectorStore> vectorStoreProvider;
    private final TeachingCorpusProvider teachingCorpusProvider;
    private final RagIndexingProperties ragIndexingProperties;

    public AiApiModels.ReindexResponse reindexLearningCorpus() {
        List<Document> sourceDocuments = teachingCorpusProvider.loadLearningDocuments();
        List<Document> chunkDocuments = splitDocuments(sourceDocuments);

        VectorStore vectorStore = vectorStoreProvider.getIfAvailable();

        if (vectorStore == null) {
            return new AiApiModels.ReindexResponse(
                    "SKIPPED",
                    sourceDocuments.size(),
                    0,
                    false,
                    "当前未启用 Embedding / VectorStore，已完成语料加载与切块，但未写入向量库。"
            );
        }

        try {
            vectorStore.delete("corpus == '" + LEARNING_CORPUS + "'");
        } catch (Exception ignored) {
            // 首次导入 / 底层实现差异时，删除失败不阻断整体重建
        }

        if (!chunkDocuments.isEmpty()) {
            addDocumentsInBatches(vectorStore, chunkDocuments, EMBEDDING_BATCH_SIZE);
        }

        return new AiApiModels.ReindexResponse(
                "OK",
                sourceDocuments.size(),
                chunkDocuments.size(),
                true,
                "学习语料已完成重建索引。"
        );
    }

    private void addDocumentsInBatches(VectorStore vectorStore, List<Document> documents, int batchSize) {
        for (int start = 0; start < documents.size(); start += batchSize) {
            int end = Math.min(start + batchSize, documents.size());
            List<Document> batch = documents.subList(start, end);
            vectorStore.add(batch);
        }
    }

    private List<Document> splitDocuments(List<Document> sourceDocuments) {
        TokenTextSplitter splitter = new TokenTextSplitter(
                ragIndexingProperties.getIndexing().getChunkSize(),
                ragIndexingProperties.getIndexing().getMinChunkSizeChars(),
                ragIndexingProperties.getIndexing().getMinChunkLengthToEmbed(),
                ragIndexingProperties.getIndexing().getMaxNumChunks(),
                ragIndexingProperties.getIndexing().isKeepSeparator()
        );

        List<Document> chunkDocuments = new ArrayList<>();

        for (Document sourceDocument : sourceDocuments) {
            String rootDocId = StringUtils.hasText(sourceDocument.getId())
                    ? sourceDocument.getId()
                    : UUID.randomUUID().toString();

            Map<String, Object> sourceMetadata = sourceDocument.getMetadata() == null
                    ? Map.of()
                    : sourceDocument.getMetadata();

            List<String> chunkTexts = splitter.apply(List.of(sourceDocument)).stream()
                    .map(Document::getText)
                    .filter(StringUtils::hasText)
                    .map(String::trim)
                    .toList();

            for (int i = 0; i < chunkTexts.size(); i++) {
                Map<String, Object> metadata = new LinkedHashMap<>(sourceMetadata);
                metadata.put("rootDocId", rootDocId);
                metadata.put("chunkIndex", i);
                metadata.put("chunkCount", chunkTexts.size());

                String chunkDocumentId = stableChunkUuid(rootDocId, i);

                chunkDocuments.add(new Document(
                        chunkDocumentId,
                        chunkTexts.get(i),
                        metadata
                ));
            }
        }

        return chunkDocuments;
    }

    private String stableChunkUuid(String rootDocId, int chunkIndex) {
        String seed = rootDocId + "#chunk-" + chunkIndex;
        return UUID.nameUUIDFromBytes(seed.getBytes(StandardCharsets.UTF_8)).toString();
    }
}
package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.config.AiProperties;
import dev.masterhesse.diglearn.ai.domain.RetrievedChunk;
import dev.masterhesse.diglearn.ai.rag.TeachingCorpusProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class RagRetrievalService {

    private final ObjectProvider<VectorStore> vectorStoreProvider;
    private final TeachingCorpusProvider teachingCorpusProvider;
    private final AiProperties aiProperties;

    public List<RetrievedChunk> retrieve(String query) {
        VectorStore vectorStore = vectorStoreProvider.getIfAvailable();
        if (vectorStore != null) {
            List<Document> docs = vectorStore.similaritySearch(
                    SearchRequest.builder()
                            .query(query)
                            .topK(aiProperties.getRag().getTopK())
                            .similarityThreshold(aiProperties.getRag().getSimilarityThreshold())
                            .filterExpression("corpus == '" + aiProperties.getRag().getCorpus() + "'")
                            .build()
            );
            if (docs != null && !docs.isEmpty()) {
                return docs.stream().map(this::toChunk).toList();
            }
        }

        // fallback：stub / 无 vector store 时也能联调
        return fallbackSearch(query);
    }

    private List<RetrievedChunk> fallbackSearch(String query) {
        return teachingCorpusProvider.loadLearningDocuments().stream()
                .filter(doc -> matches(doc, query))
                .limit(aiProperties.getRag().getTopK())
                .map(this::toChunk)
                .toList();
    }

    private boolean matches(Document doc, String query) {
        String q = query == null ? "" : query.trim().toLowerCase(Locale.ROOT);
        if (q.isBlank()) {
            return true;
        }
        String text = (doc.getText() == null ? "" : doc.getText()).toLowerCase(Locale.ROOT);
        String title = String.valueOf(doc.getMetadata().getOrDefault("title", "")).toLowerCase(Locale.ROOT);
        return text.contains(q) || title.contains(q);
    }

    private RetrievedChunk toChunk(Document doc) {
        return new RetrievedChunk(doc.getId(), doc.getText(), doc.getMetadata());
    }
}
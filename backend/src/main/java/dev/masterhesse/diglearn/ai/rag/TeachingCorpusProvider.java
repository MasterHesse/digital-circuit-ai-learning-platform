package dev.masterhesse.diglearn.ai.rag;

import org.springframework.ai.document.Document;

import java.util.List;

public interface TeachingCorpusProvider {
    List<Document> loadLearningDocuments();
}
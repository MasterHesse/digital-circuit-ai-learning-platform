package dev.masterhesse.diglearn.ai.rag;

import dev.masterhesse.diglearn.material.domain.Material;
import dev.masterhesse.diglearn.material.domain.MaterialStatus;
import dev.masterhesse.diglearn.material.repository.MaterialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.document.Document;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
@ConditionalOnProperty(
        prefix = "diglearn.ai.rag.corpus",
        name = "mode",
        havingValue = "db"
)
public class DbTeachingCorpusProvider implements TeachingCorpusProvider {

    private final MaterialRepository materialRepository;

    @Override
    @Transactional(readOnly = true)
    public List<Document> loadLearningDocuments() {
        return materialRepository.findAllByStatus(
                        MaterialStatus.PUBLISHED,
                        Sort.by(Sort.Order.asc("code"))
                ).stream()
                .filter(this::hasEmbeddableBody)
                .map(this::toDocument)
                .toList();
    }

    private boolean hasEmbeddableBody(Material material) {
        return StringUtils.hasText(material.getBody());
    }

    private Document toDocument(Material material) {
        Map<String, Object> metadata = new LinkedHashMap<>();
        metadata.put("corpus", "learning");
        metadata.put("sourceType", "material");
        metadata.put("sourceId", material.getId().toString());
        metadata.put("materialId", material.getId().toString());
        metadata.put("code", material.getCode());
        metadata.put("title", material.getTitle());
        metadata.put("type", material.getType().name());
        metadata.put("status", material.getStatus().name());
        metadata.put("visibility", "student");

        if (StringUtils.hasText(material.getKpId())) {
            metadata.put("kpId", material.getKpId());
        }
        if (material.getPublishedAt() != null) {
            metadata.put("publishedAt", material.getPublishedAt().toString());
        }

        return new Document(
                "material-" + material.getId(),
                composeText(material),
                metadata
        );
    }

    /**
     * 如果你想“严格只索引正文”，改成：
     * return material.getBody().trim();
     */
    private String composeText(Material material) {
        List<String> parts = new ArrayList<>();

        if (StringUtils.hasText(material.getTitle())) {
            parts.add(material.getTitle().trim());
        }
        if (StringUtils.hasText(material.getSummary())) {
            parts.add(material.getSummary().trim());
        }
        if (StringUtils.hasText(material.getBody())) {
            parts.add(material.getBody().trim());
        }

        return String.join("\n\n", parts);
    }
}
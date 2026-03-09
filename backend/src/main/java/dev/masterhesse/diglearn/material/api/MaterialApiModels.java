package dev.masterhesse.diglearn.material.api;

import dev.masterhesse.diglearn.material.domain.CircuitChapter;
import dev.masterhesse.diglearn.material.domain.Material;
import dev.masterhesse.diglearn.material.domain.MaterialStatus;
import dev.masterhesse.diglearn.material.domain.MaterialType;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public class MaterialApiModels {

    public record UpsertMaterialRequest(
            String code,
            String title,
            MaterialType type,
            CircuitChapter chapter,
            String kpId,
            String summary,
            String body
    ) {
    }

    public record MaterialResponse(
            UUID id,
            String code,
            String title,
            MaterialType type,
            MaterialStatus status,
            CircuitChapter chapter,
            String kpId,
            String summary,
            String body,
            OffsetDateTime publishedAt,
            OffsetDateTime createdAt,
            OffsetDateTime updatedAt
    ) {
        public static MaterialResponse from(Material material) {
            return new MaterialResponse(
                    material.getId(),
                    material.getCode(),
                    material.getTitle(),
                    material.getType(),
                    material.getStatus(),
                    material.getChapter(),
                    material.getKpId(),
                    material.getSummary(),
                    material.getBody(),
                    material.getPublishedAt(),
                    material.getCreatedAt(),
                    material.getUpdatedAt()
            );
        }
    }

    public record ChapterMaterialsResponse(
            CircuitChapter chapter,
            String chapterName,
            List<MaterialResponse> materials
    ) {
    }
}
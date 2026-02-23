package dev.masterhesse.diglearn.question.application;

import dev.masterhesse.diglearn.knowledgepoint.KnowledgePointRepository;
import dev.masterhesse.diglearn.question.persistence.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Service
@RequiredArgsConstructor
public class TagKpMapService {

    private final TagService tagService;
    private final TagKpMapRepository tagKpMapRepository;

    // 直接复用现成的 Neo4j Repository
    private final KnowledgePointRepository kpRepo;

    public List<TagKpMapEntity> list(UUID tagId) {
        tagService.get(tagId);
        return tagKpMapRepository.findByIdTagId(tagId);
    }

    @Transactional(transactionManager = "neo4jTransactionManager", readOnly = true)
    public List<TagKpMapEntity> upsert(UUID tagId, List<UpsertItem> items) {
        TagEntity tag = tagService.get(tagId);

        if (items == null || items.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "mappings is required");
        }

        List<TagKpMapEntity> saved = new ArrayList<>();

        for (UpsertItem it : items) {
            String kpId = normalizeKpId(it.kpId());
            int weight = it.weight() == null ? 1 : it.weight();

            if (weight <= 0 || weight > 100) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "invalid weight for " + kpId);
            }

            // Neo4j kpId 校验：用你现有模块
            if (!kpRepo.existsById(kpId)) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "kpId not found in neo4j: " + kpId);
            }

            TagKpMapId id = new TagKpMapId(tagId, kpId);

            TagKpMapEntity e = tagKpMapRepository.findById(id)
                .orElseGet(() -> TagKpMapEntity.builder()
                    .id(id)
                    .tag(tag)
                    .build());

            e.setWeight(weight);
            saved.add(tagKpMapRepository.save(e));
        }

        return saved;
    }

    @Transactional
    public void delete(UUID tagId, String kpId) {
        tagService.get(tagId);

        String normalized = normalizeKpId(kpId);
        if (!tagKpMapRepository.existsById(new TagKpMapId(tagId, normalized))) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "mapping not found");
        }
        tagKpMapRepository.deleteById(new TagKpMapId(tagId, normalized));
    }

    private static String normalizeKpId(String s) {
        if (s == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "kpId is required");
        String t = s.trim();
        if (t.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "kpId is required");
        return t.toUpperCase();
    }

    public record UpsertItem(String kpId, Integer weight) {}
}
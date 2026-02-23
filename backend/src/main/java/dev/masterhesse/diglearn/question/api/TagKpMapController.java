package dev.masterhesse.diglearn.question.api;

import dev.masterhesse.diglearn.knowledgepoint.KnowledgePoint;
import dev.masterhesse.diglearn.knowledgepoint.KnowledgePointRepository;
import dev.masterhesse.diglearn.question.application.TagKpMapService;
import dev.masterhesse.diglearn.question.persistence.TagKpMapEntity;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/tags")
public class TagKpMapController {

    private final TagKpMapService tagKpMapService;
    private final KnowledgePointRepository kpRepo;

    @GetMapping("/{tagId}/kps")
    public List<TagKpMapResponse> list(
        @PathVariable UUID tagId,
        @RequestParam(name = "expand", defaultValue = "false") boolean expand
    ) {
        List<TagKpMapEntity> mappings = tagKpMapService.list(tagId);

        Map<String, KnowledgePoint> kpMap = Map.of();
        if (expand) {
            List<String> kpIds = mappings.stream().map(m -> m.getId().getKpId()).distinct().toList();
            kpMap = kpRepo.findAllById(kpIds).stream()
                .collect(Collectors.toMap(KnowledgePoint::getKpId, Function.identity()));
        }

        Map<String, KnowledgePoint> finalKpMap = kpMap;
        return mappings.stream()
            .map(m -> TagKpMapResponse.from(m, expand ? finalKpMap.get(m.getId().getKpId()) : null))
            .toList();
    }

    @PostMapping("/{tagId}/kps")
    public List<TagKpMapResponse> upsert(@PathVariable UUID tagId, @RequestBody TagKpUpsertRequest req) {
        var saved = tagKpMapService.upsert(tagId, req.mappings);
        return saved.stream().map(m -> TagKpMapResponse.from(m, null)).toList();
    }

    @DeleteMapping("/{tagId}/kps/{kpId}")
    public void delete(@PathVariable UUID tagId, @PathVariable String kpId) {
        tagKpMapService.delete(tagId, kpId);
    }

    @Data
    public static class TagKpUpsertRequest {
        public List<TagKpMapService.UpsertItem> mappings;
    }

    @Data
    public static class KnowledgePointMeta {
        public String kpId;
        public String title;
        public String category;
        public Integer difficulty;

        public static KnowledgePointMeta from(KnowledgePoint k) {
            if (k == null) return null;
            KnowledgePointMeta m = new KnowledgePointMeta();
            m.kpId = k.getKpId();
            m.title = k.getTitle();
            m.category = k.getCategory();
            m.difficulty = k.getDifficulty();
            return m;
        }
    }

    @Data
    public static class TagKpMapResponse {
        public UUID tagId;
        public String kpId;
        public int weight;
        public KnowledgePointMeta meta;

        public static TagKpMapResponse from(TagKpMapEntity e, KnowledgePoint kp) {
            TagKpMapResponse r = new TagKpMapResponse();
            r.tagId = e.getId().getTagId();
            r.kpId = e.getId().getKpId();
            r.weight = e.getWeight();
            r.meta = KnowledgePointMeta.from(kp);
            return r;
        }
    }
}
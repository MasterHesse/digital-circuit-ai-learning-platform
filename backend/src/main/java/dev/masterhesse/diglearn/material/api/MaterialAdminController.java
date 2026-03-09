package dev.masterhesse.diglearn.material.api;

import dev.masterhesse.diglearn.material.api.MaterialApiModels.ChapterMaterialsResponse;
import dev.masterhesse.diglearn.material.api.MaterialApiModels.MaterialResponse;
import dev.masterhesse.diglearn.material.api.MaterialApiModels.UpsertMaterialRequest;
import dev.masterhesse.diglearn.material.application.MaterialService;
import dev.masterhesse.diglearn.material.domain.CircuitChapter;
import dev.masterhesse.diglearn.material.domain.MaterialStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/materials")
@RequiredArgsConstructor
public class MaterialAdminController {

    private final MaterialService materialService;

    @GetMapping
    public List<MaterialResponse> list(
            @RequestParam(required = false) MaterialStatus status,
            @RequestParam(required = false) CircuitChapter chapter
    ) {
        return materialService.list(status, chapter).stream()
                .map(MaterialResponse::from)
                .toList();
    }

    @GetMapping("/grouped")
    public List<ChapterMaterialsResponse> listGrouped(
            @RequestParam(required = false) MaterialStatus status
    ) {
        return materialService.listGroupedByChapter(status);
    }

    @GetMapping("/{id}")
    public MaterialResponse get(@PathVariable UUID id) {
        return MaterialResponse.from(materialService.get(id));
    }

    @PostMapping
    public MaterialResponse create(@RequestBody UpsertMaterialRequest request) {
        return MaterialResponse.from(materialService.create(request));
    }

    @PutMapping("/{id}")
    public MaterialResponse update(@PathVariable UUID id, @RequestBody UpsertMaterialRequest request) {
        return MaterialResponse.from(materialService.update(id, request));
    }

    @PostMapping("/{id}/publish")
    public MaterialResponse publish(@PathVariable UUID id) {
        return MaterialResponse.from(materialService.publish(id));
    }

    @PostMapping("/{id}/archive")
    public MaterialResponse archive(@PathVariable UUID id) {
        return MaterialResponse.from(materialService.archive(id));
    }
}
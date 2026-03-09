package dev.masterhesse.diglearn.material.application;

import dev.masterhesse.diglearn.material.api.MaterialApiModels.ChapterMaterialsResponse;
import dev.masterhesse.diglearn.material.api.MaterialApiModels.MaterialResponse;
import dev.masterhesse.diglearn.material.api.MaterialApiModels.UpsertMaterialRequest;
import dev.masterhesse.diglearn.material.domain.CircuitChapter;
import dev.masterhesse.diglearn.material.domain.Material;
import dev.masterhesse.diglearn.material.domain.MaterialStatus;
import dev.masterhesse.diglearn.material.repository.MaterialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class MaterialService {

    private final MaterialRepository materialRepository;

    @Transactional(readOnly = true)
    public List<Material> list(MaterialStatus status, CircuitChapter chapter) {
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");

        if (status != null && chapter != null) {
            return materialRepository.findAllByStatusAndChapter(status, chapter, sort);
        }
        if (status != null) {
            return materialRepository.findAllByStatus(status, sort);
        }
        if (chapter != null) {
            return materialRepository.findAllByChapter(chapter, sort);
        }
        return materialRepository.findAll(sort);
    }

    @Transactional(readOnly = true)
    public List<ChapterMaterialsResponse> listGroupedByChapter(MaterialStatus status) {
        List<Material> materials = list(status, null);

        Map<CircuitChapter, List<MaterialResponse>> grouped = materials.stream()
                .map(MaterialResponse::from)
                .collect(Collectors.groupingBy(
                        MaterialResponse::chapter
                ));

        return CircuitChapter.orderedValues().stream()
                .map(chapter -> new ChapterMaterialsResponse(
                        chapter,
                        chapter.getDisplayName(),
                        grouped.getOrDefault(chapter, List.of())
                ))
                .toList();
    }

    @Transactional(readOnly = true)
    public Material get(UUID id) {
        return materialRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Material not found"));
    }

    public Material create(UpsertMaterialRequest request) {
        validateRequest(request);

        if (materialRepository.existsByCode(request.code())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Material code already exists");
        }

        Material material = new Material();
        apply(material, request);
        return materialRepository.save(material);
    }

    public Material update(UUID id, UpsertMaterialRequest request) {
        validateRequest(request);

        Material material = get(id);

        materialRepository.findByCode(request.code())
                .filter(found -> !found.getId().equals(id))
                .ifPresent(found -> {
                    throw new ResponseStatusException(HttpStatus.CONFLICT, "Material code already exists");
                });

        apply(material, request);
        return materialRepository.save(material);
    }

    public Material publish(UUID id) {
        Material material = get(id);
        material.publish();
        return materialRepository.save(material);
    }

    public Material archive(UUID id) {
        Material material = get(id);
        material.archive();
        return materialRepository.save(material);
    }

    private void apply(Material material, UpsertMaterialRequest request) {
        material.setCode(request.code().trim());
        material.setTitle(request.title().trim());
        material.setType(request.type());
        material.setChapter(request.chapter());
        material.setKpId(normalizeNullable(request.kpId()));
        material.setSummary(normalizeNullable(request.summary()));
        material.setBody(request.body().trim());
    }

    private void validateRequest(UpsertMaterialRequest request) {
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Request body is required");
        }
        if (request.code() == null || request.code().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "code is required");
        }
        if (request.title() == null || request.title().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "title is required");
        }
        if (request.type() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "type is required");
        }
        if (request.chapter() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "chapter is required");
        }
        if (request.body() == null || request.body().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "body is required");
        }

        if (request.kpId() != null && !request.kpId().isBlank()) {
            try {
                CircuitChapter kpChapter = CircuitChapter.fromKpId(request.kpId().trim());
                if (kpChapter != request.chapter()) {
                    throw new ResponseStatusException(
                            HttpStatus.BAD_REQUEST,
                            "kpId chapter does not match request.chapter"
                    );
                }
            } catch (IllegalArgumentException ex) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid kpId format");
            }
        }
    }

    private String normalizeNullable(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
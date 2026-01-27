package dev.masterhesse.diglearn.knowledgepoint;

import java.util.List;
import java.util.Map;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import dev.masterhesse.diglearn.knowledgepoint.dto.PrereqDto;;

@RestController
@RequestMapping("/api/kp")
@Validated
public class KnowledgePointController {
    private final KnowledgePointRepository repo;

    public KnowledgePointController(KnowledgePointRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/{kpId}")
    public ResponseEntity<KnowledgePoint> getById(@PathVariable String kpId) {
        return repo.findById(kpId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{kpId}/prereqs")
    public ResponseEntity<List<PrereqDto>> prereqs(
        @PathVariable String kpId, 
        @RequestParam(defaultValue = "2") @Min(1) @Max(3) Integer depth
    ) {
        if (!repo.existsById(kpId)) {
            return ResponseEntity.notFound().build();
        }
        List<PrereqDto> prereqs = repo.findPrereqChain(kpId, depth);
        return ResponseEntity.ok(prereqs);
    }
}


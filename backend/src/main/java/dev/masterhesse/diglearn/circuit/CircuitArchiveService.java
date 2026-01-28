package dev.masterhesse.diglearn.circuit;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import dev.masterhesse.diglearn.circuit.dto.CircuitSaveRequest;
import dev.masterhesse.diglearn.circuit.dto.CircuitResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CircuitArchiveService {
    
    private final CircuitArchiveRepository repo;
    private final ObjectMapper objectMapper;

    public CircuitResponse create(CircuitSaveRequest req) {
        CircuitArchiveEntity entity = CircuitArchiveEntity.builder()
            .name(req.name())
            .circuitJson(req.circuit().toString())
            .build();

        CircuitArchiveEntity saved = repo.save(entity);
        return toResponse(saved);
    }

    public CircuitResponse get(UUID id) {
        CircuitArchiveEntity entity = repo.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "circuit not found"+id));
        return toResponse(entity);
    }


    private CircuitResponse toResponse(CircuitArchiveEntity e) {
        try {
            JsonNode circuit = objectMapper.readTree(e.getCircuitJson());
            return new CircuitResponse(e.getId(), e.getName(), circuit, e.getCreatedAt(), e.getUpdatedAt());
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "stored circuitJson is invalid JSON", ex);
        }
    }
}

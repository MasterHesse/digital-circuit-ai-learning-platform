package dev.masterhesse.diglearn.circuit;

import dev.masterhesse.diglearn.circuit.dto.CircuitResponse;
import dev.masterhesse.diglearn.circuit.dto.CircuitSaveRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/circuits")
public class CircuitArchiveController {
    
    private final CircuitArchiveService service;

    @PostMapping
    public CircuitResponse create(@Valid @RequestBody CircuitSaveRequest req) {
        return service.create(req);
    }

    @GetMapping("/{id}")
    public CircuitResponse getCircuit(@PathVariable UUID id) {
        return service.get(id);
    }

}

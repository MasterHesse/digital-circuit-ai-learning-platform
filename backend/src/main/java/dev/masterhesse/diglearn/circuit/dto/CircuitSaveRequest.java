package dev.masterhesse.diglearn.circuit.dto;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CircuitSaveRequest(
    @NotBlank String name,
    @NotNull JsonNode circuit
) {
    
}

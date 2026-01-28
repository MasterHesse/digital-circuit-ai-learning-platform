package dev.masterhesse.diglearn.circuit.dto;

import com.fasterxml.jackson.databind.JsonNode;

import java.time.Instant;
import java.util.UUID;

public record CircuitResponse(
    UUID id,
    String name,
    JsonNode circuit,
    Instant createdAt,
    Instant updatedAt
) {
    
}

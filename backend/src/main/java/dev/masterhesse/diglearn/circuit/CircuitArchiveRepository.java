package dev.masterhesse.diglearn.circuit;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CircuitArchiveRepository extends JpaRepository<CircuitArchiveEntity, UUID> {
    
}

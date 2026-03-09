package dev.masterhesse.diglearn.material.repository;

import dev.masterhesse.diglearn.material.domain.CircuitChapter;
import dev.masterhesse.diglearn.material.domain.Material;
import dev.masterhesse.diglearn.material.domain.MaterialStatus;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MaterialRepository extends JpaRepository<Material, UUID> {

    Optional<Material> findByCode(String code);

    boolean existsByCode(String code);

    List<Material> findAllByStatus(MaterialStatus status, Sort sort);

    List<Material> findAllByChapter(CircuitChapter chapter, Sort sort);

    List<Material> findAllByStatusAndChapter(MaterialStatus status, CircuitChapter chapter, Sort sort);

    List<Material> findAllByKpId(String kpId, Sort sort);
}
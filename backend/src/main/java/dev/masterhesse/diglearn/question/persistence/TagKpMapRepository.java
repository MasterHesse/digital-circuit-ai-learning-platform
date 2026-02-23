package dev.masterhesse.diglearn.question.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TagKpMapRepository extends JpaRepository<TagKpMapEntity, TagKpMapId> {

    List<TagKpMapEntity> findByIdTagId(UUID tagId);

    boolean existsByIdTagIdAndIdKpId(UUID tagId, String kpId);

    void deleteByIdTagIdAndIdKpId(UUID tagId, String kpId);
}
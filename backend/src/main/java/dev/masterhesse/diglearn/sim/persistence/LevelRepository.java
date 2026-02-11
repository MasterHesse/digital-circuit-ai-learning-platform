package dev.masterhesse.diglearn.sim.persistence;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LevelRepository extends JpaRepository<LevelEntity, String> {

    List<LevelEntity> findAllByOrderByCodeAsc();

    @EntityGraph(attributePaths = {"allowedComponents", "kpIds", "testCases"})
    @Query("select l from LevelEntity l where l.code = :code")
    Optional<LevelEntity> findDetailByCode(@Param("code") String code);
}
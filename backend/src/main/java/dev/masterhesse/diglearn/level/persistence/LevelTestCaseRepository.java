package dev.masterhesse.diglearn.level.persistence;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface LevelTestCaseRepository extends JpaRepository<LevelTestCaseEntity, UUID> {

    // 只 fetch 一个 bag：steps（允许）
    @EntityGraph(attributePaths = {"steps"})
    @Query("select distinct tc from LevelTestCaseEntity tc where tc.level.code = :code")
    List<LevelTestCaseEntity> findAllByLevelCodeWithSteps(@Param("code") String code);
}
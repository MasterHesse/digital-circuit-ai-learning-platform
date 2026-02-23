package dev.masterhesse.diglearn.knowledgepoint;

import java.util.List;

import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;
import org.springframework.data.repository.query.Param;

import dev.masterhesse.diglearn.knowledgepoint.dto.PrereqDto;

public interface KnowledgePointRepository extends Neo4jRepository<KnowledgePoint, String> {

    @Query("""
    MATCH (start:KnowledgePoint {kpId: $kpId})
    MATCH p=(start)-[:PREREQ*1..3]->(pre:KnowledgePoint)
    WITH pre, min(length(p)) AS depth
    WHERE depth <= $depth
    RETURN pre.kpId AS kpId,
           pre.title AS title,
           pre.category AS category,
           pre.difficulty AS difficulty,
           depth AS depth
    ORDER BY depth ASC, kpId ASC
    """)
    List<PrereqDto> findPrereqChain(@Param("kpId") String kpId,
                                    @Param("depth") Integer depth);
}
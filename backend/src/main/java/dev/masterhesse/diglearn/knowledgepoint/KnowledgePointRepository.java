package dev.masterhesse.diglearn.knowledgepoint;

import java.util.List;
import java.util.Map;

import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;
import org.springframework.data.repository.query.Param;

import dev.masterhesse.diglearn.knowledgepoint.dto.PrereqDto;

public interface KnowledgePointRepository extends Neo4jRepository<KnowledgePoint, String> {
    
    @Query("""
    MATCH (start:KnowledgePoint {kpId: $kpId})
    WITH $depth AS maxDepth, start

    MATCH (start)-[:PREREQ]->(p1:KnowledgePoint)
    WITH maxDepth, collect(p1) AS layer1

    CALL {
        WITH layer1, maxDepth
        WITH layer1 WHERE maxDepth >= 2
        UNWIND layer1 AS n
        MATCH (n)-[:PREREQ]->(p2:KnowledgePoint)
        RETURN collect(DISTINCT p2) AS layer2
    }
    WITH maxDepth, layer1, coalesce(layer2, []) AS layer2

    CALL {
        WITH layer2, maxDepth
        WITH layer2 WHERE maxDepth >= 3
        UNWIND layer2 AS n
        MATCH (n)-[:PREREQ]->(p3:KnowledgePoint)
        RETURN collect(DISTINCT p3) AS layer3
    }
    WITH layer1, layer2, coalesce(layer3, []) AS layer3

    UNWIND (
        [x IN layer1 | {pre:x, depth:1}] +
        [x IN layer2 | {pre:x, depth:2}] +
        [x IN layer3 | {pre:x, depth:3}]
    ) AS row
    WITH row.pre AS pre, min(row.depth) AS depth
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

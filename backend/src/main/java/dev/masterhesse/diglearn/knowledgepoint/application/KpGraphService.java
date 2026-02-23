package dev.masterhesse.diglearn.knowledgepoint.application;

import lombok.RequiredArgsConstructor;
import org.neo4j.driver.Driver;
import org.neo4j.driver.Record;
import org.neo4j.driver.Session;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

import static org.neo4j.driver.Values.parameters;

@Service
@RequiredArgsConstructor
public class KpGraphService {

    private final Driver driver;

    public record KpMeta(String kpId, String title, String category, int difficulty) {}
    public record KpEdge(String from, String to) {}
    public record KpTraceResponse(List<String> rootKpIds, List<KpMeta> nodes, List<KpEdge> edges) {}

    // ✅ 新增：给“前置链”用的返回结构（PracticeService 会用到 depth / title / difficulty 等）
    public record PrereqRow(
            String  kpId,
            String  title,
            String  category,
            Integer difficulty,
            int     depth
    ) {}

    public List<KpMeta> listByCategory(String category) {
        try (Session session = driver.session()) {
            var res = session.run("""
                MATCH (k:KnowledgePoint {category: $category})
                RETURN k.kpId as kpId, k.title as title, k.category as category, k.difficulty as difficulty
                ORDER BY k.kpId
                """, parameters("category", category));

            List<KpMeta> out = new ArrayList<>();
            while (res.hasNext()) {
                Record r = res.next();
                out.add(new KpMeta(
                        r.get("kpId").asString(),
                        r.get("title").asString(),
                        r.get("category").asString(),
                        r.get("difficulty").asInt()
                ));
            }
            return out;
        }
    }

    /**
     * ✅ 新增：查询某个知识点的前置链（depth 1..3）
     *
     * 说明：
     * - Cypher 不用 *1..$depth（兼容性坑），而是固定 *1..3，
     *   再通过 WHERE depth <= $depth 控制返回层数。
     */
    public List<PrereqRow> listPrereqs(String kpId, int depth) {
        if (kpId == null || kpId.isBlank()) return List.of();
        int d = Math.max(1, Math.min(depth, 3));

        try (Session session = driver.session()) {
            var res = session.run("""
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
                """, parameters("kpId", kpId.trim(), "depth", d));

            List<PrereqRow> out = new ArrayList<>();
            while (res.hasNext()) {
                Record r = res.next();

                String title = r.get("title").isNull() ? null : r.get("title").asString();
                String category = r.get("category").isNull() ? null : r.get("category").asString();
                Integer difficulty = r.get("difficulty").isNull() ? null : r.get("difficulty").asInt();

                out.add(new PrereqRow(
                        r.get("kpId").asString(),
                        title,
                        category,
                        difficulty,
                        r.get("depth").asInt()
                ));
            }
            return out;
        }
    }

    public KpTraceResponse trace(List<String> rootKpIds, int depth) {
        if (rootKpIds == null || rootKpIds.isEmpty()) {
            return new KpTraceResponse(List.of(), List.of(), List.of());
        }
        int d = Math.max(0, Math.min(depth, 10)); // demo 安全阈值

        try (Session session = driver.session()) {
            var result = session.run("""
                MATCH (root:KnowledgePoint)
                WHERE root.kpId IN $kpIds

                // ⚠️ 稳定写法：固定 *0..10，再用 length(p) <= $depth 过滤
                OPTIONAL MATCH p=(root)-[:PREREQ*0..10]->(n:KnowledgePoint)
                WHERE length(p) <= $depth

                WITH collect(distinct n) as ns, collect(p) as ps, collect(distinct root.kpId) as roots

                WITH ns, roots,
                     reduce(es = [], pp IN ps |
                        es + [rel IN relationships(pp) | {from: startNode(rel).kpId, to: endNode(rel).kpId}]
                     ) as rawEdges

                RETURN
                  roots as roots,
                  [x IN ns | {kpId:x.kpId, title:x.title, category:x.category, difficulty:x.difficulty}] as nodes,
                  apoc.coll.toSet(rawEdges) as edges
                """, parameters("kpIds", rootKpIds, "depth", d));

            if (!result.hasNext()) {
                return new KpTraceResponse(rootKpIds, List.of(), List.of());
            }

            Record r = result.next();
            List<String> roots = r.get("roots").asList(v -> v.asString());

            List<KpMeta> nodes = r.get("nodes").asList(v -> {
                var m = v.asMap();
                return new KpMeta(
                        (String) m.get("kpId"),
                        (String) m.get("title"),
                        (String) m.get("category"),
                        ((Number) m.get("difficulty")).intValue()
                );
            });

            List<KpEdge> edges = r.get("edges").asList(v -> {
                var m = v.asMap();
                return new KpEdge((String) m.get("from"), (String) m.get("to"));
            });

            return new KpTraceResponse(roots, nodes, edges);
        }
    }

    /*
     * 如果你 Neo4j 没装 APOC，把 trace() 里的 Cypher 换成下面这个，然后在 Java 里手动去重 edges：
     *
     * MATCH (root:KnowledgePoint)
     * WHERE root.kpId IN $kpIds
     * OPTIONAL MATCH p=(root)-[:PREREQ*0..10]->(n:KnowledgePoint)
     * WHERE length(p) <= $depth
     * WITH collect(distinct n) as ns, collect(p) as ps, collect(distinct root.kpId) as roots
     * UNWIND ps as pp
     * UNWIND relationships(pp) as rel
     * WITH ns, roots, collect(distinct {from: startNode(rel).kpId, to: endNode(rel).kpId}) as edges
     * RETURN roots, [x IN ns | {...}] as nodes, edges
     */
}
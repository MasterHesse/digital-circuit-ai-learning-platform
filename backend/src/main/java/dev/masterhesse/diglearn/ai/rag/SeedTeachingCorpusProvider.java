package dev.masterhesse.diglearn.ai.rag;

import org.springframework.ai.document.Document;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Component
@ConditionalOnProperty(
        prefix = "diglearn.ai.rag.corpus",
        name = "mode",
        havingValue = "seed",
        matchIfMissing = true
)
public class SeedTeachingCorpusProvider implements TeachingCorpusProvider {

    @Override
    public List<Document> loadLearningDocuments() {
        return List.of(
                new Document(
                        "kp-DC-BOOL-03",
                        """
                        德摩根定律有两条常见形式：
                        1. (A + B)' = A'B'
                        2. (AB)' = A' + B'
                        
                        在数字电路中，德摩根定律常用于门级变换，例如把 AND/OR 结构改写为仅使用 NAND 或 NOR 的实现。
                        它的前置通常是布尔代数基本定律和基本逻辑门。
                        """,
                        Map.of(
                                "corpus", "learning",
                                "sourceType", "kp_note",
                                "sourceId", "DC-BOOL-03",
                                "title", "德摩根定律与门级变换",
                                "kpId", "DC-BOOL-03",
                                "visibility", "student"
                        )
                ),
                new Document(
                        "kp-DC-COMB-02",
                        """
                        多路选择器 MUX 的核心作用是：在多个输入中，根据选择信号选出一路作为输出。
                        常见用途包括：
                        - 数据通路选择
                        - 逻辑函数实现
                        - 与 ALU、寄存器、总线结构联动
                        
                        学习 MUX 前，最好已经掌握组合逻辑设计流程。
                        """,
                        Map.of(
                                "corpus", "learning",
                                "sourceType", "kp_note",
                                "sourceId", "DC-COMB-02",
                                "title", "多路选择器 MUX",
                                "kpId", "DC-COMB-02",
                                "visibility", "student"
                        )
                ),
                new Document(
                        "kp-DC-SEQ-03",
                        """
                        D 触发器在时钟有效边沿采样输入 D，并把结果保存到输出 Q。
                        多个 D 触发器可以组成寄存器。
                        它是理解同步时序逻辑、寄存器、移位寄存器、计数器和 FSM 的关键基础。
                        """,
                        Map.of(
                                "corpus", "learning",
                                "sourceType", "kp_note",
                                "sourceId", "DC-SEQ-03",
                                "title", "D 触发器与寄存器",
                                "kpId", "DC-SEQ-03",
                                "visibility", "student"
                        )
                )
        );
    }
}
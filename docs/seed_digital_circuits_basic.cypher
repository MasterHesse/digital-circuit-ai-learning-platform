// seed_digital_circuits_basic.cypher
// 数字电路（基础课程）知识点与前置关系
// 可重复执行：MERGE 幂等

// 如果你想清空旧测试数据（仅 KnowledgePoint），取消注释：
// MATCH (k:KnowledgePoint) DETACH DELETE k;

// 1) 约束：kpId 唯一
CREATE CONSTRAINT knowledgepoint_kpId IF NOT EXISTS
FOR (k:KnowledgePoint)
REQUIRE k.kpId IS UNIQUE;

// 2) 创建知识点节点
UNWIND [
  // ===== FND: 基础 =====
  {kpId:'DC-FND-01', title:'数字电路导论（模拟 vs 数字）', category:'FND', difficulty:1},
  {kpId:'DC-FND-02', title:'数制与进制转换（二/八/十/十六）', category:'FND', difficulty:1},
  {kpId:'DC-FND-03', title:'有符号数与补码（溢出）', category:'FND', difficulty:1},
  {kpId:'DC-FND-04', title:'真值表与逻辑表达式入门', category:'FND', difficulty:1},

  // ===== BOOL: 布尔代数与化简 =====
  {kpId:'DC-BOOL-01', title:'基本逻辑门（AND/OR/NOT/XOR 等）', category:'BOOL', difficulty:1},
  {kpId:'DC-BOOL-02', title:'布尔代数基本定律', category:'BOOL', difficulty:1},
  {kpId:'DC-BOOL-03', title:'德摩根定律与门级变换（NAND/NOR 实现）', category:'BOOL', difficulty:1},
  {kpId:'DC-BOOL-04', title:'最小项/最大项与 SOP/POS 规范形式', category:'BOOL', difficulty:2},
  {kpId:'DC-BOOL-05', title:'卡诺图化简（2~4 变量）', category:'BOOL', difficulty:2},
  {kpId:'DC-BOOL-06', title:'组合逻辑毛刺与冒险（Hazard）', category:'BOOL', difficulty:2},

  // ===== COMB: 组合逻辑模块 =====
  {kpId:'DC-COMB-01', title:'组合逻辑设计流程（规格→真值表→化简→实现）', category:'COMB', difficulty:2},
  {kpId:'DC-COMB-02', title:'多路选择器 MUX（实现与应用）', category:'COMB', difficulty:1},
  {kpId:'DC-COMB-03', title:'译码器 Decoder（含使能与地址译码）', category:'COMB', difficulty:1},
  {kpId:'DC-COMB-04', title:'编码器 Encoder（含优先编码）', category:'COMB', difficulty:1},
  {kpId:'DC-COMB-05', title:'三态缓冲与总线（Tri-state & Bus）', category:'COMB', difficulty:2},

  // ===== ARITH: 算术电路 =====
  {kpId:'DC-ARITH-01', title:'半加器与全加器', category:'ARITH', difficulty:1},
  {kpId:'DC-ARITH-02', title:'多位加法器（串行进位、溢出）', category:'ARITH', difficulty:2},
  {kpId:'DC-ARITH-03', title:'减法与补码加法', category:'ARITH', difficulty:2},
  {kpId:'DC-ARITH-04', title:'比较器（相等/大小）', category:'ARITH', difficulty:2},
  {kpId:'DC-ARITH-05', title:'简单 ALU（加/减/与/或/异或）', category:'ARITH', difficulty:2},

  // ===== SEQ/TIM: 时序逻辑与时序概念 =====
  {kpId:'DC-SEQ-01', title:'时钟与同步设计基本思想', category:'SEQ', difficulty:1},
  {kpId:'DC-SEQ-02', title:'锁存器与触发器（Latch vs FF）', category:'SEQ', difficulty:2},
  {kpId:'DC-SEQ-03', title:'D 触发器与寄存器', category:'SEQ', difficulty:2},
  {kpId:'DC-SEQ-04', title:'常见触发器 SR/JK/T（认识与转换）', category:'SEQ', difficulty:2},
  {kpId:'DC-TIM-01', title:'传播延迟、建立/保持时间（Timing）', category:'TIM', difficulty:2},
  {kpId:'DC-TIM-02', title:'亚稳态与同步器（Metastability）', category:'TIM', difficulty:2},
  {kpId:'DC-SEQ-05', title:'移位寄存器（串并转换）', category:'SEQ', difficulty:2},
  {kpId:'DC-SEQ-06', title:'计数器（异步/同步、模 N）', category:'SEQ', difficulty:2},

  // ===== FSM / MEM =====
  {kpId:'DC-FSM-01', title:'有限状态机 FSM（Moore/Mealy，状态图→电路）', category:'FSM', difficulty:3},
  {kpId:'DC-MEM-01', title:'存储器基础（ROM/RAM，地址/数据，读写概念）', category:'MEM', difficulty:2}
] AS row
MERGE (k:KnowledgePoint {kpId: row.kpId})
SET k.title = row.title,
    k.category = row.category,
    k.difficulty = row.difficulty;

// 3) 创建前置关系：主题 -> 它的前置
UNWIND [
  // FND
  {from:'DC-FND-02', to:'DC-FND-01'},
  {from:'DC-FND-03', to:'DC-FND-02'},
  {from:'DC-FND-04', to:'DC-FND-02'},

  // BOOL
  {from:'DC-BOOL-01', to:'DC-FND-04'},
  {from:'DC-BOOL-02', to:'DC-BOOL-01'},
  {from:'DC-BOOL-03', to:'DC-BOOL-02'},
  {from:'DC-BOOL-04', to:'DC-BOOL-02'},
  {from:'DC-BOOL-05', to:'DC-BOOL-04'},

  // COMB
  {from:'DC-COMB-01', to:'DC-BOOL-05'},
  {from:'DC-COMB-02', to:'DC-COMB-01'},
  {from:'DC-COMB-03', to:'DC-COMB-01'},
  {from:'DC-COMB-04', to:'DC-COMB-01'},
  {from:'DC-COMB-05', to:'DC-COMB-01'},
  {from:'DC-BOOL-06', to:'DC-COMB-01'},

  // ARITH
  {from:'DC-ARITH-01', to:'DC-FND-02'},
  {from:'DC-ARITH-01', to:'DC-BOOL-01'},
  {from:'DC-ARITH-02', to:'DC-ARITH-01'},
  {from:'DC-ARITH-02', to:'DC-FND-03'},
  {from:'DC-ARITH-03', to:'DC-FND-03'},
  {from:'DC-ARITH-03', to:'DC-ARITH-01'},
  {from:'DC-ARITH-04', to:'DC-COMB-01'},
  {from:'DC-ARITH-04', to:'DC-FND-02'},
  {from:'DC-ARITH-05', to:'DC-ARITH-02'},
  {from:'DC-ARITH-05', to:'DC-COMB-02'},

  // SEQ / TIM
  {from:'DC-SEQ-01', to:'DC-COMB-01'},
  {from:'DC-SEQ-02', to:'DC-SEQ-01'},
  {from:'DC-SEQ-03', to:'DC-SEQ-02'},
  {from:'DC-SEQ-04', to:'DC-SEQ-02'},
  {from:'DC-TIM-01', to:'DC-SEQ-03'},
  {from:'DC-TIM-02', to:'DC-TIM-01'},
  {from:'DC-SEQ-05', to:'DC-SEQ-03'},
  {from:'DC-SEQ-06', to:'DC-SEQ-03'},

  // FSM / MEM
  {from:'DC-FSM-01', to:'DC-SEQ-03'},
  {from:'DC-FSM-01', to:'DC-COMB-01'},
  {from:'DC-MEM-01', to:'DC-COMB-03'},
  {from:'DC-MEM-01', to:'DC-SEQ-03'}
] AS rel
MATCH (a:KnowledgePoint {kpId: rel.from})
MATCH (b:KnowledgePoint {kpId: rel.to})
MERGE (a)-[:PREREQ]->(b);
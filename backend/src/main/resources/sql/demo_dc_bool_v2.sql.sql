BEGIN;

/* =========================================================
   demo_dc_bool_v2.sql  —  DC-BOOL 完整 Demo 题库脚本
   ---------------------------------------------------------
   【question_pool 字段设计意图】
   CHAPTER    = 章节核心练习（每KP 3题，用于课内章节检测）
   SUPPLEMENT = 课外巩固补充题（每KP ≥5题，推荐系统主力题源）
   EXAM       = 综合模拟考试题（本 Demo 暂未使用）

   【推荐策略说明（Service 层待实现）】
   当用户在 KP-X 的 CHAPTER 题中答错时，推荐逻辑应：
     1. 优先推送：同 KP 的 SUPPLEMENT 题（精确巩固）
        → WHERE question_pool = 'SUPPLEMENT'
              AND 题目的 tag 包含 kp:DC-KP-X
     2. 次要推送：跨 KP 标签匹配的 SUPPLEMENT 题（知识溯源）
        → WHERE question_pool = 'SUPPLEMENT'
              AND 题目的 tag 包含前置 KP（weight=70 的跨KP标签）
   这样避免了"答错 A 只推 B/C"的章节内循环问题。
   ========================================================= */

-- =========================================================
-- SECTION 1: Cleanup（按 FK 依赖顺序）
-- =========================================================
DELETE FROM question_attempts
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-%');

DELETE FROM user_question_state
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-%');

DELETE FROM question_tag_map
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-%');

DELETE FROM questions WHERE stem LIKE '[DEMO-%';

DELETE FROM tag_kp_map
WHERE tag_id IN (
  SELECT id FROM tags
  WHERE  name LIKE 'kp:DC-BOOL-%' OR name LIKE 'kp:DC-FND-%'
      OR name LIKE 'topic:BOOL-%' OR name LIKE 'topic:FND-%'
);
DELETE FROM tags
WHERE  name LIKE 'kp:DC-BOOL-%' OR name LIKE 'kp:DC-FND-%'
    OR name LIKE 'topic:BOOL-%' OR name LIKE 'topic:FND-%';


-- =========================================================
-- SECTION 2: Tags（20 个：10 KP 精确标签 + 10 主题标签）
-- =========================================================
INSERT INTO tags (id, name, description) VALUES
  -- BOOL KP tags
  ('10000000-0000-0000-0000-000000000001'::uuid, 'kp:DC-BOOL-01', 'KP: 基本逻辑门（AND/OR/NOT/XOR/NAND/NOR）'),
  ('10000000-0000-0000-0000-000000000002'::uuid, 'kp:DC-BOOL-02', 'KP: 布尔代数基本定律'),
  ('10000000-0000-0000-0000-000000000003'::uuid, 'kp:DC-BOOL-03', 'KP: 德摩根定律与门级变换（NAND/NOR实现）'),
  ('10000000-0000-0000-0000-000000000004'::uuid, 'kp:DC-BOOL-04', 'KP: 最小项/最大项与SOP/POS规范形式'),
  ('10000000-0000-0000-0000-000000000005'::uuid, 'kp:DC-BOOL-05', 'KP: 卡诺图化简（2~4变量）'),
  ('10000000-0000-0000-0000-000000000006'::uuid, 'kp:DC-BOOL-06', 'KP: 组合逻辑毛刺与冒险（Hazard）'),
  -- FND KP tags（前置知识点，用于跨KP溯源推荐）
  ('10000000-0000-0000-0000-000000000011'::uuid, 'kp:DC-FND-01',  'KP: 数字电路导论（模拟vs数字）'),
  ('10000000-0000-0000-0000-000000000012'::uuid, 'kp:DC-FND-02',  'KP: 数制与进制转换（二/八/十/十六）'),
  ('10000000-0000-0000-0000-000000000013'::uuid, 'kp:DC-FND-03',  'KP: 有符号数与补码（溢出）'),
  ('10000000-0000-0000-0000-000000000014'::uuid, 'kp:DC-FND-04',  'KP: 真值表与逻辑表达式入门'),
  -- BOOL topic tags（宏观主题分类）
  ('20000000-0000-0000-0000-000000000001'::uuid, 'topic:BOOL-gates',    '基本逻辑门'),
  ('20000000-0000-0000-0000-000000000002'::uuid, 'topic:BOOL-laws',     '布尔代数定律'),
  ('20000000-0000-0000-0000-000000000003'::uuid, 'topic:BOOL-demorgan', '德摩根定理与门级变换'),
  ('20000000-0000-0000-0000-000000000004'::uuid, 'topic:BOOL-sop-pos',  'SOP/POS 规范形式'),
  ('20000000-0000-0000-0000-000000000005'::uuid, 'topic:BOOL-kmap',     '卡诺图化简'),
  ('20000000-0000-0000-0000-000000000006'::uuid, 'topic:BOOL-hazard',   '组合逻辑冒险'),
  -- FND topic tags
  ('20000000-0000-0000-0000-000000000011'::uuid, 'topic:FND-intro',      '数字电路基础概念'),
  ('20000000-0000-0000-0000-000000000012'::uuid, 'topic:FND-numbase',    '数制与进制转换'),
  ('20000000-0000-0000-0000-000000000013'::uuid, 'topic:FND-signed',     '有符号数与补码'),
  ('20000000-0000-0000-0000-000000000014'::uuid, 'topic:FND-truthtable', '真值表与逻辑表达式');


-- =========================================================
-- SECTION 3: tag_kp_map（20 条）
-- =========================================================
INSERT INTO tag_kp_map (tag_id, kp_id, weight) VALUES
  ('10000000-0000-0000-0000-000000000001'::uuid, 'DC-BOOL-01', 100),
  ('10000000-0000-0000-0000-000000000002'::uuid, 'DC-BOOL-02', 100),
  ('10000000-0000-0000-0000-000000000003'::uuid, 'DC-BOOL-03', 100),
  ('10000000-0000-0000-0000-000000000004'::uuid, 'DC-BOOL-04', 100),
  ('10000000-0000-0000-0000-000000000005'::uuid, 'DC-BOOL-05', 100),
  ('10000000-0000-0000-0000-000000000006'::uuid, 'DC-BOOL-06', 100),
  ('10000000-0000-0000-0000-000000000011'::uuid, 'DC-FND-01',  100),
  ('10000000-0000-0000-0000-000000000012'::uuid, 'DC-FND-02',  100),
  ('10000000-0000-0000-0000-000000000013'::uuid, 'DC-FND-03',  100),
  ('10000000-0000-0000-0000-000000000014'::uuid, 'DC-FND-04',  100),
  ('20000000-0000-0000-0000-000000000001'::uuid, 'DC-BOOL-01',  50),
  ('20000000-0000-0000-0000-000000000002'::uuid, 'DC-BOOL-02',  50),
  ('20000000-0000-0000-0000-000000000003'::uuid, 'DC-BOOL-03',  50),
  ('20000000-0000-0000-0000-000000000004'::uuid, 'DC-BOOL-04',  50),
  ('20000000-0000-0000-0000-000000000005'::uuid, 'DC-BOOL-05',  50),
  ('20000000-0000-0000-0000-000000000006'::uuid, 'DC-BOOL-06',  50),
  ('20000000-0000-0000-0000-000000000011'::uuid, 'DC-FND-01',   50),
  ('20000000-0000-0000-0000-000000000012'::uuid, 'DC-FND-02',   50),
  ('20000000-0000-0000-0000-000000000013'::uuid, 'DC-FND-03',   50),
  ('20000000-0000-0000-0000-000000000014'::uuid, 'DC-FND-04',   50);


-- =========================================================
-- SECTION 4: CHAPTER 题（18 道，question_pool='CHAPTER'）
-- DC-BOOL-01~06，每 KP 3 道，用于课内章节练习
-- =========================================================
WITH q (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool) AS (
  VALUES
  -- ---- DC-BOOL-01 ----
  ('30000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) AND门：A=1, B=0 时输出为？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'AND门只有所有输入均为1时才输出1；A=1,B=0 → 输出0。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) XOR门：A=1, B=1 时输出为？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'XOR（异或）：相同输入为0，不同输入为1；A=B=1 → 输出0。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) 哪种门等价于 NOT(A OR B)？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"NAND"},{"id":"B","text":"NOR"},{"id":"C","text":"XOR"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'NOR = NOT(A+B)，即对 OR 结果取反。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-BOOL-02 ----
  ('30000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 幂等律：A + A = ?', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"0"},{"id":"C","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '幂等律：A+A=A；A·A=A。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 恒等律：A · 1 = ?', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"0"},{"id":"C","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '恒等律：A·1=A；A+0=A。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000006'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 吸收律：A + A·B = ?', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"A·B"},{"id":"C","text":"B"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '吸收律：A+AB=A；A(A+B)=A。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-BOOL-03 ----
  ('30000000-0000-0000-0000-000000000007'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) 德摩根定律：NOT(A·B) 等价于？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"NOT(A) · NOT(B)"},{"id":"B","text":"NOT(A) + NOT(B)"},{"id":"C","text":"A + B"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'NOT(A·B) = NOT(A)+NOT(B)：乘积取反变为各项取反后相或。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000008'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) 仅用 NAND 门实现 NOT A，做法是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A NAND A"},{"id":"B","text":"A NAND 0"},{"id":"C","text":"A NAND 1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'NAND(A,A) = NOT(A·A) = NOT(A)，同输入 NAND 即取反。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000009'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) NOT(A + B) 对应哪种逻辑门？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"NAND"},{"id":"B","text":"NOR"},{"id":"C","text":"XNOR"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'NOR = NOT(A+B)，即 OR 结果取反。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-BOOL-04 ----
  ('30000000-0000-0000-0000-000000000010'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) 2变量F(A,B)在(0,1)和(1,1)时F=1，最小项编号集合是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"m(0,1)"},{"id":"B","text":"m(1,3)"},{"id":"C","text":"m(2,3)"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '(0,1)→二进制01=1→m1；(1,1)→二进制11=3→m3；故为 m(1,3)。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000011'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) 标准SOP中，每个"积项"（最小项）是指？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"若干变量相或"},{"id":"B","text":"所有n个变量相与（各取原变量或反变量）"},{"id":"C","text":"单个变量的取反"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'SOP的每一项是最小项：所有n个变量相 AND，各变量可取原变量或反变量。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000012'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) F = ΠM(0,2) 表示 F 在哪些编号上为0？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"编号0和2"},{"id":"B","text":"除0和2以外的所有编号"},{"id":"C","text":"无法判断"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '最大项编号集合即F=0的最小项编号，ΠM(0,2)表示在输入0和2处F=0。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-BOOL-05 ----
  ('30000000-0000-0000-0000-000000000013'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 3变量卡诺图中，合法的分组大小是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"任意2的整数倍"},{"id":"B","text":"2的幂次（1,2,4,8）"},{"id":"C","text":"任意连续格数"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '卡诺图分组必须是2的幂次（1,2,4,8,…），才能消去相应数量的变量。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000014'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 卡诺图化简的主要目标是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"减少实现所需的门数量与级数"},{"id":"B","text":"减少输入变量个数"},{"id":"C","text":"减少真值表行数"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '化简通过合并最小项得到最简 SOP，减少门数/级数，降低实现成本。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000015'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 卡诺图的边界格是否可以"环绕"相邻？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"是，左右/上下边界均相邻可环绕"},{"id":"B","text":"否，边界格不相邻"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '卡诺图采用格雷码排列，行列边界均可环绕，形成"圆柱面"拓扑相邻关系。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-BOOL-06 ----
  ('30000000-0000-0000-0000-000000000016'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) 组合逻辑"毛刺/冒险"的典型成因是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"不同路径门延迟不一致导致信号到达时间差"},{"id":"B","text":"输入电平本身不稳定"},{"id":"C","text":"使用了XOR门"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '毛刺/冒险根本原因：多条信号路径延迟不同，切换瞬间输出出现意外脉冲。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000017'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) "静态1冒险"（Static-1 Hazard）是指？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"输出本应稳定为1，却短暂下降至0"},{"id":"B","text":"输出本应稳定为0，却短暂升至1"},{"id":"C","text":"输出在0和1之间反复振荡"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '静态1冒险：稳态为1，因路径延迟不一致出现短暂0脉冲。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('30000000-0000-0000-0000-000000000018'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) 消除SOP实现中静态1冒险的常用方法是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"增加覆盖相邻最小项的冗余共识项（Consensus Term）"},{"id":"B","text":"将所有AND门改为XOR门"},{"id":"C","text":"降低工作频率"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '添加冗余共识项使相邻分组产生重叠覆盖，消除切换时的毛刺。',
   'PUBLISHED','zh-CN','CHAPTER')
)
INSERT INTO questions (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, created_at, updated_at)
SELECT id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, now(), now()
FROM q;


-- =========================================================
-- SECTION 5: SUPPLEMENT 题（39 道，question_pool='SUPPLEMENT'）
-- DC-FND-01~04（9道前置支撑）+ DC-BOOL-01~06 各5道（30道）
-- =========================================================
WITH q (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool) AS (
  VALUES

  /* ---- DC-FND-01（2道）---- */
  ('41000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 与模拟信号相比，数字信号最突出的优势是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"抗噪声能力强，便于存储与处理"},{"id":"B","text":"频率响应范围更宽"},{"id":"C","text":"精度可以无限提高"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '数字信号取值离散，具有强抗噪声特性，易于数字化存储和处理。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('41000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) "正逻辑"约定中，逻辑"1"对应？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"高电平"},{"id":"B","text":"低电平"},{"id":"C","text":"零电压"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '正逻辑：高电平=1，低电平=0；负逻辑则相反。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-FND-02（3道）---- */
  ('42000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 二进制数 1010(2) 对应的十进制数是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"8"},{"id":"B","text":"10"},{"id":"C","text":"12"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '1×2³+0×2²+1×2¹+0×2⁰ = 8+0+2+0 = 10。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('42000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 十进制数 13 转换为4位二进制是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"1011"},{"id":"B","text":"1101"},{"id":"C","text":"1110"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '13 = 8+4+1 = 2³+2²+2⁰，得 1101(2)。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('42000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 十六进制 0x1F 转为十进制是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"25"},{"id":"B","text":"31"},{"id":"C","text":"47"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '0x1F = 1×16 + 15 = 31。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-FND-03（2道）---- */
  ('43000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 8位补码 11111111 代表的十进制数是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"-1"},{"id":"B","text":"127"},{"id":"C","text":"255"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '最高位1表示负数；按位取反加1：00000000+1=1，故值为-1。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('43000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 4位补码能表示的最小负数是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"-7"},{"id":"B","text":"-8"},{"id":"C","text":"-15"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '4位补码范围[-8,+7]，最小值-8对应编码1000（最高位权重为-2³=-8）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-FND-04（2道）---- */
  ('44000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 三变量逻辑函数的完整真值表有几行？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"6"},{"id":"B","text":"8"},{"id":"C","text":"16"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'n变量有2ⁿ种组合，3变量共2³=8行。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('44000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 函数 F=A·B 的真值表中，F=1 的输入组合有几个？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"1个"},{"id":"B","text":"2个"},{"id":"C","text":"3个"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'AND运算仅在A=1且B=1时输出1，2变量真值表（4行）中只有1行满足。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-BOOL-01 补充（5道）---- */
  ('31000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) NAND门：A=1, B=1 时，输出为？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'NAND = NOT(A·B) = NOT(1·1) = NOT(1) = 0。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('31000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) 三输入AND门：A=1, B=1, C=1 时，输出为？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"},{"id":"C","text":"取决于具体型号"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'AND门所有输入均为1时输出1，与输入个数无关。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('31000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) 哪种门的功能是"相同输入时输出0，不同输入时输出1"？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"OR"},{"id":"B","text":"XOR"},{"id":"C","text":"XNOR"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'XOR（异或）：同0异1。XNOR（同或）：同1异0，与XOR相反。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('31000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) 仅用一种门即可实现任意布尔函数，该类门称"通用门"。以下哪种是通用门？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"AND"},{"id":"B","text":"OR"},{"id":"C","text":"NAND"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   'NAND 和 NOR 均是通用门，可单独实现任意布尔函数（由德摩根定律与逻辑完备性保证）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('31000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-01) NOR门：A=0, B=0 时，输出为？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'NOR = NOT(A+B) = NOT(0+0) = NOT(0) = 1。NOR门仅在所有输入为0时输出1。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-BOOL-02 补充（5道）---- */
  ('32000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 互补律：A · A'' = ?（A''表示NOT A）', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"A"},{"id":"C","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '互补律：A·A''=0；对应地，A+A''=1。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('32000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 零元律：A + 1 = ?', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"1"},{"id":"C","text":"0"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '零元律（OR）：A+1=1；零元律（AND）：A·0=0。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('32000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 双重否定律：NOT(NOT(A)) = ?', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"0"},{"id":"C","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '双重否定律：两次取反恢复原值，NOT(NOT(A))=A。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('32000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 分配律：A · (B + C) = ?', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A·B + A·C"},{"id":"B","text":"A + B·C"},{"id":"C","text":"A·B·C"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '布尔分配律与普通代数一致：A(B+C)=AB+AC。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('32000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-02) 化简：A + A''·B = ?（A''=NOT A）', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A + B"},{"id":"B","text":"A"},{"id":"C","text":"A·B"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'A+A''B = (A+A'')(A+B) = 1·(A+B) = A+B（推广吸收律，利用分配律展开可得）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-BOOL-03 补充（5道）---- */
  ('33000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) 三变量德摩根：NOT(A·B·C) = ?', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"NOT A · NOT B · NOT C"},{"id":"B","text":"NOT A + NOT B + NOT C"},{"id":"C","text":"A + B + C"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '德摩根推广：多变量乘积取反，等于各变量取反后相或。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('33000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) 化简 NOT(A'' + B'')（A''=NOT A，B''=NOT B）= ?', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A·B"},{"id":"B","text":"A+B"},{"id":"C","text":"A''·B''"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '德摩根：NOT(A''+B'') = NOT(A'')·NOT(B'') = A·B。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('33000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) 仅使用NAND门实现 OR(A,B)，正确连接方式是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A、B直接接一个NAND门"},{"id":"B","text":"先NAND(A,A)和NAND(B,B)各自取非，再将两结果接入NAND"},{"id":"C","text":"三个NAND门串联"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'OR(A,B)=NOT(NOT A·NOT B)=NAND(NOT A,NOT B)；NOT A=NAND(A,A)，NOT B=NAND(B,B)，故选B。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('33000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) 气泡推进（Bubble Pushing）：NAND(A,B) 等价于？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"OR(NOT A, NOT B)"},{"id":"B","text":"NOR(A, B)"},{"id":"C","text":"AND(NOT A, NOT B)"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '由德摩根：NAND(A,B)=NOT(A·B)=NOT A+NOT B=OR(NOT A,NOT B)，即"输入取反的OR门"。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('33000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-03) NOR(A,B) 经德摩根变换等价于？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"NOT A · NOT B"},{"id":"B","text":"NOT A + NOT B"},{"id":"C","text":"A · B"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '由德摩根：NOR(A,B)=NOT(A+B)=NOT A·NOT B，即"输入取反的AND门"。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-BOOL-04 补充（5道）---- */
  ('34000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) n=3变量的布尔函数共有多少个最小项？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"6"},{"id":"B","text":"8"},{"id":"C","text":"16"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'n变量有2ⁿ种输入组合，对应2ⁿ个最小项。3变量共2³=8个。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('34000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) 三变量(A高位,B,C低位)最小项m₅对应的标准积项是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A''BC"},{"id":"B","text":"AB''C"},{"id":"C","text":"ABC''"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '5的三位二进制为101，A=1,B=0,C=1，对应积项 A·B''·C。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('34000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) 标准SOP（最小项之和）中，每个最小项须满足？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"包含全部n个变量，各取原变量或反变量之一"},{"id":"B","text":"只包含值为1的变量"},{"id":"C","text":"至少包含一个变量"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '最小项要求全部n个变量都出现，每个变量根据输入取值选原变量或反变量。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('34000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) 两变量A(高位),B(低位)，F=Σm(0,3)的标准SOP是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A''B + AB''"},{"id":"B","text":"A''B'' + AB"},{"id":"C","text":"A''B'' + A''B"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'm0=(A=0,B=0)→A''B''；m3=(A=1,B=1)→AB；SOP = A''B''+AB（即XNOR）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('34000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-04) 两变量A(高位),B(低位)，F=ΠM(1,2)，F=1的输入组合是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"(0,0) 和 (1,1)"},{"id":"B","text":"(0,1) 和 (1,0)"},{"id":"C","text":"(0,0) 和 (0,1)"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'M1→(0,1)处F=0；M2→(1,0)处F=0；余下 m0=(0,0) 和 m3=(1,1) 处F=1。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-BOOL-05 补充（5道）---- */
  ('35000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 2变量卡诺图共有几个格（cell）？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"2"},{"id":"B","text":"4"},{"id":"C","text":"8"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '2变量有2²=4种输入组合，卡诺图共4个格，排列为2×2。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('35000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 4变量卡诺图中，一个含4格的分组，化简后积项包含几个文字？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"1"},{"id":"B","text":"2"},{"id":"C","text":"4"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '含2ᵏ格的分组消去k个变量：4=2²，消去2个变量，剩余4-2=2个文字。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('35000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 卡诺图中无关项（Don''t-care，标记X）的处理方式是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"必须当作1"},{"id":"B","text":"必须当作0"},{"id":"C","text":"可视化简需要灵活指定为0或1"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   '无关项代表不关心的输出，化简时可任意指定0或1以获得更大/更优分组。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('35000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 2变量卡诺图中，F=Σm(0,1,2,3)，化简结果为？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A+B"},{"id":"B","text":"A·B"},{"id":"C","text":"1（常数）"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   '所有格均为1，整个卡诺图合为一组，函数恒为1（常数真）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('35000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-05) 关于"本质主蕴含项（Essential Prime Implicant）"，描述正确的是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"覆盖最小项数最多的主蕴含项"},{"id":"B","text":"包含至少一个被它唯一覆盖的最小项（其他主蕴含项均不覆盖）"},{"id":"C","text":"只含1个格的最小分组"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '本质主蕴含项覆盖了某个"独占"最小项（无其他PI可覆盖），必须被选入最终表达式。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-BOOL-06 补充（5道）---- */
  ('36000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) 静态0冒险（Static-0 Hazard）是指？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"输出本应稳定为0，却出现短暂的1脉冲"},{"id":"B","text":"输出本应稳定为1，却出现短暂的0脉冲"},{"id":"C","text":"输出在0和1之间持续振荡"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '静态0冒险：稳态为0，因延迟不一致短暂出现1脉冲（与静态1冒险方向相反）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('36000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) 动态冒险（Dynamic Hazard）的特征是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"输出在本该跳变一次时发生多次意外翻转（如0→1→0→1）"},{"id":"B","text":"输出完全不发生跳变"},{"id":"C","text":"仅在时序逻辑中出现"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '动态冒险：信号本应只跳变一次，却因多级延迟不一致出现多次翻转。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('36000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) 在卡诺图中，如何判断SOP实现存在静态1冒险？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"两个相邻的1格未被任何共同（或重叠）的分组覆盖"},{"id":"B","text":"某分组格数不是2的幂"},{"id":"C","text":"存在无关项（Don''t-care）"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '若逻辑相邻（仅一位不同）的两个1格分属不同分组且无重叠，切换该位时会出现静态1冒险。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('36000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) F=AB+A''C，B=C=1时改变A会产生毛刺。消除毛刺应添加的冗余项是？', 3::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"BC"},{"id":"B","text":"AC"},{"id":"C","text":"A''B"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '添加共识项BC后F=AB+A''C+BC。当B=C=1时BC=1恒成立，无论A如何变化输出均稳定为1。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('36000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-BOOL] (DC-BOOL-06) POS（和之积）形式的表达式可能存在哪种静态冒险？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"静态1冒险"},{"id":"B","text":"静态0冒险"},{"id":"C","text":"POS不会产生冒险"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'SOP（AND-OR）实现易产生静态1冒险；POS（OR-AND）实现易产生静态0冒险。',
   'PUBLISHED','zh-CN','SUPPLEMENT')
)
INSERT INTO questions (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, created_at, updated_at)
SELECT id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, now(), now()
FROM q;


-- =========================================================
-- SECTION 6: question_tag_map（共 129 条）
-- 标签权重策略：
--   主 KP 标签  weight=100（精确知识点，推荐首选匹配）
--   跨 KP 标签  weight=70 （关联前置KP，支撑知识溯源）
--   主题标签    weight=50 （宏观分类，推荐兜底匹配）
-- =========================================================

-- ---- 6a: FND 补充题标签（20条）----
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('41000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('41000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('41000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('41000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('42000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('42000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('42000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('42000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('42000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('42000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  -- 43-001 跨KP→FND-02：补码计算需要进制基础
  ('43000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('43000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000012'::uuid, 70,now()),
  ('43000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  ('43000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('43000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  ('44000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('44000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now()),
  -- 44-002 跨KP→BOOL-01：F=A·B 直接涉及 AND 门概念
  ('44000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('44000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000001'::uuid, 70,now()),
  ('44000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now());


-- ---- 6b: BOOL 章节题标签（18道×2标签=36条）----
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('30000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000006'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000006'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000007'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000007'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000008'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000008'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000009'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000009'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000010'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000010'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000011'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000011'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000012'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000012'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000013'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000013'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000014'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000014'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000015'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000015'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000016'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000016'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000017'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000017'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now()),
  ('30000000-0000-0000-0000-000000000018'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('30000000-0000-0000-0000-000000000018'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now());


-- ---- 6c: BOOL-01 补充题标签（13条）----
-- 31-001/004/005 跨KP→BOOL-03：NAND/NOR/通用门均直接涉及德摩根
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('31000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('31000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000003'::uuid, 70,now()),
  ('31000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now()),
  ('31000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('31000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now()),
  ('31000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('31000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now()),
  ('31000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('31000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000003'::uuid, 70,now()),
  ('31000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now()),
  ('31000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000001'::uuid,100,now()),
  ('31000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000003'::uuid, 70,now()),
  ('31000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000001'::uuid, 50,now());


-- ---- 6d: BOOL-02 补充题标签（10条）----
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('32000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('32000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now()),
  ('32000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('32000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now()),
  ('32000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('32000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now()),
  ('32000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('32000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now()),
  ('32000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000002'::uuid,100,now()),
  ('32000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000002'::uuid, 50,now());


-- ---- 6e: BOOL-03 补充题标签（13条）----
-- 33-003/004/005 跨KP→BOOL-01：涉及 NAND/NOR 具体门操作
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('33000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('33000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now()),
  ('33000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('33000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now()),
  ('33000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('33000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000001'::uuid, 70,now()),
  ('33000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now()),
  ('33000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('33000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000001'::uuid, 70,now()),
  ('33000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now()),
  ('33000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000003'::uuid,100,now()),
  ('33000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000001'::uuid, 70,now()),
  ('33000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000003'::uuid, 50,now());


-- ---- 6f: BOOL-04 补充题标签（11条）----
-- 34-001 跨KP→FND-04：最小项数量本质是真值表行数问题
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('34000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('34000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000014'::uuid, 70,now()),
  ('34000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now()),
  ('34000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('34000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now()),
  ('34000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('34000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now()),
  ('34000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('34000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now()),
  ('34000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000004'::uuid,100,now()),
  ('34000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000004'::uuid, 50,now());


-- ---- 6g: BOOL-05 补充题标签（13条）----
-- 35-003/004/005 跨KP→BOOL-04：无关项/本质PI均以最小项概念为基础
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('35000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('35000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now()),
  ('35000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('35000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now()),
  ('35000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('35000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000004'::uuid, 70,now()),
  ('35000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now()),
  ('35000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('35000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000004'::uuid, 70,now()),
  ('35000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now()),
  ('35000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000005'::uuid,100,now()),
  ('35000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000004'::uuid, 70,now()),
  ('35000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000005'::uuid, 50,now());


-- ---- 6h: BOOL-06 补充题标签（13条）----
-- 36-003 跨KP→BOOL-05：K-map识别冒险
-- 36-004 跨KP→BOOL-02：共识定理属于布尔代数定律
-- 36-005 跨KP→BOOL-04：POS冒险需理解最大项/POS概念
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('36000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('36000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now()),
  ('36000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('36000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now()),
  ('36000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('36000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000005'::uuid, 70,now()),
  ('36000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now()),
  ('36000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('36000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000002'::uuid, 70,now()),
  ('36000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now()),
  ('36000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000006'::uuid,100,now()),
  ('36000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000004'::uuid, 70,now()),
  ('36000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000006'::uuid, 50,now());

/* =========================================================
   执行完毕后可运行以下验证查询：

   -- 按 pool 统计题目数量
   SELECT question_pool, COUNT(*) AS cnt
   FROM questions WHERE stem LIKE '[DEMO-%'
   GROUP BY question_pool;

   -- 按 KP 统计各池题目数量
   SELECT t.name AS kp, q.question_pool, COUNT(*) AS cnt
   FROM question_tag_map qtm
   JOIN tags t ON t.id = qtm.tag_id
   JOIN questions q ON q.id = qtm.question_id
   WHERE t.name LIKE 'kp:DC-%' AND q.stem LIKE '[DEMO-%'
   GROUP BY t.name, q.question_pool
   ORDER BY t.name, q.question_pool;

   -- 验证跨KP多标签（补充题应有 ≥2 个KP标签的题目）
   SELECT q.stem, COUNT(DISTINCT t.name) AS kp_tag_count
   FROM question_tag_map qtm
   JOIN tags t ON t.id = qtm.tag_id AND t.name LIKE 'kp:%'
   JOIN questions q ON q.id = qtm.question_id
   WHERE q.question_pool = 'SUPPLEMENT' AND q.stem LIKE '[DEMO-%'
   GROUP BY q.id, q.stem
   HAVING COUNT(DISTINCT t.name) >= 2
   ORDER BY kp_tag_count DESC;
   ========================================================= */

COMMIT;
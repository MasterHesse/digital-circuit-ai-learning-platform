BEGIN;

-- 0) 清理旧 demo（按依赖顺序删，避免外键问题）
DELETE FROM question_attempts
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-BOOL]%' );

DELETE FROM user_question_state
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-BOOL]%' );

DELETE FROM question_tag_map
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-BOOL]%' );

DELETE FROM questions
WHERE stem LIKE '[DEMO-BOOL]%';

-- 删 tag 映射（只删我们这次 demo 的 tag）
DELETE FROM tag_kp_map
WHERE tag_id IN (
  SELECT id FROM tags
  WHERE name LIKE 'kp:DC-BOOL-%' OR name LIKE 'topic:BOOL-%'
);

DELETE FROM tags
WHERE name LIKE 'kp:DC-BOOL-%' OR name LIKE 'topic:BOOL-%';


-- 1) 插入 tags（6个KP标签 + 6个主题标签）
WITH tag_seed(id, name, description) AS (
  VALUES
    ('10000000-0000-0000-0000-000000000001'::uuid, 'kp:DC-BOOL-01', 'KP marker: DC-BOOL-01'),
    ('10000000-0000-0000-0000-000000000002'::uuid, 'kp:DC-BOOL-02', 'KP marker: DC-BOOL-02'),
    ('10000000-0000-0000-0000-000000000003'::uuid, 'kp:DC-BOOL-03', 'KP marker: DC-BOOL-03'),
    ('10000000-0000-0000-0000-000000000004'::uuid, 'kp:DC-BOOL-04', 'KP marker: DC-BOOL-04'),
    ('10000000-0000-0000-0000-000000000005'::uuid, 'kp:DC-BOOL-05', 'KP marker: DC-BOOL-05'),
    ('10000000-0000-0000-0000-000000000006'::uuid, 'kp:DC-BOOL-06', 'KP marker: DC-BOOL-06'),

    ('20000000-0000-0000-0000-000000000001'::uuid, 'topic:BOOL-gates',    'AND/OR/NOT/XOR/NAND/NOR'),
    ('20000000-0000-0000-0000-000000000002'::uuid, 'topic:BOOL-laws',     'Boolean algebra laws'),
    ('20000000-0000-0000-0000-000000000003'::uuid, 'topic:BOOL-demorgan', 'De Morgan + gate transform'),
    ('20000000-0000-0000-0000-000000000004'::uuid, 'topic:BOOL-sop-pos',  'Minterm/Maxterm SOP/POS'),
    ('20000000-0000-0000-0000-000000000005'::uuid, 'topic:BOOL-kmap',     'Karnaugh map'),
    ('20000000-0000-0000-0000-000000000006'::uuid, 'topic:BOOL-hazard',   'Hazard / glitch')
)
INSERT INTO tags(id, name, description)
SELECT id, name, description FROM tag_seed;


-- 2) tag <-> kp 映射
INSERT INTO tag_kp_map(kp_id, weight, tag_id)
VALUES
  ('DC-BOOL-01', 100, '10000000-0000-0000-0000-000000000001'::uuid),
  ('DC-BOOL-02', 100, '10000000-0000-0000-0000-000000000002'::uuid),
  ('DC-BOOL-03', 100, '10000000-0000-0000-0000-000000000003'::uuid),
  ('DC-BOOL-04', 100, '10000000-0000-0000-0000-000000000004'::uuid),
  ('DC-BOOL-05', 100, '10000000-0000-0000-0000-000000000005'::uuid),
  ('DC-BOOL-06', 100, '10000000-0000-0000-0000-000000000006'::uuid),

  -- 主题 tag 也可以映射到 kp（可选，但对检索/统计更友好）
  ('DC-BOOL-01', 50,  '20000000-0000-0000-0000-000000000001'::uuid),
  ('DC-BOOL-02', 50,  '20000000-0000-0000-0000-000000000002'::uuid),
  ('DC-BOOL-03', 50,  '20000000-0000-0000-0000-000000000003'::uuid),
  ('DC-BOOL-04', 50,  '20000000-0000-0000-0000-000000000004'::uuid),
  ('DC-BOOL-05', 50,  '20000000-0000-0000-0000-000000000005'::uuid),
  ('DC-BOOL-06', 50,  '20000000-0000-0000-0000-000000000006'::uuid);


-- 3) 插入 BOOL demo 题库（每个 KP 3 题，共 18 题）
--    注意：type/status 可能需要替换成你项目真实枚举字符串
WITH q(id, type, stem, difficulty, content, solution, explanation, status, lang) AS (
  VALUES
  -- DC-BOOL-01 gates
  ('30000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-01) AND门：A=1,B=0 时输出为？', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'AND 门只有在两个输入都为 1 时输出 1。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-01) XOR门：A=1,B=1 时输出为？', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'XOR 相同为 0，不同为 1。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-01) 下列哪一个是 NOT(A OR B)？', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"NAND"},{"id":"B","text":"NOR"},{"id":"C","text":"XOR"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'NOT(OR) 对应 NOR。', 'PUBLISHED', 'zh-CN'),

  -- DC-BOOL-02 laws
  ('30000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-02) 化简：A + A = ?', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"0"},{"id":"C","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '幂等律：A + A = A。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-02) 化简：A · 1 = ?', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"0"},{"id":"C","text":"1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '恒等律：A·1=A。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000006'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-02) 吸收律：A + A·B = ?', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"A·B"},{"id":"C","text":"B"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '吸收律：A + A·B = A。', 'PUBLISHED', 'zh-CN'),

  -- DC-BOOL-03 DeMorgan / NAND NOR
  ('30000000-0000-0000-0000-000000000007'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-03) 德摩根：NOT(A·B) 等价于？', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"NOT A · NOT B"},{"id":"B","text":"NOT A + NOT B"},{"id":"C","text":"A + B"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'NOT(AB)=A''+B''。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000008'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-03) 只用 NAND 实现 NOT A 的做法是？', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"A NAND A"},{"id":"B","text":"A NAND 0"},{"id":"C","text":"A NAND 1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'NAND 同输入：A NAND A = NOT A。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000009'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-03) NOT(A + B) 对应哪种门？', 1,
   '{"format":"single_choice","options":[{"id":"A","text":"NAND"},{"id":"B","text":"NOR"},{"id":"C","text":"XNOR"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'NOT(OR)=NOR。', 'PUBLISHED', 'zh-CN'),

  -- DC-BOOL-04 SOP/POS
  ('30000000-0000-0000-0000-000000000010'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-04) 2变量函数 F(A,B)=1 当且仅当 (A,B)=(0,1) 或 (1,1)。其最小项集合是？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"m(0,1)"},{"id":"B","text":"m(1,3)"},{"id":"C","text":"m(2,3)"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '按二进制 AB：01->1，11->3。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000011'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-04) 标准 SOP（与项之和）的“项”指的是？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"若干变量相或"},{"id":"B","text":"若干变量相与（可能带反）"},{"id":"C","text":"一个变量的取反"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'SOP 的每一项是积项（AND）。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000012'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-04) 若 F=ΠM(0,2)，表示 F 在哪些编号上为 0？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"0 和 2"},{"id":"B","text":"除 0 和 2 以外"},{"id":"C","text":"无法判断"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '最大项编号集合对应输出为 0 的格。', 'PUBLISHED', 'zh-CN'),

  -- DC-BOOL-05 Kmap
  ('30000000-0000-0000-0000-000000000013'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-05) 3变量卡诺图中，允许的分组大小是？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"只能 2 的整数倍"},{"id":"B","text":"只能 2 的幂（1,2,4,8）"},{"id":"C","text":"任意连续格数"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'K-map 分组必须是 2 的幂。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000014'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-05) 卡诺图化简的目标通常是最少的？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"逻辑门级数/门数量"},{"id":"B","text":"输入变量个数"},{"id":"C","text":"真值表行数"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '化简就是减少实现成本（门数/级数/输入数）。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000015'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-05) K-map 中边界是否“相邻”（可环绕分组）？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"是"},{"id":"B","text":"否"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'Gray code 排列使边界相邻，可环绕。', 'PUBLISHED', 'zh-CN'),

  -- DC-BOOL-06 Hazard
  ('30000000-0000-0000-0000-000000000016'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-06) 组合逻辑中“毛刺/冒险”通常由什么导致？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"门延迟导致不同路径到达时间不同"},{"id":"B","text":"输入电平一定不稳定"},{"id":"C","text":"只要用 XOR 就会出现"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '典型原因是路径延迟不一致。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000017'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-06) 下列哪种属于“静态 1 冒险”(static-1 hazard)？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"输出应保持 1，但短暂掉到 0"},{"id":"B","text":"输出应保持 0，但短暂升到 1"},{"id":"C","text":"输出随机振荡"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   'static-1：本应为 1，出现短暂 0。', 'PUBLISHED', 'zh-CN'),

  ('30000000-0000-0000-0000-000000000018'::uuid, 'SINGLE_CHOICE', '[DEMO-BOOL] (DC-BOOL-06) 消除 SOP 实现中的静态冒险，常见手段是？', 2,
   '{"format":"single_choice","options":[{"id":"A","text":"增加冗余一致项（consensus term）"},{"id":"B","text":"把所有门换成 XOR"},{"id":"C","text":"降低时钟频率"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '常用加冗余项覆盖相邻最小项。', 'PUBLISHED', 'zh-CN')
)
INSERT INTO questions(id, type, stem, difficulty, content, solution, explanation, status, lang, created_at, updated_at)
SELECT id, type, stem, difficulty, content, solution, explanation, status, lang, now(), now()
FROM q;


-- 4) question <-> tag 映射（每题绑定 1 个 kp tag + 1 个 topic tag）
-- kp tag 权重 100；topic tag 权重 50
INSERT INTO question_tag_map(question_id, tag_id, created_at, weight)
VALUES
  -- BOOL-01
  ('30000000-0000-0000-0000-000000000001'::uuid, '10000000-0000-0000-0000-000000000001'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000002'::uuid, '10000000-0000-0000-0000-000000000001'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000003'::uuid, '10000000-0000-0000-0000-000000000001'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000001'::uuid, '20000000-0000-0000-0000-000000000001'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000002'::uuid, '20000000-0000-0000-0000-000000000001'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000003'::uuid, '20000000-0000-0000-0000-000000000001'::uuid, now(), 50),

  -- BOOL-02
  ('30000000-0000-0000-0000-000000000004'::uuid, '10000000-0000-0000-0000-000000000002'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000005'::uuid, '10000000-0000-0000-0000-000000000002'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000006'::uuid, '10000000-0000-0000-0000-000000000002'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000004'::uuid, '20000000-0000-0000-0000-000000000002'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000005'::uuid, '20000000-0000-0000-0000-000000000002'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000006'::uuid, '20000000-0000-0000-0000-000000000002'::uuid, now(), 50),

  -- BOOL-03
  ('30000000-0000-0000-0000-000000000007'::uuid, '10000000-0000-0000-0000-000000000003'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000008'::uuid, '10000000-0000-0000-0000-000000000003'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000009'::uuid, '10000000-0000-0000-0000-000000000003'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000007'::uuid, '20000000-0000-0000-0000-000000000003'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000008'::uuid, '20000000-0000-0000-0000-000000000003'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000009'::uuid, '20000000-0000-0000-0000-000000000003'::uuid, now(), 50),

  -- BOOL-04
  ('30000000-0000-0000-0000-000000000010'::uuid, '10000000-0000-0000-0000-000000000004'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000011'::uuid, '10000000-0000-0000-0000-000000000004'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000012'::uuid, '10000000-0000-0000-0000-000000000004'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000010'::uuid, '20000000-0000-0000-0000-000000000004'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000011'::uuid, '20000000-0000-0000-0000-000000000004'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000012'::uuid, '20000000-0000-0000-0000-000000000004'::uuid, now(), 50),

  -- BOOL-05
  ('30000000-0000-0000-0000-000000000013'::uuid, '10000000-0000-0000-0000-000000000005'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000014'::uuid, '10000000-0000-0000-0000-000000000005'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000015'::uuid, '10000000-0000-0000-0000-000000000005'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000013'::uuid, '20000000-0000-0000-0000-000000000005'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000014'::uuid, '20000000-0000-0000-0000-000000000005'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000015'::uuid, '20000000-0000-0000-0000-000000000005'::uuid, now(), 50),

  -- BOOL-06
  ('30000000-0000-0000-0000-000000000016'::uuid, '10000000-0000-0000-0000-000000000006'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000017'::uuid, '10000000-0000-0000-0000-000000000006'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000018'::uuid, '10000000-0000-0000-0000-000000000006'::uuid, now(), 100),
  ('30000000-0000-0000-0000-000000000016'::uuid, '20000000-0000-0000-0000-000000000006'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000017'::uuid, '20000000-0000-0000-0000-000000000006'::uuid, now(), 50),
  ('30000000-0000-0000-0000-000000000018'::uuid, '20000000-0000-0000-0000-000000000006'::uuid, now(), 50);

COMMIT;
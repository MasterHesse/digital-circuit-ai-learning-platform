BEGIN;

/* =========================================================
   demo_dc_fnd_v1.sql  —  DC-FND 完整 Demo 题库脚本
   ---------------------------------------------------------
   知识点范围：DC-FND-01 ～ DC-FND-04（数字电路基础）

   题目 UUID 范围：
     CHAPTER    50000000-xxxx（12道，每KP 3道）
     SUPPLEMENT 51~54 000000-xxxx（20道，每KP 5道）

   【question_pool 字段设计意图】
   CHAPTER    = 章节核心练习（每KP 3题，用于课内章节检测）
   SUPPLEMENT = 课外巩固补充题（每KP 5题，推荐系统主力题源）

   【与 demo_dc_bool_v2.sql 的关系说明】
   · 本脚本 Cleanup 仅清理 stem LIKE '[DEMO-FND%' 的题目，
     不影响 '[DEMO-BOOL]' 系列题目
   · BOOL 脚本曾作为前置支撑嵌入的 9 道 FND 题（41/42/43/44
     系列）将被本脚本 Cleanup 清除，并以更完整的 5题/KP 版本替换
   · Tags（kp:DC-FND-* / topic:FND-*）与 BOOL 脚本共享，
     使用 ON CONFLICT DO NOTHING 保证幂等
   · Section 2/3 额外补充 kp:DC-BOOL-01 与 kp:DC-BOOL-03 两个
     辅助标签（ON CONFLICT DO NOTHING），供 FND-04 补充题在
     question_tag_map 中做跨KP引用（连接 FND-04 → BOOL-01/03）

   【推荐策略说明（Service 层待实现）】
   当用户在 KP-X 的 CHAPTER 题中答错时，推荐逻辑应：
     1. 优先推送：同 KP 的 SUPPLEMENT 题（精确巩固）
        → WHERE question_pool = 'SUPPLEMENT'
              AND 题目的 tag 包含 kp:DC-FND-X
     2. 次要推送：跨 KP 标签匹配的 SUPPLEMENT 题（知识溯源）
        → WHERE question_pool = 'SUPPLEMENT'
              AND 题目的 tag 包含前置 KP（weight=70 的跨KP标签）
   ========================================================= */


-- =========================================================
-- SECTION 1: Cleanup（仅清理 FND Demo 题，不影响 BOOL 题）
-- =========================================================
DELETE FROM question_attempts
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-FND%');

DELETE FROM user_question_state
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-FND%');

DELETE FROM question_tag_map
WHERE question_id IN (SELECT id FROM questions WHERE stem LIKE '[DEMO-FND%');

DELETE FROM questions WHERE stem LIKE '[DEMO-FND%';


-- =========================================================
-- SECTION 2: Tags（10个：8 FND标签 + 2 BOOL辅助标签）
-- ON CONFLICT DO NOTHING 保证与 BOOL 脚本共存
-- =========================================================
INSERT INTO tags (id, name, description) VALUES
  -- FND KP tags
  ('10000000-0000-0000-0000-000000000011'::uuid, 'kp:DC-FND-01', 'KP: 数字电路导论（模拟vs数字）'),
  ('10000000-0000-0000-0000-000000000012'::uuid, 'kp:DC-FND-02', 'KP: 数制与进制转换（二/八/十/十六）'),
  ('10000000-0000-0000-0000-000000000013'::uuid, 'kp:DC-FND-03', 'KP: 有符号数与补码（溢出）'),
  ('10000000-0000-0000-0000-000000000014'::uuid, 'kp:DC-FND-04', 'KP: 真值表与逻辑表达式入门'),
  -- FND topic tags
  ('20000000-0000-0000-0000-000000000011'::uuid, 'topic:FND-intro',      '数字电路基础概念'),
  ('20000000-0000-0000-0000-000000000012'::uuid, 'topic:FND-numbase',    '数制与进制转换'),
  ('20000000-0000-0000-0000-000000000013'::uuid, 'topic:FND-signed',     '有符号数与补码'),
  ('20000000-0000-0000-0000-000000000014'::uuid, 'topic:FND-truthtable', '真值表与逻辑表达式'),
  -- BOOL KP tags（辅助，供 FND-04 补充题跨KP引用，与 BOOL 脚本共享）
  ('10000000-0000-0000-0000-000000000001'::uuid, 'kp:DC-BOOL-01', 'KP: 基本逻辑门（AND/OR/NOT/XOR/NAND/NOR）'),
  ('10000000-0000-0000-0000-000000000003'::uuid, 'kp:DC-BOOL-03', 'KP: 德摩根定律与门级变换（NAND/NOR实现）')
ON CONFLICT DO NOTHING;


-- =========================================================
-- SECTION 3: tag_kp_map（10条）
-- =========================================================
INSERT INTO tag_kp_map (tag_id, kp_id, weight) VALUES
  ('10000000-0000-0000-0000-000000000011'::uuid, 'DC-FND-01', 100),
  ('10000000-0000-0000-0000-000000000012'::uuid, 'DC-FND-02', 100),
  ('10000000-0000-0000-0000-000000000013'::uuid, 'DC-FND-03', 100),
  ('10000000-0000-0000-0000-000000000014'::uuid, 'DC-FND-04', 100),
  ('20000000-0000-0000-0000-000000000011'::uuid, 'DC-FND-01',  50),
  ('20000000-0000-0000-0000-000000000012'::uuid, 'DC-FND-02',  50),
  ('20000000-0000-0000-0000-000000000013'::uuid, 'DC-FND-03',  50),
  ('20000000-0000-0000-0000-000000000014'::uuid, 'DC-FND-04',  50),
  -- BOOL 辅助标签的 tag_kp_map（与 BOOL 脚本共享）
  ('10000000-0000-0000-0000-000000000001'::uuid, 'DC-BOOL-01', 100),
  ('10000000-0000-0000-0000-000000000003'::uuid, 'DC-BOOL-03', 100)
ON CONFLICT DO NOTHING;


-- =========================================================
-- SECTION 4: CHAPTER 题（12 道，question_pool='CHAPTER'）
-- DC-FND-01~04，每 KP 3 道，用于课内章节练习
-- =========================================================
WITH q (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool) AS (
  VALUES
  -- ---- DC-FND-01 ----
  ('50000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 下列信号中，哪种属于数字信号？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"温度传感器输出的连续电压"},{"id":"B","text":"正弦波音频信号"},{"id":"C","text":"高/低电平跳变的矩形脉冲序列"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   '数字信号在时间和幅度上均离散（高/低电平表示0和1）；温度电压和正弦波均为时间和幅度连续的模拟信号。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 一个二进制位（bit）能且仅能表示几种状态？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"1种"},{"id":"B","text":"2种"},{"id":"C","text":"4种"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'bit是最小信息单元，只能取0或1两种离散状态，这是数字电路"二值逻辑"的基础。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 以下哪项不是数字电路相比模拟电路的优点？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"抗干扰能力强"},{"id":"B","text":"便于大规模集成与数字存储"},{"id":"C","text":"可以无损地表示和处理任意精度的连续模拟量"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   'ADC量化必然引入误差，数字系统无法无损表示任意精度连续量；抗干扰强、便于集成与存储均是数字电路的突出优点。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-FND-02 ----
  ('50000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 二进制数 1101(2) 转换为十进制数是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"11"},{"id":"B","text":"13"},{"id":"C","text":"15"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '按权展开：1×2³+1×2²+0×2¹+1×2⁰ = 8+4+0+1 = 13。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 十进制数 27 转换为十六进制是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0x1A"},{"id":"B","text":"0x1B"},{"id":"C","text":"0x1C"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '27 = 1×16+11；十六进制中11用字母B表示，故结果为0x1B。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000006'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 八进制数 47(8) 转换为二进制是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"100111(2)"},{"id":"B","text":"100011(2)"},{"id":"C","text":"101011(2)"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '八进制转二进制：每位拆为3位二进制；4(8)→100(2)，7(8)→111(2)，拼接得100111(2)。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-FND-03 ----
  ('50000000-0000-0000-0000-000000000007'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 十进制 -5 用8位补码表示为？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"10000101"},{"id":"B","text":"11111010"},{"id":"C","text":"11111011"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   '+5原码=00000101；取反（反码）=11111010；再加1得补码=11111011。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000008'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 8位二进制补码（有符号数）的表示范围是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"-127 ~ +127"},{"id":"B","text":"-128 ~ +127"},{"id":"C","text":"-128 ~ +128"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'n位补码范围：-2^(n-1) ~ 2^(n-1)-1；8位最小值10000000=-128，最大值01111111=+127。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000009'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 两个8位正数补码相加：0111 0000 + 0011 0000，结果符号位变为1，这说明？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"计算出错，需要重算"},{"id":"B","text":"发生了正溢出（上溢），结果不可信"},{"id":"C","text":"两正数之和确实为负数，完全正常"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '0x70(+112)+0x30(+48)=160>127，超出8位补码上限，发生正溢出；结果1010 0000被错误解读为-96，不可信。',
   'PUBLISHED','zh-CN','CHAPTER'),

  -- ---- DC-FND-04 ----
  ('50000000-0000-0000-0000-000000000010'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 逻辑函数 F = A + B·C，当 A=0, B=1, C=1 时，F=？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0"},{"id":"B","text":"1"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'AND（·）优先于OR（+）：B·C=1·1=1，F=0+1=1。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000011'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 四变量逻辑函数的真值表共有多少行？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"8"},{"id":"B","text":"16"},{"id":"C","text":"32"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'n个输入变量有2ⁿ种输入组合；4变量：2⁴=16行。',
   'PUBLISHED','zh-CN','CHAPTER'),

  ('50000000-0000-0000-0000-000000000012'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 从真值表写出标准SOP（与或式），正确方法是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"找F=0的各行对应最小项，求和"},{"id":"B","text":"找F=1的各行对应最小项，求和"},{"id":"C","text":"把所有变量的所有积项直接相加"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '标准SOP由所有使F=1的输入对应的最小项相OR构成；F=0的行对应最大项，用于构造POS（积之和的对偶形式）。',
   'PUBLISHED','zh-CN','CHAPTER')
)
INSERT INTO questions (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, created_at, updated_at)
SELECT id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, now(), now()
FROM q;


-- =========================================================
-- SECTION 5: SUPPLEMENT 题（20 道，question_pool='SUPPLEMENT'）
-- DC-FND-01~04 各 5 道
-- =========================================================
WITH q (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool) AS (
  VALUES

  /* ---- DC-FND-01（5道）---- */
  ('51000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 将模拟信号转换为数字信号的器件称为？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"DAC（数模转换器）"},{"id":"B","text":"ADC（模数转换器）"},{"id":"C","text":"运算放大器（Op-Amp）"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   'ADC（Analog-to-Digital Converter）将连续模拟信号经采样、量化、编码转换为数字信号；DAC完成反向转换。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('51000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 以下哪类应用场景最适合采用模拟电路而非数字电路？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"程序代码的执行与存储"},{"id":"B","text":"音频信号的高保真连续放大"},{"id":"C","text":"图像文件的压缩与存储"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '模拟电路擅长处理连续信号（如高保真音频放大）；程序执行和文件压缩/存储均属数字系统的典型强项。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('51000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 与模拟信号相比，数字信号的取值特点是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"取值连续，可以是任意实数"},{"id":"B","text":"取值离散，通常只有0和1两种"},{"id":"C","text":"取值随时间连续平滑变化"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '数字信号在时间和幅度上均离散，以有限个值（通常0/1）表示信息；这是其抗干扰能力强的根本原因。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('51000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 一个字节（Byte）包含多少个二进制位（bit）？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"4"},{"id":"B","text":"8"},{"id":"C","text":"16"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '1 Byte = 8 bits，字节是计算机中最常用的基本存储单位；4位称为半字节（nibble），可表示一个十六进制数字（0~F）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('51000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-01) 以下哪种存储介质利用了"两态"（离散）特性来表示数字信息？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"温度计中水银柱的高度"},{"id":"B","text":"硬盘磁道上磁化方向（南极/北极两种状态）"},{"id":"C","text":"麦克风输出的连续音频电压"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '硬盘以两种磁化方向编码0和1，是数字存储的典型例子；水银柱高度和音频电压均为连续变化的模拟量。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-FND-02（5道）---- */
  ('52000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 八进制数 57(8) 转换为十进制数是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"47"},{"id":"B","text":"57"},{"id":"C","text":"63"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '按权展开：5×8¹+7×8⁰ = 40+7 = 47。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('52000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 十进制数 255 转换为十六进制是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0xEF"},{"id":"B","text":"0xFF"},{"id":"C","text":"0xFE"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '255 = 15×16+15 = 0xFF；F在十六进制中代表15（最大单个数字）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('52000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 将二进制数转换为十六进制时，从低位（右）起每几位分为一组？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"2位"},{"id":"B","text":"3位"},{"id":"C","text":"4位"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   '2⁴=16，恰好4位二进制对应一个十六进制数字（0~F），故按4位分组；3位对应八进制转换。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('52000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 二进制数 11001100(2) 对应的十六进制是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"0xCC"},{"id":"B","text":"0xC3"},{"id":"C","text":"0x3C"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '按4位分组：高位1100(2)=12=C，低位1100(2)=12=C，拼接得0xCC。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('52000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-02) 十进制数 100 转换为二进制是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"1100100(2)"},{"id":"B","text":"1100010(2)"},{"id":"C","text":"1101100(2)"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '100=64+32+4=2⁶+2⁵+2²，对应1100100(2)；验证：64+32+4=100。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-FND-03（5道）---- */
  ('53000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 正数的补码与其原码的关系是？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"完全相同（符号位0，数值位不变）"},{"id":"B","text":"数值位按位取反"},{"id":"C","text":"数值位取反再加1"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '正数：原码=反码=补码，符号位为0，数值位不变；只有负数的补码才需要"取反加1"操作。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('53000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 8位补码 10000000 代表哪个十进制数？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"-0"},{"id":"B","text":"-127"},{"id":"C","text":"-128"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   '10000000最高位兼作数值位，权值为-2⁷=-128，故表示-128；这是8位补码唯一没有对应正数的特殊值（最小值）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('53000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 8位补码 11110110 对应的十进制真值是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"-10"},{"id":"B","text":"-9"},{"id":"C","text":"-8"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '最高位1→负数；求反：00001001；加1得00001010=10；故真值为-10。（验证：-128+64+32+16+4+2=-10）',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('53000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 两个符号相异（一正一负）的数做8位补码加法，是否可能溢出？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"不会；异号之和绝对值缩小，必在范围内"},{"id":"B","text":"可能溢出，取决于操作数大小"},{"id":"C","text":"一定溢出"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '设a∈[0,127]，b∈[-128,-1]，则a+b∈[-128,126]，始终在8位补码[-128,127]范围内。溢出只在同号相加（正+正 或 负+负）时发生。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('53000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-03) 计算补码减法 00001010 - 00000011（即10-3），等价于哪个补码加法？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"00001010 + 11111101"},{"id":"B","text":"00001010 + 00000011"},{"id":"C","text":"11110101 + 00000011"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '减去+3等于加上-3；-3的补码：+3=00000011，取反=11111100，加1=11111101；故10-3=00001010+11111101=00000111=7。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  /* ---- DC-FND-04（5道）---- */
  ('54000000-0000-0000-0000-000000000001'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 逻辑表达式 F = A''B + AB''（A''=NOT A）实现的是哪种运算？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"AND（与）"},{"id":"B","text":"OR（或）"},{"id":"C","text":"XOR（异或）"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   'F=A''B+AB''即XOR（异或）的标准定义式：输入不同时F=1（A=0,B=1 或 A=1,B=0），输入相同时F=0。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('54000000-0000-0000-0000-000000000002'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 以下哪种表示方法能唯一确定一个逻辑函数？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"一般逻辑表达式（非标准形式）"},{"id":"B","text":"真值表"},{"id":"C","text":"逻辑图（门电路图）"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '真值表穷举所有输入组合及对应输出，能唯一确定逻辑函数；同一函数可有多种等价的逻辑表达式和逻辑图。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('54000000-0000-0000-0000-000000000003'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 化简：F = A''B + AB（A''=NOT A），结果是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A"},{"id":"B","text":"B"},{"id":"C","text":"A''（即NOT A）"}]}'::jsonb,
   '{"answer":"B"}'::jsonb,
   '提取公因子：F = (A''+A)·B = 1·B = B（互补律A+A''=1，恒等律1·B=B）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('54000000-0000-0000-0000-000000000004'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 逻辑函数 F = A·B 的反函数 F'' = NOT(A·B) 化简结果是？', 2::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"A'' + B''（即NOT A + NOT B）"},{"id":"B","text":"A''·B''（即NOT A · NOT B）"},{"id":"C","text":"A + B"}]}'::jsonb,
   '{"answer":"A"}'::jsonb,
   '德摩根定律：NOT(A·B) = NOT(A)+NOT(B) = A''+B''（"积取反"变"各取反后相或"）。',
   'PUBLISHED','zh-CN','SUPPLEMENT'),

  ('54000000-0000-0000-0000-000000000005'::uuid, 'SINGLE_CHOICE',
   '[DEMO-FND] (DC-FND-04) 五变量逻辑函数的真值表有多少行？', 1::smallint,
   '{"format":"single_choice","options":[{"id":"A","text":"16"},{"id":"B","text":"25"},{"id":"C","text":"32"}]}'::jsonb,
   '{"answer":"C"}'::jsonb,
   'n变量有2ⁿ种输入组合；5变量：2⁵=32行。注意是2的5次方=32，而非5×5=25。',
   'PUBLISHED','zh-CN','SUPPLEMENT')
)
INSERT INTO questions (id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, created_at, updated_at)
SELECT id, type, stem, difficulty, content, solution, explanation, status, lang, question_pool, now(), now()
FROM q;


-- =========================================================
-- SECTION 6: question_tag_map（共 68 条）
-- 标签权重策略：
--   主 KP 标签  weight=100（精确知识点，推荐首选匹配）
--   跨 KP 标签  weight=70 （关联前置/后续KP，支撑知识溯源）
--   主题标签    weight=50 （宏观分类，推荐兜底匹配）
-- =========================================================

-- ---- 6a: FND CHAPTER 题标签（12道×2标签=24条）----
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  -- DC-FND-01 CHAPTER
  ('50000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  -- DC-FND-02 CHAPTER
  ('50000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000006'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000006'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  -- DC-FND-03 CHAPTER
  ('50000000-0000-0000-0000-000000000007'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000007'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000008'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000008'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000009'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000009'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  -- DC-FND-04 CHAPTER
  ('50000000-0000-0000-0000-000000000010'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000010'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000011'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000011'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now()),
  ('50000000-0000-0000-0000-000000000012'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('50000000-0000-0000-0000-000000000012'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now());


-- ---- 6b: FND-01 补充题标签（5道×2标签=10条）----
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('51000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('51000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('51000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('51000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('51000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('51000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('51000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('51000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now()),
  ('51000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000011'::uuid,100,now()),
  ('51000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000011'::uuid, 50,now());


-- ---- 6c: FND-02 补充题标签（5道×2标签=10条）----
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('52000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('52000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('52000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('52000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('52000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('52000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('52000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('52000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now()),
  ('52000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000012'::uuid,100,now()),
  ('52000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000012'::uuid, 50,now());


-- ---- 6d: FND-03 补充题标签（12条）----
-- 53-003 跨KP→FND-02：读取8位补码真值需要熟练掌握二进制运算
-- 53-005 跨KP→FND-02：补码减法转加法需要二进制加法基础
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  ('53000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('53000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  ('53000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('53000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  -- 53-003: 跨KP→FND-02（二进制运算基础）
  ('53000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('53000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000012'::uuid, 70,now()),
  ('53000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  ('53000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('53000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now()),
  -- 53-005: 跨KP→FND-02（二进制加法基础）
  ('53000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000013'::uuid,100,now()),
  ('53000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000012'::uuid, 70,now()),
  ('53000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000013'::uuid, 50,now());


-- ---- 6e: FND-04 补充题标签（12条）----
-- 54-001 跨KP→BOOL-01：A'B+AB' 即XOR，直接涉及异或门概念
-- 54-004 跨KP→BOOL-03：NOT(A·B)=A'+B' 使用德摩根定律
INSERT INTO question_tag_map (question_id, tag_id, weight, created_at) VALUES
  -- 54-001: 跨KP→BOOL-01
  ('54000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('54000000-0000-0000-0000-000000000001'::uuid,'10000000-0000-0000-0000-000000000001'::uuid, 70,now()),
  ('54000000-0000-0000-0000-000000000001'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now()),
  ('54000000-0000-0000-0000-000000000002'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('54000000-0000-0000-0000-000000000002'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now()),
  ('54000000-0000-0000-0000-000000000003'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('54000000-0000-0000-0000-000000000003'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now()),
  -- 54-004: 跨KP→BOOL-03
  ('54000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('54000000-0000-0000-0000-000000000004'::uuid,'10000000-0000-0000-0000-000000000003'::uuid, 70,now()),
  ('54000000-0000-0000-0000-000000000004'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now()),
  ('54000000-0000-0000-0000-000000000005'::uuid,'10000000-0000-0000-0000-000000000014'::uuid,100,now()),
  ('54000000-0000-0000-0000-000000000005'::uuid,'20000000-0000-0000-0000-000000000014'::uuid, 50,now());

/* =========================================================
   执行完毕后可运行以下验证查询：

   -- 按 pool 统计 FND Demo 题目数量
   SELECT question_pool, COUNT(*) AS cnt
   FROM questions WHERE stem LIKE '[DEMO-FND%'
   GROUP BY question_pool;
   -- 期望：CHAPTER 12，SUPPLEMENT 20

   -- 按 KP 统计各池题目数量（仅 FND KP 标签）
   SELECT t.name AS kp, q.question_pool, COUNT(*) AS cnt
   FROM question_tag_map qtm
   JOIN tags t ON t.id = qtm.tag_id
   JOIN questions q ON q.id = qtm.question_id
   WHERE t.name LIKE 'kp:DC-FND-%' AND q.stem LIKE '[DEMO-FND%'
   GROUP BY t.name, q.question_pool
   ORDER BY t.name, q.question_pool;
   -- 期望：每个 FND KP 的 CHAPTER=3，SUPPLEMENT=5

   -- 验证跨KP多标签（补充题中持有 >=2 个KP标签的题目）
   SELECT q.stem, COUNT(DISTINCT t.name) AS kp_tag_count
   FROM question_tag_map qtm
   JOIN tags t ON t.id = qtm.tag_id AND t.name LIKE 'kp:%'
   JOIN questions q ON q.id = qtm.question_id
   WHERE q.question_pool = 'SUPPLEMENT' AND q.stem LIKE '[DEMO-FND%'
   GROUP BY q.id, q.stem
   HAVING COUNT(DISTINCT t.name) >= 2
   ORDER BY kp_tag_count DESC;
   -- 期望：4道题（53-003, 53-005, 54-001, 54-004），各持有2个KP标签
   ========================================================= */

COMMIT;
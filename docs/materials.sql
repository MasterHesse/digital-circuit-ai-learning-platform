BEGIN;

-- FND: 基础 (4个)
INSERT INTO public.materials (id, body, chapter, code, created_at, kp_id, published_at, status, summary, title, type, updated_at)
VALUES 
(uuid_generate_v4(), 
'## 数字电路导论（模拟 vs 数字）

### 1. 基本概念
数字电路处理离散信号（0/1，高/低电平），模拟电路处理连续信号（如电压波形）。数字电路抗噪声强、易集成、逻辑可编程。

### 2. 模拟 vs 数字对比
| 方面 | 模拟电路 | 数字电路 |
|------|----------|----------|
| 信号 | 连续 | 离散（二进制） |
| 噪声 | 易受干扰 | 容错阈值 |
| 设计 | 仿真复杂 | 逻辑化简 |
| 示例 | 放大器 | 加法器 |

### 3. 数字电路优势
- **可靠性**：再生特性恢复信号。
- **大规模集成**：VLSI芯片。
- **应用**：CPU、FPGA、手机。

### 4. 学习路径
从数制入手，理解二进制基础。
掌握后，可设计逻辑门电路。', 'FND', 'DC-FND-01_lesson', CURRENT_TIMESTAMP, 'DC-FND-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'数字电路导论：模拟 vs 数字对比。数字电路处理离散二进制信号，抗噪强、易集成。优势：可靠性高、大规模集成。', 
'数字电路导论（模拟 vs 数字）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 数制与进制转换（二/八/十/十六）

### 1. 数制基础
- **十进制**：基数10，每位0-9。
- **二进制**：基数2，0/1。权重：2^0, 2^1...
- **八进制**：基数8，0-7。
- **十六进制**：基数16，0-9/A-F。

### 2. 转换方法
- **十→二**：除2取余，倒序读。
  示例：10(10) = 1010(2)
- **二→十**：乘权累加。1010(2)=8+2=10(10)
- **二↔八/十六**：分组转换（3位二→一八，4位二→一十六）。
  示例：101101(2)=55(10)=37(8)=39(H)

### 3. 应用要点
BCD码（8421）：十进制打包二进制，用于显示。
练习：转换25(10)到各进制。', 'FND', 'DC-FND-02_lesson', CURRENT_TIMESTAMP, 'DC-FND-02', CURRENT_TIMESTAMP, 'PUBLISHED', 
'数制转换：二/八/十/十六进制。除2取余、二分组法。示例与BCD码应用。', 
'数制与进制转换（二/八/十/十六）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 有符号数与补码（溢出）

### 1. 有符号数表示
- **原码**：符号位+值，缺点：+0/-0。
- **反码**：负数取反。
- **补码**：负数=反码+1。统一加法、单符号位。

### 2. 补码运算
- 加法：正+负=补码相加（溢出丢弃）。
- 范围：n位，-2^{n-1} ~ 2^{n-1}-1。
  示例：4位，-8~7。

### 3. 溢出检测
正+正=负 或 负+负=正 → 溢出。
符号位进位XOR=1。

示例：1011(-5,4位)+0111(7)=溢出。
补码简化硬件设计，必备知识。', 'FND', 'DC-FND-03_lesson', CURRENT_TIMESTAMP, 'DC-FND-03', CURRENT_TIMESTAMP, 'PUBLISHED', 
'有符号数：补码表示（负=反码+1）。运算统一、溢出检测（符号异或）。范围与示例。', 
'有符号数与补码（溢出）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 真值表与逻辑表达式入门

### 1. 真值表
列出所有输入组合输出。变量n→2^n行。

### 2. 逻辑表达式
- **与**：A·B (1仅全1)
- **或**：A+B (1任一1)
- **非**：Ā (反)

### 3. 示例
F=A·B + C：3变量8行表。

| A | B | C | F |
|---|---|---|----|
|0|0|0|0|
|0|0|1|1|...

### 4. 规范形式预备
最小项：Σm(行号F=1)。
入门后学化简。', 'FND', 'DC-FND-04_lesson', CURRENT_TIMESTAMP, 'DC-FND-04', CURRENT_TIMESTAMP, 'PUBLISHED', 
'真值表：全输入输出列。逻辑运算：与/或/非。示例与最小项预备。', 
'真值表与逻辑表达式入门', 'LESSON', CURRENT_TIMESTAMP);

-- BOOL: 布尔代数与化简 (6个)
INSERT INTO public.materials (id, body, chapter, code, created_at, kp_id, published_at, status, summary, title, type, updated_at)
VALUES 
(uuid_generate_v4(), 
'## 基本逻辑门（AND/OR/NOT/XOR 等）

### 1. 基本门符号与真值表
- **AND (与门)**：输出1仅输入全1。符号：& 或 ·
- **OR (或门)**：输出1任一1。符号：+ 
- **NOT (非门)**：反转。
- **XOR (异或)**：奇数1为1。A⊕B = A·B + Ā·B

### 2. 通用门
NAND (与非)：万能，可实现所有门。
NOR (或非)：亦万能。

### 3. 示例电路
半加器：S=A⊕B, C=A·B。

### 4. 波形识别
掌握门特性，为组合逻辑基础。', 'BOOL', 'DC-BOOL-01_lesson', CURRENT_TIMESTAMP, 'DC-BOOL-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'逻辑门：AND/OR/NOT/XOR/NAND/NOR。真值表、符号、万能门、半加器示例。', 
'基本逻辑门（AND/OR/NOT/XOR 等）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 布尔代数基本定律

### 1. 基本定律
- **交换律**：A+B=B+A, A·B=B·A
- **结合律**：(A+B)+C=A+(B+C)
- **分配律**：A·(B+C)=A·B + A·C
- **吸收律**：A+(A·B)=A, A·(A+B)=A
- **补码律**：A+Ā=1, A·Ā=0

### 2. 恒等式
0+ A=A, 1·A=A。

### 3. 化简示例
F= A·B + A·B·C + A·B·C = A·B (吸收律)。

### 4. 应用
手动化简表达式，减少门数。', 'BOOL', 'DC-BOOL-02_lesson', CURRENT_TIMESTAMP, 'DC-BOOL-02', CURRENT_TIMESTAMP, 'PUBLISHED', 
'布尔定律：交换/结合/分配/吸收/补码。恒等式与化简示例。', 
'布尔代数基本定律', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 德摩根定律与门级变换（NAND/NOR 实现）

### 1. 德摩根定律
(A+B)'' = A''·B'', (A·B)'' = A'' + B''

### 2. 门级变换
AND→NAND+NOT, 但双NAND实现AND。
全NAND电路：NOT=NAND输入并联，AND=串NAND+并NAND等。

### 3. NOR实现
类似德摩根，NOR万能。

### 4. 示例
F=A·B + C → 全NAND：4 NAND门。

### 5. 优势
CMOS工艺易实现NAND/NOR，节省成本。', 'BOOL', 'DC-BOOL-03_lesson', CURRENT_TIMESTAMP, 'DC-BOOL-03', CURRENT_TIMESTAMP, 'PUBLISHED', 
'德摩根：(A+B)''=A''B''。NAND/NOR万能实现所有门，CMOS优势。', 
'德摩根定律与门级变换（NAND/NOR 实现）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 最小项/最大项与 SOP/POS 规范形式

### 1. 最小项 (m)
变量全覆盖，F=1行：如A''BC (m1 for ABC=011)

### 2. 最大项 (M)
F=0行：如(A+B+C'') (M6 for 110)

### 3. SOP (和或形)
Σm(i)：最小项或。
POS (积或形)：ΠM(j)：最大项积。

### 4. 示例
真值表F=Σm(1,3,5,7) = A''B + A B''

互补：POS从F''。', 'BOOL', 'DC-BOOL-04_lesson', CURRENT_TIMESTAMP, 'DC-BOOL-04', CURRENT_TIMESTAMP, 'PUBLISHED', 
'最小项/最大项：SOP=Σm, POS=ΠM。规范形式与互补关系。', 
'最小项/最大项与 SOP/POS 规范形式', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 卡诺图化简（2~4 变量）

### 1. 卡诺图 (K-map)
格子图，邻格可合并（幂2组）。

### 2. 2-4变量示例
3变A B C：
  BC\A 00 01 11 10
00 |0  1  1  0 → 组A=0,B=1 → B''

### 3. 规则
- 最大组、对称环绕、别漏1。
- 4变：16格，行/列表达式。

### 4. 验证
化简后查表一致。

卡诺图直观，Quine-McCluskey补。', 'BOOL', 'DC-BOOL-05_lesson', CURRENT_TIMESTAMP, 'DC-BOOL-05', CURRENT_TIMESTAMP, 'PUBLISHED', 
'卡诺图：邻格合并幂2组。2-4变示例、规则、验证。', 
'卡诺图化简（2~4 变量）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 组合逻辑毛刺与冒险（Hazard）

### 1. 毛刺 (Glitch)
瞬时错误输出，因延迟。

### 2. 静态冒险
- 函数不变，输出跳变。
静态1冒险：并项覆盖重叠。

### 3. 动态冒险
函数变，多次变。

### 4. 消除
静态1：加冗余项 (P Q + P Q'')。
冒险检测：多相器。

### 5. 示例
F= A B + A'' C，A=1→0时冒险，加 A B + A'' C + A C。', 'BOOL', 'DC-BOOL-06_lesson', CURRENT_TIMESTAMP, 'DC-BOOL-06', CURRENT_TIMESTAMP, 'PUBLISHED', 
'毛刺/冒险：静态/动态。消除：冗余项覆盖。示例。', 
'组合逻辑毛刺与冒险（Hazard）', 'LESSON', CURRENT_TIMESTAMP);

-- COMB: 组合逻辑模块 (5个)
INSERT INTO public.materials (id, body, chapter, code, created_at, kp_id, published_at, status, summary, title, type, updated_at)
VALUES 
(uuid_generate_v4(), 
'## 组合逻辑设计流程（规格→真值表→化简→实现）

### 1. 设计步骤
1. **规格**：功能描述（如2选1 MUX）。
2. **真值表**：输入输出全列。
3. **化简**：K-map → 最小SOP。
4. **实现**：门电路或模块调用。
5. **验证**：仿真。

### 2. 示例：3输入多数投票
F=多数1 → Σm(3,5,6,7) → AB+AC+BC。

### 3. 注意
考虑毛刺，选NAND实现。

完整流程确保正确性。', 'COMB', 'DC-COMB-01_lesson', CURRENT_TIMESTAMP, 'DC-COMB-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'组合逻辑设计：规格→表→K-map→门实现→验证。多数投票示例。', 
'组合逻辑设计流程（规格→真值表→化简→实现）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 多路选择器 MUX（实现与应用）

### 1. MUX定义
n选1：S选择输入到Y。
2选1：Y= S·I1 + S''·I0

### 2. 实现
- 门级：与或门。
- 级联：4选1=两2选1。

### 3. 应用
- 数据路由、函数发生器（全MUX实现任意函数）。
- Verilog：assign Y = sel ? i1 : i0;

### 4. 扩展
带使能EN。', 'COMB', 'DC-COMB-02_lesson', CURRENT_TIMESTAMP, 'DC-COMB-02', CURRENT_TIMESTAMP, 'PUBLISHED', 
'MUX：n选1数据选择。门实现、级联、函数发生器应用。', 
'多路选择器 MUX（实现与应用）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 译码器 Decoder（含使能与地址译码）

### 1. Decoder
n→2^n线：全1解码一热。
2-4解码器：A1A0=00→Y0=1。

### 2. 使能G
G=0全0。级联大译码。

### 3. 应用：地址译码
内存芯片选通：高地址→片选CS。

### 4. 实现
与门阵列。', 'COMB', 'DC-COMB-03_lesson', CURRENT_TIMESTAMP, 'DC-COMB-03', CURRENT_TIMESTAMP, 'PUBLISHED', 
'译码器：n→2^n一热。使能G、地址应用、与门实现。', 
'译码器 Decoder（含使能与地址译码）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 编码器 Encoder（含优先编码）

### 1. Encoder
2^n→n线：一热→二进制。
优先编码器：多1取最高。

### 2. 优先2-4
输入D3~D0，V=有效，Y1Y0=最高D位置。

### 3. 真值表
D3=1→Y=11, V=1。

### 4. 应用
键盘扫描。', 'COMB', 'DC-COMB-04_lesson', CURRENT_TIMESTAMP, 'DC-COMB-04', CURRENT_TIMESTAMP, 'PUBLISHED', 
'编码器：一热→二进制。优先级处理多输入。', 
'编码器 Encoder（含优先编码）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 三态缓冲与总线（Tri-state & Bus）

### 1. 三态门
输出：高/低/高阻Z。EN=1传，0=Z。

### 2. 总线
多发一收：EN控制上总线。

### 3. 应用
内存总线：CS+RD/WR选。
仲裁：总线控制器。

### 4. 注意
无EN冲突。', 'COMB', 'DC-COMB-05_lesson', CURRENT_TIMESTAMP, 'DC-COMB-05', CURRENT_TIMESTAMP, 'PUBLISHED', 
'三态缓冲：高阻Z输出。总线多路访问、无冲突。', 
'三态缓冲与总线（Tri-state & Bus）', 'LESSON', CURRENT_TIMESTAMP);

-- ARITH: 算术电路 (5个)
INSERT INTO public.materials (id, body, chapter, code, created_at, kp_id, published_at, status, summary, title, type, updated_at)
VALUES 
(uuid_generate_v4(), 
'## 半加器与全加器

### 1. 半加器 (HA)
无进位输入：S=A⊕B, C=A·B

### 2. 全加器 (FA)
S=A⊕B⊕Cin, Cout= A·B + (A⊕B)·Cin

### 3. 真值表
FA 8行验证。

### 4. 实现
两HA+或门。

级联多位。', 'ARITH', 'DC-ARITH-01_lesson', CURRENT_TIMESTAMP, 'DC-ARITH-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'半/全加器：S=⊕, C=多数。真值与级联。', 
'半加器与全加器', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 多位加法器（串行进位、溢出）

### 1. 串行进位 (Ripple Carry)
FA串联，Cout→Cin下位。延迟n t_pd。

### 2. 溢出
符号位Cout XOR Cn-1。

### 3. 改进
进位预看 CLA：快速C生成。

### 4. 示例
4位：A=1011+B=0011=1110。', 'ARITH', 'DC-ARITH-02_lesson', CURRENT_TIMESTAMP, 'DC-ARITH-02', CURRENT_TIMESTAMP, 'PUBLISHED', 
'多位加法器：Ripple Carry延迟、溢出检测。CLA预看。', 
'多位加法器（串行进位、溢出）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 减法与补码加法

### 1. 减法=加负
A-B = A + (-B) = A + ~B +1 (补码)

### 2. ALU减
加法器+控制：Sub=1→Xin=~X+1。

### 3. 符号扩展
负数高位补1。

### 4. 示例
7-3：0111 + 1101( -3补)=0100。', 'ARITH', 'DC-ARITH-03_lesson', CURRENT_TIMESTAMP, 'DC-ARITH-03', CURRENT_TIMESTAMP, 'PUBLISHED', 
'减法：补码加。ALU控制、符号扩展。', 
'减法与补码加法', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 比较器（相等/大小）

### 1. 相等
Eq= (A0=B0) · (A1=B1)...

### 2. 大小
逐位从MSB：A>B若A_i=1 B_i=0首异位。

### 3. 级联
3状态：A>B, A=B, A<B。

### 4. 示例
4位比较器K-map。', 'ARITH', 'DC-ARITH-04_lesson', CURRENT_TIMESTAMP, 'DC-ARITH-04', CURRENT_TIMESTAMP, 'PUBLISHED', 
'比较器：Eq逐位与，大小MSB优先。级联3状态。', 
'比较器（相等/大小）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 简单 ALU（加/减/与/或/异或）

### 1. ALU功能
多运算选：Op[1:0]控加减逻辑/位。

### 2. 设计
- 算术：前述+ MUX。
- 逻辑：门直通。

### 3. 真值表
Op=00加,01减,10与,11或。

### 4. 标志
Zero=~|Y, Carry, Overflow。', 'ARITH', 'DC-ARITH-05_lesson', CURRENT_TIMESTAMP, 'DC-ARITH-05', CURRENT_TIMESTAMP, 'PUBLISHED', 
'简单ALU：Op选加减逻辑位运算。标志生成。', 
'简单 ALU（加/减/与/或/异或）', 'LESSON', CURRENT_TIMESTAMP);

-- SEQ/TIM: 时序逻辑与时序概念 (SEQ 6 + TIM 2)
INSERT INTO public.materials (id, body, chapter, code, created_at, kp_id, published_at, status, summary, title, type, updated_at)
VALUES 
(uuid_generate_v4(), 
'## 时钟与同步设计基本思想

### 1. 时序逻辑
输出依输入+状态，时钟同步。

### 2. 时钟信号
周期上升/下降沿触发。

### 3. 同步设计
边沿触发，全系统统一CLK，避免竞争。

### 4. 时序图
Setup前输入稳定。

异步风险高，用同步。', 'SEQ', 'DC-SEQ-01_lesson', CURRENT_TIMESTAMP, 'DC-SEQ-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'时序逻辑：时钟同步边沿触发。异步风险。', 
'时钟与同步设计基本思想', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 锁存器与触发器（Latch vs FF）

### 1. 锁存器 (Latch)
电平敏感：EN=1透传，0锁。

### 2. 触发器 (FF)
边沿敏感：↑沿采样。

### 3. 类型
SR Latch：NAND交叉。D Latch：SR变D。

### 4. 对比
Latch易毛刺，FF同步好。

设计用FF。', 'SEQ', 'DC-SEQ-02_lesson', CURRENT_TIMESTAMP, 'DC-SEQ-02', CURRENT_TIMESTAMP, 'PUBLISHED', 
'Latch电平 vs FF边沿。SR/D实现、优劣。', 
'锁存器与触发器（Latch vs FF）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## D 触发器与寄存器

### 1. D FF
Qnext=D，↑采样。

### 2. 寄存器
n D FF并行：并入串出。

### 3. 使能
CLK·EN控制。

### 4. 实现
Master-Slave D Latch。', 'SEQ', 'DC-SEQ-03_lesson', CURRENT_TIMESTAMP, 'DC-SEQ-03', CURRENT_TIMESTAMP, 'PUBLISHED', 
'D FF/寄存器：边沿采样、使能、Master-Slave。', 
'D 触发器与寄存器', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 常见触发器 SR/JK/T（认识与转换）

### 1. SR FF
S=1 R=0设，R=1 S=0复，禁00/11。

### 2. JK FF
J=K=1互补，解禁。

### 3. T FF
T=1翻转，计数用。

### 4. 转换
JK→D: J=D, K=D''
特征表转换。', 'SEQ', 'DC-SEQ-04_lesson', CURRENT_TIMESTAMP, 'DC-SEQ-04', CURRENT_TIMESTAMP, 'PUBLISHED', 
'S R/J K/T FF：特征与互转。', 
'常见触发器 SR/JK/T（认识与转换）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 传播延迟、建立/保持时间（Timing）

### 1. t_pd：门延迟累积。

### 2. Setup t_su：CLK前D稳定。

### 3. Hold t_h：CLK后D稳。

### 4. 时序约束
t_su + t_pd < T_clk - t_pd_max。

违约亚稳。', 'TIM', 'DC-TIM-01_lesson', CURRENT_TIMESTAMP, 'DC-TIM-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'时序：t_pd/t_su/t_h。CLK周期约束。', 
'传播延迟、建立/保持时间（Timing）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 亚稳态与同步器（Metastability）

### 1. 亚稳：违时序，Q慢变。

### 2. MTBF
同步器两FF串：减概率。

### 3. 解决
时钟域跨越用FIFO/握手。

### 4. 概率
e^{-t/τ}衰减。', 'TIM', 'DC-TIM-02_lesson', CURRENT_TIMESTAMP, 'DC-TIM-02', CURRENT_TIMESTAMP, 'PUBLISHED', 
'亚稳态：违约慢变。两FF同步器、MTBF。', 
'亚稳态与同步器（Metastability）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 移位寄存器（串并转换）

### 1. SISO：串入串出。

### 2. PISO/SIPO：并串/串并。

### 3. 环形/Johnson：反馈。

### 4. 应用
串口通信、延时。', 'SEQ', 'DC-SEQ-05_lesson', CURRENT_TIMESTAMP, 'DC-SEQ-05', CURRENT_TIMESTAMP, 'PUBLISHED', 
'移位寄存器：串并转换类型、应用。', 
'移位寄存器（串并转换）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 计数器（异步/同步、模 N）

### 1. 异步 (Ripple)：Cout链T FF。

### 2. 同步：全并CLK，逻辑解码复位。

### 3. 模N：清零逻辑，如÷3。

### 4. 上/下：DIR控。', 'SEQ', 'DC-SEQ-06_lesson', CURRENT_TIMESTAMP, 'DC-SEQ-06', CURRENT_TIMESTAMP, 'PUBLISHED', 
'计数器：异步/同步、模N清零、上/下下行。', 
'计数器（异步/同步、模 N）', 'LESSON', CURRENT_TIMESTAMP);

-- FSM / MEM (2个)
INSERT INTO public.materials (id, body, chapter, code, created_at, kp_id, published_at, status, summary, title, type, updated_at)
VALUES 
(uuid_generate_v4(), 
'## 有限状态机 FSM（Moore/Mealy，状态图→电路）

### 1. FSM定义
状态+输入→输出/下一状态。

### 2. Moore：输出依状态。
Mealy：依状态+输入（快）。

### 3. 设计
1. 状态图/表。
2. 下一状态K-map→D FF。
3. 输出逻辑。

### 4. 示例：2位序列检测010。', 'FSM', 'DC-FSM-01_lesson', CURRENT_TIMESTAMP, 'DC-FSM-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'FSM：Moore/Mealy。状态图→下一/输出逻辑。序列检测例。', 
'有限状态机 FSM（Moore/Mealy，状态图→电路）', 'LESSON', CURRENT_TIMESTAMP),

(uuid_generate_v4(), 
'## 存储器基础（ROM/RAM，地址/数据，读写概念）

### 1. ROM：只读，掩膜/OTP。
解码地址→数据线。

### 2. RAM：读写。
SRAM：6T翻转，DRAM：1T+电容。

### 3. 时序
地址稳定→CS+RD/WE→数据。

### 4. 组织
xM xN位。', 'MEM', 'DC-MEM-01_lesson', CURRENT_TIMESTAMP, 'DC-MEM-01', CURRENT_TIMESTAMP, 'PUBLISHED', 
'ROM/RAM：只读/读写。SRAM/DRAM细胞、地址/读写时序。', 
'存储器基础（ROM/RAM，地址/数据，读写概念）', 'LESSON', CURRENT_TIMESTAMP);

COMMIT;
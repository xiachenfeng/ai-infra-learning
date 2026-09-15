# 第二轮重学：局部编号与全局编号

- 日期：2026-09-15
- 状态：本次已保存；R2 编号与分组基础检查通过，整个单元未完成
- 前序内容：[[sessions/2026-09-13-grid-block-thread-relearning|Grid、Block、Thread 入门]]

## 本次讲解

- `threadIdx.x` 是本 Block 内的编号，另一个 Block 可以拥有相同的局部编号。
- 对本次一维 launch，需要结合 Block 编号和组内 Thread 编号区分逻辑线程。
- 每 Thread 处理一个元素的本例采用连续映射：全局编号 = Block 编号 × 每 Block 线程数 + 局部编号。
- 通过两个 Block 各自的 Thread 0 示范编号重复与全局位置不同。箭头表示本例的数据负责关系，不表示调度或执行先后。

## 独立测评与 Evaluation

纯编号模型：一个 Grid 有 3 个 Block，每个 Block 4 个 Thread；所有编号从 0 开始；每个 Thread 负责一个元素，各 Block 按连续段分配。判断 Block 2、Thread 1 负责的全局元素编号，并给出算式。

用户回答：`2*4+1=9`。独立完成，答案和算式均正确。正确性 4、完整性 4、迁移能力 2；难度 2，信心未提供。已追加正式记录；本题只证明简单一维编号应用，不据此提升历史掌握度或判定 R2 完成。

## 显示与验证

聊天中的计算采用普通文本，避免当前公式显示问题；Obsidian 原生数学规范保持不变。
这是概念推导，不是 GPU 实测。沿用历史掌握度；新增一维编号独立应用证据。

## 后续教学

下一步讲解同一个 Block 的 Thread 如何按连续编号组成 32 线程的 Warp，用一维 64 线程 Block 完整示范两个 Warp。随后安排同一 Block 有 96 个 Thread 的分组计数练习；该练习回答 96/32=3，正确，不评分。

机制依据：[NVIDIA Advanced Kernel Programming](https://docs.nvidia.com/cuda/cuda-programming-guide/03-advanced/advanced-kernel-programming.html)。

## Warp 独立测评与 Evaluation

条件：一个一维 Block 有128个线程，编号从0开始；判断给定线程的 Warp 编号并给出依据。

- Thread 70：首次回答“70/32=2.x，warp应该是3”，方法正确但混淆第几组与编号。正确性2、完整性4、迁移能力1、难度2、信心未提供。提示后回答2，记为提示后完成；不覆盖首次评分。
- Thread 105：回答“105/32=3.x，所以是3”，独立完成。正确性4、完整性4、迁移能力2、难度2、信心未提供。
- 下一步讲解部分 Warp：以40线程示范；50线程引导练习回答50-32=18，正确且不评分。R2仍未完成验收，历史掌握度不变。

## 部分 Warp 独立测评与 Evaluation

题目：一个一维 Block 有70个线程，判断“需要3个Warp，所以实际启动96个Thread”是否正确并解释。

用户回答：“不对，启动3个warp，但是最后一个并未完全使用。”独立完成；正确性4、完整性4、迁移能力2、难度2、信心未提供。题目未要求计算尾组具体人数，不因未写6而扣分。

下一步讲解 Warp 不跨 Block 合并：用两个各16线程的 Block 示范，再练习三个各20线程的 Block，共多少 Warp。练习回答3个，正确，不评分。

## Block 分组边界独立测评与 Evaluation

题目：同为64线程，A为1个Block各64线程，B为4个Block各16线程；比较Warp数并解释。用户回答：“2个，4个block内独立组成warp”。依照题目顺序，A为2个、B为4个，理由正确；独立完成。正确性4、完整性4、迁移能力3、难度2、信心未提供。单题评分不直接提升整体掌握度。

下一步讲解 Lane：Warp 内从0到31的位置编号，以一维Block中的Thread70对应Warp2、Lane6示范。Thread45的Lane引导练习回答12，教师用编号表讲解正确结果13；相似练习Thread46回答14，正确。两次均为引导练习，不逐题评分。

## Lane 独立测评与 Evaluation

题目：一维Block有128个线程，编号从0开始，判断Thread83的Lane编号并给出算式。用户回答：“19，83=2*32+19”。独立完成；正确性4、完整性4、迁移能力2、难度2、信心未提供。已追加正式答题记录。

本组一维编号练习结束，R2学习会话仍进行中，下一步推荐二维线程坐标与线性编号；尚未开始讲解或测评。历史掌握度保留，未据此认定R2整体完成。

## 二维线程坐标讲解

开始二维编号概念模型：一个Block在x方向4个线程、y方向3个线程，总计12个；图中x向右、y向下，所有坐标从0开始。CUDA的Block内线性编号按x先变化，等于y乘以x方向线程数再加x。编号顺序不表示执行时间顺序。

完整示范坐标(x=2,y=1)：前面1整行共4个线程，本行偏移2，因此线性编号6。引导练习坐标(x=1,y=2)的Block内线性编号，回答9，正确，不评分。当前为概念模型，不涉及原CUDA示例的代码修改或GPU实验。

依据：[NVIDIA Thread Hierarchy](https://docs.nvidia.com/cuda/archive/12.6.0/cuda-c-programming-guide/index.html#thread-hierarchy)。

## 二维线性编号独立测评与 Evaluation

条件：二维Block的x方向8线程、y方向4线程；目标坐标(x=3,y=2)，要求线性编号及算式。

首次回答26：正确性0、完整性2、迁移能力0、难度2、信心未提供。未提供算式，不能仅凭26推断具体错误来源。第一轮引导定位行起点后回答2*4+1=9，沿用上一题条件；教师对照两题并解释每行线程数与总行数的区别，再引导定位前两行线程数。用户修正为2*8+3=19，记为提示后完成，不覆盖首次评分。

独立复测：x方向6线程、y方向4线程，目标(x=4,y=2)，要求Block内线性编号及算式。用户回答2*6+4=16，独立完成；正确性4、完整性4、迁移能力2、难度2、信心未提供。首次题评分保留，复测单独记录。

## 二维坐标到 Warp 与 Lane 的组合示范

使用8列8行的单个Block，按每行8线程排列：y为0至3的四行对应线性编号0至31、Warp0；y为4至7对应编号32至63、Warp1。图表仅表示编号与分组，不表示执行顺序。示范目标(x=3,y=5)：线性编号43，43=1*32+11，因此Warp1、Lane11。

引导练习：同一个8列8行Block，目标(x=6,y=4)，给出线性编号、Warp与Lane的对应关系；回答线程编号38、Warp1、Lane6，正确，不评分。R2整体未完成验收。

## 二维 Warp 与 Lane 独立测评与 Evaluation

条件：8列8行的Block，坐标(x=2,y=6)，要求先给出线性线程编号，再判断Warp和Lane。首次回答6*8+2=50、Warp2、Lane18。线性编号与Lane正确，Warp编号错误；正确性3、完整性4、迁移能力2、难度2、信心未提供。教师提示补全50=空格*32+18后，用户回答Warp1，记为提示后完成，不覆盖首次表现。

独立复测：8列12行的Block，坐标(x=5,y=9)，要求线性编号、Warp编号与Lane编号并附算式。用户回答77、2、13，三个编号均正确，独立完成；正确性4、完整性3、迁移能力2、难度2、信心未提供。完整性扣分仅因题目明确要求算式而未提供，不影响编号应用检查通过。教师补充9*8+5=77和77=2*32+13，不计作用户独立推导证据。

二维坐标到Warp/Lane的基本计算复测通过，停止重复同型编号练习。下一步推荐用完整代码讲解Warp内分支执行；尚未开始。R2整体仍待验收，不提前提升整体掌握度。

## Session End — 2026-09-15

- 本次保存涵盖9月13日至15日课程设计调整与重学记录；本课共10道正式测评，7次首次结果正确，3次提示后修正；引导练习不评分。前序9月13日另有2道正式测评，分别保留。
- 学会：一维全局映射、部分Warp、各Block独立分组、Lane、二维坐标到线性编号及Warp/Lane。
- 薄弱点：零基编号与第几组混淆、换题时沿用旧行宽；复测已通过，安排间隔解释题。
- 掌握度：GPU Execution Model保持3，R2未整体验收，本轮0/8单元完成。没有新增GPU实测。
- 下一课：完整代码与图示讲解Warp内分支执行。

### Knowledge Extraction

| 知识范围 | 处理结果 | 依据 |
|---|---|---|
| 一维编号、部分Warp与Block分组 | 更新Canonical | 历史独立解释与本轮应用、原因解释及NVIDIA资料支持；保留原验证日期 |
| 二维坐标到Warp/Lane | 新建Candidate | 已独立计算，尚缺本轮脱离提示的机制解释；列明提升条件并加入复习队列 |
| R1提交与完成、同步等待 | No Knowledge Change | 已有正式卡覆盖；本轮复习没有改变机制结论，依赖解释仍待独立复核 |

目标：[[knowledge/canonical/gpu-execution-hierarchy]]、[[knowledge/candidates/2d-thread-warp-lane-mapping]]；R1已有卡：[[knowledge/canonical/cuda-streams-events-and-timing]]。

### 保存检查与变更摘要

- 状态、掌握度证据、错误、复习队列、正式答题记录已对齐；保留首次评分与提示修正。
- 正式卡迁移为wikilink、原生数学和Mermaid；二维候选卡附坐标表与映射图。
- 只做静态语法与路径检查，未在Obsidian实际预览。CUDA示例未实机编译运行。
- 同步包含本轮课程原则、README、模板、示例、会话与计划；本地Obsidian配置和空白日记不纳入学习提交。

### 本次提交文件清单

- [[AGENTS]]
- [[README]]
- [[curriculum]]
- [[inbox]]
- [[templates/knowledge-card]]
- [[knowledge/canonical/gpu-execution-hierarchy]]
- [[knowledge/candidates/2d-thread-warp-lane-mapping]]
- [[state/current]]
- [[state/mastery]]
- [[state/mistakes]]
- [[state/review-queue]]
- [[state/answer-history.csv]]
- [[examples/cuda/thread_block_grid.cu]]
- [[examples/pytorch/eager_async.py]]
- [[sessions/2026-09-13-cpu-gpu-relearning]]
- [[sessions/2026-09-13-grid-block-thread-relearning]]
- [[sessions/2026-09-13-relearning-plan]]
- [[sessions/2026-09-15-thread-index-relearning]]
- [[weekly-reviews/2026-W33]]
- [[weekly-reviews/2026-W36]]
- [[weekly-reviews/2026-W37]]
- [[weekly-reviews/2026-W38]]

关键变更：推理主线与教学约定更新；R1/R2过程与正式成绩补全；GPU执行正式卡增加证据和原生图形；二维候选卡新增；复习任务定于9月18日起。历史8月14日CSV记录仅补引号以修复字段解析，原答案和评分均保留。历史周报保留原文，不作为本周成果。

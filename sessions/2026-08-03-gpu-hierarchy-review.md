# Learning Session

- Date: 2026-08-02 至 2026-08-03
- Topic: Warp 与 Grid、Block、Thread 的本质区别
- Duration: 未记录
- Final confidence: 80/100

## Learning Goals

- 间隔复测 Grid、Block、Thread、Warp 的关系与区别。
- 区分 serving 请求、CUDA Stream 和 kernel 执行层对象。
- 将执行层级用于分析部分 Warp、分支发散和跨 Block 同步。

## Questions Asked

1. 闭卷定义 Grid、Block、Thread、Warp。
2. 分析多个 Grid 与 CUDA Stream 的执行关系。
3. 分析 LLM serving 是否适合一用户一 Stream。
4. 推导 continuous batching 的吞吐来源与延迟代价。
5. 判断用户请求与 Warp/Block/Grid 的映射关系。
6. 分析部分有效 Warp、Warp Divergence 和 Warp 是否能跨 Block。
7. 分析跨 Block 等待造成的调度死锁。
8. 区分 Thread 逻辑实例数与 Warp 数量。

## My Answers

- 正确指出 Grid、Block、Thread 属于程序组织计算的概念，Warp 属于硬件执行概念。
- 正确说明一次 launch 对应一个 Grid，同一 Stream 按顺序执行。
- 经引导后说明用户请求与 Grid/Warp 是多对多关系。
- 能解释 batching 可能提高吞吐但不一定降低延迟。
- 正确分析 40 Thread Block 的两个 Warp 及分支发散情况。
- 正确指出 Warp 不会跨 Block，且跨 Block 等待可能导致 kernel 卡住。
- 曾把 256 个 Thread/8 个 Warp 误答为“8 个逻辑执行实例”，经追问后纠正为 256 个逻辑实例和 8 个 Warp。

## Evaluation

GPU Execution Model 从“能够解释”提升到“能够应用和分析”。用户不仅能复述四个概念，还能分析部分有效 Warp、分支发散、跨 Block 死锁，并迁移到 LLM serving 的多对多映射。Thread 与 Warp 的逻辑实例混淆经苏格拉底式追问后纠正，需间隔复测。Continuous Batching 和跨 Stream 并发仍主要依赖引导，暂不视为正式掌握。

## New Knowledge

- Thread 数决定逻辑执行实例数；Warp 数描述硬件如何成组执行 Thread。
- Warp 固定从同一 Block 内取 Thread，不能跨 Block 拼接。
- 普通 kernel 中跨 Block 全局等待可能因 Block 未全部驻留而死锁。
- LLM 用户请求与 kernel/Grid 是多对多关系。
- Continuous Batching 的主要收益来自更大的矩阵问题、权重复用、并行 tile 和开销分摊，而非简单增加 Stream。

## Mistakes and Gaps

- 一度把 Warp 数量当成 Thread 逻辑实例数量。
- 初始解释 batching 时过度强调 Stream 竞争和 Warp 统一控制流，忽略权重复用、矩阵规模与 kernel launch 开销。
- 尚未验证不同 Stream 的 Grid 是否真实并发。
- 尚未部署或 benchmark Continuous Batching。

## Mastery Changes

- GPU Execution Model: 2 → 3
- CUDA Stream and Grid Concurrency: 新增 1
- Continuous Batching: 0 → 2

## Knowledge Extraction

- 合并正式知识：`knowledge/canonical/gpu-execution-hierarchy.md`
- 新增候选：`knowledge/candidates/cuda-stream-grid-concurrency.md`
- 新增候选：`knowledge/candidates/llm-continuous-batching.md`
- 未更新 `knowledge/candidates/cuda-asynchronous-execution.md`：本次没有复测 eager execution、GPU 完成与 CPU 同步等待。
- 未沉淀 occupancy、寄存器/shared memory 对驻留资源的定量影响：本次只涉及直觉，没有计算或实验。

## Files Updated

- `sessions/2026-08-03-gpu-hierarchy-review.md`
- `knowledge/canonical/gpu-execution-hierarchy.md`
- `knowledge/candidates/cuda-stream-grid-concurrency.md`
- `knowledge/candidates/llm-continuous-batching.md`
- `state/current.md`
- `state/mastery.md`
- `state/mistakes.md`
- `state/review-queue.md`
- `state/answer-history.csv`
- `inbox.md`
- `weekly-reviews/2026-W31.md`（学习开始时按规则生成）

## Next Review

- 2026-08-06：复测 Thread 逻辑实例数、Warp 数与部分有效 Warp。
- 2026-08-10：闭卷解释完整执行层级和 LLM 请求映射。
- 下一学习任务：验证 PyTorch eager execution 与 CUDA asynchronous execution。

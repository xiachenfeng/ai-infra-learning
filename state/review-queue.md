# Review Queue

当前安排（2026-09-15）：R1已讲解、依赖解释待独立复核；R2编号与分组计算已通过，下一课先讲Warp内分支。按 [[sessions/2026-09-13-relearning-plan|R1–R8重学计划]] 继续。保留历史复习需求，不一次清空逾期项。

2026-09-13 调整：下表日期和优先级保留原计划记录，不要求一次清空逾期项。每次按当前推理主线选一个直接相关主题复习；tiled transpose 深入优化和 `record_stream()` 三版本实验为选修/待验证，不阻塞主线。恢复上下文时先讲解和示范，独立测评只检查已经教过的机制；具体下一步以 `state/current.md` 为准。

| Knowledge Point | Reason | Priority | Review After |
|---|---|---:|---|
| GPU Execution Model | 复测 kernel launch 对应 Grid、整 Grid 的同 Stream 顺序和跨 Stream Event 依赖 | 5 | 2026-08-12 |
| GPU Memory Hierarchy | 闭卷复测 Register、Shared Memory、L2、HBM 的延迟、容量和作用域；用指标区分数据复用与访问重排 | 5 | 2026-08-13 |
| CUDA Tiled Transpose and Bank Conflict | 从 `examples/cuda/tiled_transpose.cu` 复测 Block/tile 两层坐标交换、coalescing、同地址广播、同 bank 不同地址冲突和 32→33 padding；有 GPU 时编译并 profiler 验证 | 5 | 2026-08-13 |
| CUDA Tensor Lifetime and `record_stream()` | 官方文档和 allocator 源码说明已核验；待在 NVIDIA GPU 上完成三版本最小实验并决定是否提升为 canonical | 5 | 2026-08-12 |
| CUDA Event Timing | 复测预热、Event 区间、同步范围和批量/单次计时单位 | 5 | 2026-08-11 |
| CUDA Stream Concurrency | 根据 profiler 时间线计算重叠，并解释“允许并发”不等于充分并行或抢占 | 4 | 2026-08-11 |
| LLM Continuous Batching | 独立解释调度循环、权重复用与吞吐—延迟权衡 | 4 | 2026-08-10 |

## 本轮间隔复习

| 内容 | 可检查任务 | 优先级 | 最早复习日期 |
|---|---|---:|---|
| 二维编号与零基Warp | 脱离公式解释为何乘每行线程数、为何Lane不总等于x；新Block形状下独立换算 | 5 | 2026-09-18 |
| R1 数据依赖 | 新场景中独立判断CPU工作能否继续，并说明是否使用GPU结果 | 5 | 2026-09-18 |

二维候选卡的提升条件见 [[knowledge/candidates/2d-thread-warp-lane-mapping#转入 Canonical 的条件|验证条件]]；满足后合并至原执行层级正式卡，保留候选演进记录。新示例GPU编译与运行仍待环境，不提前算实验完成。

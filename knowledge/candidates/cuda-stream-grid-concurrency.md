# CUDA Stream and Grid Concurrency

- Status: 已验证，2026-08-04 提升为正式知识
- Evidence: `sessions/2026-08-03-gpu-hierarchy-review.md`, `sessions/2026-08-04-cuda-streams-events.md`
- Canonical: `knowledge/canonical/cuda-streams-events-and-timing.md`
- Last verified: 2026-08-04

## 提升前的候选理解

- 一次 kernel launch 对应一个 Grid；多次 kernel launch 产生多个 Grid。
- 同一 CUDA Stream 中的 kernel 按提交顺序执行，后提交的 Grid 不会越过前一个 Grid。
- 不同 Stream 中的 Grid 具有并发机会，但并发不是保证。
- 是否真正并发取决于数据依赖、SM/寄存器/shared memory 等剩余资源、kernel 特征和硬件能力。

## 提升前的验证缺口

- 只验证了“同一 Stream 保持提交顺序”。
- 尚未解释 CUDA Event 如何表达跨 Stream 依赖。
- 尚未通过 profiler 观察两个 Grid 的串行或并发执行。

## 验证清单（2026-08-04 已完成）

1. 根据多 Stream 代码判断可能的执行顺序和依赖关系。
2. 编写两个独立 kernel，比较同 Stream 与不同 Stream 的时间线。
3. 使用 profiler 验证资源充足与资源饱和时的并发现象。

## 转入 canonical 的条件（已满足）

- 能分析包含两个 Stream 和 Event 的最小代码；
- 完成至少一次时间线实验；
- 能解释“允许并发”为什么不等于“保证并发”。

## 验证结果

- 已分析两个 Stream 与中间 Event 的依赖图，并区分 `wait_event()`、`wait_stream()` 和 CPU 同步 API。
- 已完成中间 Event 与整条 Stream 等待实验，验证依赖范围不同且两个 wait 调用不阻塞 CPU。
- 已通过 PyTorch Profiler 观察两个 Stream 上 10 个 kernel 的时间线；存在部分重叠，但大型 GEMM 没有获得接近两倍的并行收益。

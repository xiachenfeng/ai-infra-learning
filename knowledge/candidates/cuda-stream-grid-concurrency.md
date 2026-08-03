# CUDA Stream and Grid Concurrency

- Status: 候选知识，尚未验证
- Evidence: `sessions/2026-08-03-gpu-hierarchy-review.md`
- Last discussed: 2026-08-03

## 候选理解

- 一次 kernel launch 对应一个 Grid；多次 kernel launch 产生多个 Grid。
- 同一 CUDA Stream 中的 kernel 按提交顺序执行，后提交的 Grid 不会越过前一个 Grid。
- 不同 Stream 中的 Grid 具有并发机会，但并发不是保证。
- 是否真正并发取决于数据依赖、SM/寄存器/shared memory 等剩余资源、kernel 特征和硬件能力。

## 尚未进入正式知识库的原因

- 只验证了“同一 Stream 保持提交顺序”。
- 尚未解释 CUDA Event 如何表达跨 Stream 依赖。
- 尚未通过 profiler 观察两个 Grid 的串行或并发执行。

## 需要完成的验证

1. 根据多 Stream 代码判断可能的执行顺序和依赖关系。
2. 编写两个独立 kernel，比较同 Stream 与不同 Stream 的时间线。
3. 使用 profiler 验证资源充足与资源饱和时的并发现象。

## 转入 canonical 的条件

- 能分析包含两个 Stream 和 Event 的最小代码；
- 完成至少一次时间线实验；
- 能解释“允许并发”为什么不等于“保证并发”。

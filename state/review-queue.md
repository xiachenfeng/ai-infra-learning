# Review Queue

| Knowledge Point | Reason | Priority | Review After |
|---|---|---:|---|
| GPU Execution Model | 间隔复测 Grid、Block、Thread、Warp 及 LLM 请求多对多映射 | 5 | 2026-08-10 |
| CUDA Tensor Lifetime and `record_stream()` | 已通过双侧 Stream、alias、手动 Event 与保守性迁移题；待完成最小 GPU 实验并决定是否提升为 canonical | 5 | 2026-08-09 |
| CUDA Event Timing | 复测预热、Event 区间、同步范围和批量/单次计时单位 | 5 | 2026-08-11 |
| CUDA Stream Concurrency | 根据 profiler 时间线计算重叠，并解释“允许并发”不等于充分并行或抢占 | 4 | 2026-08-11 |
| LLM Continuous Batching | 独立解释调度循环、权重复用与吞吐—延迟权衡 | 4 | 2026-08-10 |

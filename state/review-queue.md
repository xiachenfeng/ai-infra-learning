# Review Queue

| Knowledge Point | Reason | Priority | Review After |
|---|---|---:|---|
| GPU Execution Model | 间隔复测 Grid、Block、Thread、Warp 及 LLM 请求多对多映射 | 5 | 2026-08-10 |
| CUDA Stream Wait vs Synchronize | 曾把 `wait_event`、`wait_stream` 误认为 CPU 阻塞；闭卷分析等待对象与依赖范围 | 5 | 2026-08-07 |
| CUDA Tensor Lifetime and `record_stream()` | 闭卷分析两个侧 Stream 的登记、allocator Event 延迟回收和手动 Event 替代方案；完成最小 GPU 实验 | 5 | 2026-08-09 |
| CUDA Event Timing | 复测预热、Event 区间、同步范围和批量/单次计时单位 | 5 | 2026-08-11 |
| CUDA Stream Concurrency | 根据 profiler 时间线计算重叠，并解释“允许并发”不等于充分并行或抢占 | 4 | 2026-08-11 |
| LLM Continuous Batching | 独立解释调度循环、权重复用与吞吐—延迟权衡 | 4 | 2026-08-10 |

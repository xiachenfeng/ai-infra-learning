# Review Queue

| Knowledge Point | Reason | Priority | Review After |
|---|---|---:|---|
| Thread vs Warp Count | 曾把 256 个 Thread/8 个 Warp 误认为 8 个逻辑实例 | 5 | 2026-08-06 |
| GPU Execution Model | 间隔复测 Grid、Block、Thread、Warp 及 LLM 请求多对多映射 | 5 | 2026-08-10 |
| CUDA Stream Wait vs Synchronize | 曾把 `wait_event`、`wait_stream` 误认为 CPU 阻塞；闭卷分析等待对象与依赖范围 | 5 | 2026-08-07 |
| CUDA Event Timing | 复测预热、Event 区间、同步范围和批量/单次计时单位 | 5 | 2026-08-11 |
| CUDA Stream Concurrency | 根据 profiler 时间线计算重叠，并解释“允许并发”不等于充分并行或抢占 | 4 | 2026-08-11 |
| LLM Continuous Batching | 独立解释调度循环、权重复用与吞吐—延迟权衡 | 4 | 2026-08-10 |

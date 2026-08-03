# Review Queue

| Knowledge Point | Reason | Priority | Review After |
|---|---|---:|---|
| Thread vs Warp Count | 曾把 256 个 Thread/8 个 Warp 误认为 8 个逻辑实例 | 5 | 2026-08-06 |
| GPU Execution Model | 间隔复测 Grid、Block、Thread、Warp 及 LLM 请求多对多映射 | 5 | 2026-08-10 |
| CUDA Asynchronous Execution | 验证候选知识：独立区分 eager、异步提交、GPU 完成与 CPU 同步等待 | 5 | 2026-08-04 |
| CUDA Timing Experiment | 验证候选知识：比较无同步、仅前同步、前后同步和 CUDA Event 计时 | 5 | GPU 环境准备后 |
| CUDA Stream and Grid Concurrency | 验证不同 Stream 只是允许并发，并用 profiler 观察实际时间线 | 4 | GPU 环境准备后 |
| LLM Continuous Batching | 独立解释调度循环、权重复用与吞吐—延迟权衡 | 4 | 2026-08-10 |

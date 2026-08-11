# Review Queue

| Knowledge Point | Reason | Priority | Review After |
|---|---|---:|---|
| GPU Execution Model | 复测 kernel launch 对应 Grid、整 Grid 的同 Stream 顺序和跨 Stream Event 依赖 | 5 | 2026-08-12 |
| GPU Memory Hierarchy | 闭卷复测 Register、Shared Memory、L2、HBM 的延迟、容量和作用域；用指标区分数据复用与访问重排 | 5 | 2026-08-13 |
| CUDA Tiled Transpose and Bank Conflict | 从 `examples/cuda/tiled_transpose.cu` 复测 Block/tile 两层坐标交换、coalescing、同地址广播、同 bank 不同地址冲突和 32→33 padding；有 GPU 时编译并 profiler 验证 | 5 | 2026-08-13 |
| CUDA Tensor Lifetime and `record_stream()` | 官方文档和 allocator 源码说明已核验；待在 NVIDIA GPU 上完成三版本最小实验并决定是否提升为 canonical | 5 | 2026-08-12 |
| CUDA Event Timing | 复测预热、Event 区间、同步范围和批量/单次计时单位 | 5 | 2026-08-11 |
| CUDA Stream Concurrency | 根据 profiler 时间线计算重叠，并解释“允许并发”不等于充分并行或抢占 | 4 | 2026-08-11 |
| LLM Continuous Batching | 独立解释调度循环、权重复用与吞吐—延迟权衡 | 4 | 2026-08-10 |

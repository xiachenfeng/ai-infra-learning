# Learning Session

- Date: 2026-08-03 至 2026-08-04
- Topic: PyTorch CUDA Stream、Event、同步与性能计时
- Duration: 未记录
- Final confidence: 80/100

## Learning Goals

- 区分 PyTorch eager execution、CUDA 异步执行和同步等待。
- 理解同一 Stream 顺序、跨 Stream Event 依赖和各类同步 API 的范围。
- 在真实 GPU 上验证正确计时、精确依赖和多 Stream 时间线。

## Environment

- PyTorch: 2.12.1+cu130
- CUDA runtime: 13.0
- GPU: NVIDIA GeForce RTX 3090
- Compute capability: 8.6

## Questions and Answers

- 正确判断 eager 表示运行到算子时立即提交，不保证 CUDA 计算已经完成。
- 正确说明同一 Stream 有序、不同 Stream 默认没有相对顺序。
- 正确识别 `.item()` 会使 CPU 等待结果，CPU 计时需要测量前后同步。
- 起初不清楚 `wait_event()` 与 `Event.synchronize()` 的区别，经依赖图和反事实题后能区分 GPU 侧等待与 CPU 阻塞。
- 两次误认为 `wait_stream()` 会阻塞 CPU；最小解释后通过阻塞 API 复测。
- 初始给 CUDA Event 计时添加不必要的 `end.wait_event(start)`；纠正后理解同一 Stream 已建立顺序。
- 初始将 100 次总提交时间与单次 Event 时间比较，误判为约 6 倍；统一单位后纠正为约 600 倍。
- 正确分析中间 Event：等待 B 的完成 Event 可确认 `a1`、`b1` 完成，但 `a2` 可能未完成。
- 正确从 profiler 时间戳计算第一对 kernel 重叠约 0.086 ms，并判断大型 GEMM 不会因增加 10 个 Stream 获得 10 倍吞吐。

## Experiments

### CUDA Timing

100 次 4096×4096 矩阵乘法：

- CPU submission only: 0.947 ms
- Wall time until done: 579.428 ms
- CPU synchronized timer: 591.462 ms
- CUDA Event timer: 582.912 ms
- CUDA Event per matmul: 5.829 ms

### Dependency Scope

- `wait_event()` CPU 调用：0.016 ms；CPU 等到中间 Event 路径完成：113.386 ms；此时 Stream A 未全部完成。
- `wait_stream()` CPU 调用：0.064 ms；CPU 等到完整依赖路径完成：580.694 ms；此时 Stream A 已完成。

### Profiler Timeline

- CUDA Stream IDs: 21、25
- Kernel count: 10
- Cross-stream overlap pairs reported: 9
- 第一对 kernel 重叠约 0.086 ms。
- kernel 持续时间总和约 7.7 ms，整体跨度约 6.962 ms，只呈现部分重叠。

## Evaluation

用户已经能将 Stream 顺序、Event 精确位置、GPU 依赖和 CPU 同步用于代码分析，并通过真实实验验证结论，达到应用和分析水平。两个主要薄弱点是 wait 与 synchronize 的等待者，以及 benchmark 总时间/单次时间单位；两者均在本次完成当场复测，但仍需间隔复习。对 profiler 的“重叠”判断正确，但曾使用“抢占”一词，尚不能据此推断硬件抢占机制。

## Mastery Changes

- CUDA Asynchronous Execution: 1 → 3
- CUDA Stream and Grid Concurrency: 1 → 3

## Knowledge Extraction

- 新增正式知识：`knowledge/canonical/cuda-streams-events-and-timing.md`
- 候选 `knowledge/candidates/cuda-asynchronous-execution.md` 已验证并标记提升。
- 候选 `knowledge/candidates/cuda-stream-grid-concurrency.md` 已验证并标记提升。
- `knowledge/candidates/llm-continuous-batching.md` 未变化：本次没有独立设计或 benchmark batching scheduler。
- 未沉淀 `record_stream()`、Stream priority、CUDA Graph 和 Nsight：本次没有讲解、测试或实验这些内容。

## Files Updated

- `knowledge/canonical/cuda-streams-events-and-timing.md`
- `knowledge/candidates/cuda-asynchronous-execution.md`
- `knowledge/candidates/cuda-stream-grid-concurrency.md`
- `sessions/2026-08-04-cuda-streams-events.md`
- `state/current.md`
- `state/mastery.md`
- `state/mistakes.md`
- `state/review-queue.md`
- `state/answer-history.csv`
- `inbox.md`
- `weekly-reviews/2026-W32.md`

## Next Review

- 2026-08-06：Thread 与 Warp 数量间隔复测。
- 2026-08-07：闭卷分析 `wait_event()`、`wait_stream()` 与 synchronize API。
- 2026-08-11：复测 CUDA Event 计时和多 Stream profiler 时间线。
- 下一学习任务：多 Stream Tensor 生命周期与 `record_stream()`，随后进入 GPU memory hierarchy。

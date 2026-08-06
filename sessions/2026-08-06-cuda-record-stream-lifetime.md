# Learning Session

- Date: 2026-08-05 至 2026-08-06
- Topic: Thread/Warp 间隔复测与跨 Stream Tensor 生命周期
- Duration: 未记录
- Final confidence: 90/100

## Learning Goals

- 间隔复测 Thread 逻辑实例数、Warp 数和部分有效 Warp；
- 区分跨 Stream 数据依赖与 Tensor 显存生命周期；
- 理解 `record_stream()`、allocator Event 延迟回收和手动同步方案；
- 分析等待位置对显存安全与并发重叠的影响。

## Questions Asked

1. 计算 3 个 Block、每 Block 100 个 Thread 的逻辑 Thread、Warp 和部分有效 Warp；
2. 解释 Warp 为什么不能跨 Block，并完成无 `__syncthreads()` 的反事实题；
3. 分析 `del x`、侧 Stream 未完成读取和显存块复用之间的竞态；
4. 区分 `s1.wait_stream(s0)` 与 `x.record_stream(s1)`；
5. 比较过早反向等待和释放前等待的并发性；
6. 解释手动同步后，创建 Stream 上复用显存的写入为什么安全；
7. 推导引用计数、allocator 回收流程、内部 CUDA Event 和显存可复用的顺序；
8. 双侧 Stream 同时使用同一 Tensor 的登记题未作答，转入复习队列。

## My Answers

- 正确计算每个 100 Thread Block 有 4 个 Warp、3 个 Block 共 12 个 Warp；最初把最后一个 Warp 的有效 Thread 误算为 6，经引导后纠正为 4。
- 最初用“Block 内可以同步”解释 Warp 不跨 Block；在最小解释和反事实题后，能说明 Block 是 Warp 的硬件分组边界。
- 独立正确区分 512 个 Thread 逻辑实例与 16 个 Warp 硬件执行分组。
- 正确排列显存复用竞态：`del x → allocator 复用 → 新 Tensor 覆盖 → 侧 Stream 读取`。
- 能判断创建 Stream 在释放前等待侧 Stream 可以保证安全，并在复测中正确指出延迟等待保留更多并发机会。
- 最初不清楚 `wait_stream()` 与 `record_stream()` 的区别；经匹配题后能识别前者管理执行顺序、后者登记 allocator 生命周期。
- 正确说明 `record_stream()` 不阻塞 CPU，并最终正确选择延迟回收顺序。

## Evaluation

Thread/Warp 间隔复测通过，GPU Execution Model 保持掌握度 3。用户能够独立区分逻辑 Thread 数和硬件 Warp 数，并在解释后通过 Block 边界反事实题。

跨 Stream Tensor 生命周期达到掌握度 2：用户能解释数据就绪与显存生命周期的区别，能分析 allocator 延迟回收和手动同步的安全性，也能判断等待位置对并发的影响。但核心机制经过多轮引导才稳定，双侧 Stream 迁移题和独立 GPU 实验尚未完成，不能评为应用分析级或写入 Canonical。

## New Knowledge

- `wait_stream()` 约束 Stream 后续工作的执行顺序，解决数据就绪；
- `record_stream()` 登记 Tensor 显存被侧 Stream 使用，解决 Python 引用消失后的延迟复用；
- 最后一个 Storage 引用消失先触发 allocator 回收流程，内部 Event 完成后显存块才从 pending 变为可复用；
- 手动把侧 Stream 完成位置同步回创建 Stream 可以替代 `record_stream()`，但等待放得过早会损失并发；
- `record_stream()` 的回收位置可能覆盖侧 Stream 中与 Tensor 无关的既有工作，因此存在显存复用延迟和可预测性成本。

## Mistakes and Gaps

- 部分 Warp 的有效 Thread 余数计算错误；
- 把 Block 同步范围误当成 Warp 不跨 Block 的根本原因；
- 一度把有序的双向 `wait_stream()` 误判为死锁；
- 初始不清楚 `wait_stream()` 与 `record_stream()` 的职责边界；
- 一度把 GPU Event 完成表述为解除 Python 引用；
- 未完成两个侧 Stream 都使用同一 Tensor 时的登记分析；
- 尚未运行 `record_stream()` 相关真实 GPU 实验。

## Mastery Changes

- GPU Execution Model: 保持 3，完成 2026-08-06 间隔复测；
- CUDA Tensor Lifetime Across Streams: 新增 2。

## Knowledge Extraction

- Knowledge Candidate：新增 `knowledge/candidates/cuda-record-stream-and-tensor-lifetime.md`。
  - 依据：形成了可复用的 allocator/Event 生命周期模型，但核心机制主要在引导后掌握，双侧 Stream 迁移题与独立实验未完成。
- No Knowledge Change：`knowledge/canonical/gpu-execution-hierarchy.md`。
  - 依据：本次 Thread/Warp 仅完成复习和纠错，已有 canonical 内容仍然准确完整，没有新的机制性结论。

## Files Updated

- `knowledge/candidates/cuda-record-stream-and-tensor-lifetime.md`
- `sessions/2026-08-06-cuda-record-stream-lifetime.md`
- `state/current.md`
- `state/mastery.md`
- `state/mistakes.md`
- `state/review-queue.md`
- `state/answer-history.csv`
- `weekly-reviews/2026-W32.md`
- `knowledge/canonical/cuda-streams-events-and-timing.md`（仅更新候选状态交叉引用）

## Next Review

- 2026-08-07：复测 wait API 与 synchronize API 的等待对象和范围；
- 2026-08-09：完成双侧 Stream 生命周期题和 `record_stream()` 最小实验；
- 2026-08-10：复测完整 GPU 执行层级和 LLM 请求多对多映射。

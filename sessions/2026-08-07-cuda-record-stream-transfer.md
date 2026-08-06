# Learning Session

- Date: 2026-08-07
- Topic: `record_stream()` 迁移复测、别名 Storage 生命周期与手动 Event 替代方案
- Duration: 未记录
- Final confidence: 未提供

## Learning Goals

- 闭卷复测 `event.record()`、`wait_event()` 与 `synchronize()` 的等待对象和 CPU/GPU 关系；
- 分析两个侧 Stream 同时使用同一 Tensor 时的 `record_stream()` 登记要求；
- 理解 `record_stream()` 的释放时边界、view alias 共享 Storage、手动 Event 替代方案和保守性成本。

## Questions Asked

1. 判断 `event.record(s0)`、`s1.wait_event(event)`、`s1.synchronize()` 哪些阻塞 CPU，以及 `wait_event()` 等待对象；
2. 分析同一 Tensor 被 `s1`、`s2` 两个侧 Stream 读取时需要登记哪些 Stream；
3. 判断只登记 `s1` 时，`s2` 读取的风险；
4. 分析 `record_stream()` 后、`del x` 前继续在 recorded Stream 上提交使用是否受保护；
5. 分析 `del x` 后才提交的使用是否受同一次释放流程保护；
6. 分析 `x.view()` 产生的别名与共享 Storage 的最后引用；
7. 判断在 `x` 或 `alias_x` 任一别名上调用 `record_stream()` 是否能保护同一块 Storage；
8. 比较手动 Event 替代方案中 Event 放在最后一次使用前后的位置差异；
9. 分析手动 Event 等待位置对 `s0` 独立工作与 `s1` 使用 `x` 的并发重叠影响；
10. 综合诊断混合 `wait_stream()`、`record_stream()`、view alias 与独立工作的一段代码。

## My Answers

- 正确区分 `event.record()` 和 `wait_event()` 为队列操作，`synchronize()` 为 CPU 阻塞等待；能说明 `wait_event()` 等待 Event 之前的生产 Stream 工作。
- 正确判断两个侧 Stream 都读取同一 Tensor 时，`wait_stream()` 只解决数据就绪，不保护 `del x` 后的显存生命周期；需要分别 `record_stream(s1)` 和 `record_stream(s2)`。
- 正确指出只登记 `s1` 时最多保护 `s1`，`s2` 可能读到被复用后覆盖的数据。
- 正确说明 `record_stream()` 不是精确位置依赖，而是 Storage 对 Stream 的生命周期登记；保护边界取决于 Tensor 释放时 recorded Stream 上已排队的工作。
- 正确判断释放后才提交的后续使用不会被此前释放流程保护。
- 初答误认为 `del x` 会触发共享 Storage 回收；经引导后意识到 `alias_x` 仍持有同一 Storage 引用。
- 正确判断 `x.record_stream(s1)` 可以保护 `alias_x` 读取的同一块共享 Storage，因为登记对象是 Storage 而非变量名。
- 正确选择手动 Event 应记录在侧 Stream 对 Storage 的最后一次使用之后。
- 正确判断释放前等待比过早等待更能保留并发重叠；经追问补全 `s0.wait_event(done)` 不阻塞 CPU，但会让 `s0` 后续 GPU 工作等待 `done`。
- 综合诊断题通过：能区分数据就绪、显存生命周期、漏登侧 Stream 和 `record_stream()` 不会在调用处过早串行化独立工作。

## Evaluation

CUDA Tensor Lifetime Across Streams 从掌握度 2 提升到 3。用户已经能把 `record_stream()`、手动 Event、双侧 Stream 和 view alias 用于代码级故障分析，也能解释保守性和并发权衡。

暂不提升到 4 或 canonical：本次仍未运行最小 GPU 实验，也未独立追踪 PyTorch native allocator 源码路径。下一步需要用实验或源码证据验证显存复用和 pending block 行为。

## New Knowledge

- `record_stream()` 不是精确位置依赖，而是 Storage 对 Stream 的生命周期登记；
- 一次释放触发的保护范围取决于释放时 recorded Stream 上已经排队的工作，不覆盖释放之后才提交的使用；
- `record_stream()` 绑定的是 Storage 与 Stream 的关系，不是变量名与 Stream 的关系；
- `del` 某个 Tensor 变量不等于释放显存，只有共享 Storage 的最后一个引用消失才进入 allocator 回收流程；
- 手动 Event 更精准，但必须放在侧 Stream 对 Storage 的最后一次使用之后；
- `record_stream()` 更保守，因为释放时 recorded Stream 上已排队的无关工作也可能延迟显存复用；
- 手动 Event 的等待点应尽量靠近生命周期释放边界，避免提前串行化无关的独立 GPU 工作。

## Mistakes and Gaps

- 起初把 `del x` 误认为共享 Storage 的最后引用释放；
- 对 `s0.wait_event(done)` 的影响需要追问后补全：它通常不阻塞 CPU，但会约束 `s0` 后续 GPU 工作的执行顺序；
- 尚未运行 `record_stream()` 最小实验；
- 尚未追踪 PyTorch native allocator 源码中的 `record_stream()` 和 pending block 释放路径。

## Mastery Changes

- CUDA Stream Wait vs Synchronize：间隔复测通过，保持掌握度 3；
- CUDA Tensor Lifetime Across Streams：2 → 3。

## Knowledge Extraction

- Knowledge Candidate：更新 `knowledge/candidates/cuda-record-stream-and-tensor-lifetime.md`。
  - 依据：本次产生了可复用的机制结论，并通过多道迁移题验证；但尚无真实 GPU 实验或源码追踪，因此仍为 Candidate。
- No Knowledge Change：`knowledge/canonical/cuda-streams-events-and-timing.md`。
  - 依据：本次 wait/synchronize 是复测，已有 canonical 内容仍然准确完整，没有新的机制性修订。

## Files Updated

- `knowledge/candidates/cuda-record-stream-and-tensor-lifetime.md`
- `sessions/2026-08-07-cuda-record-stream-transfer.md`
- `state/current.md`
- `state/mastery.md`
- `state/mistakes.md`
- `state/review-queue.md`
- `state/answer-history.csv`
- `weekly-reviews/2026-W32.md`

## Next Review

- 2026-08-09：完成 `record_stream()` 最小 GPU 实验，对比缺少登记、使用 `record_stream()` 和手动 Event 三种方案；
- 实验或源码追踪通过后，考虑将 `cuda-record-stream-and-tensor-lifetime` 从 Candidate 提升为 Canonical；
- 随后进入 GPU memory hierarchy。

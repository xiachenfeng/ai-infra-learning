# Learning Session

- Date: 2026-08-09
- Topic: `record_stream()` 实验推演、官方核验与 GPU Memory Hierarchy 入门
- Duration: 未记录
- Final confidence: 未提供

## Learning Goals

- 设计缺少登记、使用 `record_stream()` 和手动 Event 三种显存复用实验；
- 区分地址复用、实际显存访问、结果异常和代码安全性；
- 用官方文档和 allocator 源码说明核验 `record_stream()` 机制；
- 开始 GPU memory hierarchy，理解算术强度、存储作用域和跨 Block 共享。

## Questions Asked

1. 分析 `data_ptr()` 复用是否等价于竞态已经发生；
2. 比较 `record_stream()` pending block 与手动 Event 提前同址复用；
3. 诊断新 Tensor 改在 `s2` 写入时 Event 等待的 Stream 和位置；
4. 区分创建 Stream 到消费者 Stream、旧 Tensor 最后使用到新写入两条依赖边；
5. 判断 HBM 大量读取 kernel 的瓶颈并比较算术强度；
6. 区分 register、shared memory、L2 和 HBM 的作用域；
7. 用两个 kernel 展示不同 Block 通过 global memory 共享数据；
8. 分析 kernel、Grid、Block、Thread 层级与同/跨 Stream Grid 顺序。

## My Answers

- 正确说明地址复用只表示 allocator 返回同一显存块，不等价于结果已经错误；危险代码一次运行正常也不能证明安全。
- 能解释 `record_stream()` 使 block 在旧工作未完成时保持 pending，而手动 Event 可以让地址先复用、实际写入等待旧读取完成。
- 正确将 Event 等待放到真正执行覆盖写入的 `s2`，并保留旧 `s1` 读取到新写入的依赖。
- 初始只检查 `torch.empty()` 是否写显存，忽略创建 Stream 语义；经官方资料核验和迁移题后，补上 `s2.wait_stream(s0)`。
- 正确识别低算术强度 kernel 更可能受 HBM 带宽限制，理解 shared memory 通过 Block 内复用减少 HBM traffic。
- 能说明 register 线程私有、shared memory 属于单个 Block、L2 可跨 Block 自动缓存、global memory 地址可被不同 Block 访问。
- 正确判断 `__syncthreads()` 不能同步不同 Block；能计算 `kernel<<<8, 256>>>` 为一个 Grid、8 个 Blocks、2048 个 Threads。
- 能用同 Stream kernel 顺序或 Event 建立 producer Grid 到 consumer Grid 的依赖。

## Evaluation

CUDA Tensor Lifetime Across Streams 保持掌握度 3。迁移分析和机制表达已稳定，且官方资料支持核心结论；由于本机没有 PyTorch/CUDA，尚无真实 GPU 实验，不提升到 4。

GPU Memory Hierarchy 从 0 提升到 2。已经能识别各层作用域、HBM 带宽瓶颈和片上复用，但尚未闭卷完成延迟排序，也未进入 bank conflict、coalescing、occupancy 等应用分析。

## Mistakes and Gaps

- 一度认为 `torch.empty()` 不写显存即可删除创建 Stream 到消费者 Stream 的依赖，忽略 allocator 的创建 Stream 语义；当场复测通过。
- 对算术强度的解释最初较简略，需要继续用 operations/byte 表达。
- `register -> shared memory -> L2 -> HBM` 的延迟排序尚未闭卷作答完成。
- `record_stream()` 三版本真实 GPU 实验仍未运行。

## Mastery Changes

- GPU Memory Hierarchy：0 → 2；
- GPU Execution Model：保持 3，补充 kernel launch、Grid 级顺序和跨 Stream Event 证据；
- CUDA Kernel：保持 2，增加 producer/consumer kernel 阅读证据；
- CUDA Tensor Lifetime Across Streams：保持 3，增加实验推演和官方核验证据。

## Knowledge Extraction

- Knowledge Candidate：更新 `knowledge/candidates/cuda-record-stream-and-tensor-lifetime.md`。
  - 依据：加入地址复用与实际写入分离、创建 Stream/消费者 Stream 双依赖边和官方资料核验证据；真实 GPU 实验仍缺失，因此保持 Candidate。
- No Knowledge Change：GPU Memory Hierarchy。
  - 依据：本次是概念入门，层级延迟排序和关键优化机制尚未完成，不足以形成稳定知识卡。

## Files Updated

- `knowledge/candidates/cuda-record-stream-and-tensor-lifetime.md`
- `sessions/2026-08-09-record-stream-and-memory-hierarchy.md`
- `state/current.md`
- `state/mastery.md`
- `state/mistakes.md`
- `state/review-queue.md`
- `state/answer-history.csv`

## Next Review

- 2026-08-11：闭卷复测 GPU memory hierarchy 的延迟、容量和作用域；
- 2026-08-12：在可用 NVIDIA GPU 环境运行 `record_stream()` 三版本最小实验；
- 2026-08-12：复测同 Stream Grid 顺序和跨 Stream Event 依赖。

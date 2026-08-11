# Learning Session

- Date: 2026-08-09 至 2026-08-11
- Topic: GPU Memory Hierarchy、Coalescing、Shared Memory Bank 与 Tiled Transpose
- Duration: 未记录
- Final confidence: 未提供

## Learning Goals

- 建立 Register、Shared Memory、L2、HBM 的延迟、容量和作用域模型；
- 理解 Shared Memory 的数据复用和访问重排两类价值；
- 用 Warp 地址分布解释 global-memory coalescing 和物理事务；
- 阅读 tiled transpose，理解 row-major 映射、Block/tile 两层转置和 padding。

## Questions Asked

1. 闭卷排序存储层级并说明作用域；
2. 计算 Shared Memory tile 复用对 HBM 读取量的影响；
3. 判断无复用时 Shared Memory staging 是否一定更快；
4. 比较连续与 stride-32 global-memory 访问的 coalescing；
5. 用 row-major 矩阵和 tiled transpose 分析连续读写；
6. 区分 HBM 有用字节、逻辑 load/store 和物理内存事务；
7. 区分 Shared Memory 数据复用与访问重排，并用 profiler 指标迁移；
8. 计算 Shared Memory bank 映射，区分广播与 bank conflict；
9. 阅读 padded tiled-transpose 的 `threadIdx`、`blockIdx` 和 tile 坐标。

## My Answers

- 经逐层引导后正确完成 `Register → Shared Memory → L2 → HBM` 的延迟与容量排序，并将 Register 校准为 Thread 私有；
- 正确计算 256 个 float 复用 8 次时，HBM 读取从 2048 降为 256，即原来的 `1/8`；
- 能判断无复用且不改善访问模式时 Shared Memory staging 可能更慢；
- 正确判断 row-major 同一行的连续列具有更好 coalescing，并计算转置优化后连续输出位置；
- 初始多次把 tiled transpose 的收益解释为减少读取，最终能根据 profiler 指标区分复用和访问重排；
- 最初把 HBM 访问称为中断，复测后能说明减少的是物理内存事务；
- 正确完成 bank 模 32 的基础计算，但把 stride-32 不同地址误认为同地址广播；对比复测后纠正；
- 对 `threadIdx.x/y`、`blockDim`、row-major 和 Block 坐标交换主动要求完整上下文，当前仍需继续学习保存的转置代码。

## Evaluation

GPU Memory Hierarchy 保持掌握度 2。层级、容量、作用域、基本 coalescing 和复用计算已经能够解释，并通过 profiler 指标迁移题；但 tiled transpose 的两层坐标交换与 padding bank 映射尚未独立完成，且缺少真实 GPU profiler 证据。

CUDA Kernel 保持掌握度 2。能够阅读完整 kernel、计算局部一维地址并理解基本 Thread/Block 坐标；尚未独立编写、编译和运行 CUDA kernel。

估算 Phase 1 完成约 65%，整个 24 周课程完成约 11%。依据是 GPU 执行、异步 Stream/Event 和基础 profiler 已完成验证，Memory Hierarchy 已进入应用代码但尚未实机验证，系统基础部分仍有缺口，Phase 2～6 尚未正式进入。

## New Knowledge

- 延迟从低到高、容量从小到大的第一版模型均为 `Register → Shared Memory → L2 → HBM`；
- Tile 是逻辑数据/计算分块，可在多个物理存储层级间搬运；
- Shared Memory 可以通过复用降低 HBM 字节，也可以通过访问重排改善 coalescing；
- Coalescing 不必减少逻辑访存数量，但可减少物理事务和无效字节；
- tiled transpose 需要交换全局 tile 坐标和 tile 内局部坐标；
- bank 编号由地址映射得到，同 bank 不同地址会冲突，完全同地址读取可能广播；padding 可改变行跨度和 bank 映射。

## Mistakes and Gaps

- 多次用“中断”描述普通 HBM 访问；
- 多次将 tiled transpose 的访问重排误认为数据复用；
- 混淆完整 word 地址与取模后的 bank 编号；
- 尚未闭卷完成 input/output tile 坐标交换；
- 尚未独立推导 `tile[32][33]` 如何消除 stride-32 bank conflict；
- 当前环境没有 `nvcc`，保存的代码仅通过 CPU 索引模拟，未实机编译和 profiler 验证。

## Mastery Changes

- GPU Memory Hierarchy：保持 2，证据扩展到 coalescing、Shared Memory 两类用途和 bank 基础；
- CUDA Kernel：保持 2，增加 tiled-transpose 代码阅读证据。

## Knowledge Extraction

- Knowledge Candidate：新增 `knowledge/candidates/gpu-memory-hierarchy-and-tiled-transpose.md`。
  - 依据：形成了可复用的层级、coalescing、复用/重排、bank 与 tiled-transpose 机制模型，并保存完整代码；但独立解释和真实 GPU 实验尚未通过。
- No Knowledge Change：现有 CUDA Stream/Event Canonical。
  - 依据：本次未产生 Stream/Event 机制的新结论，仅沿用已验证的异步提交模型。

## Files Updated

- `examples/cuda/tiled_transpose.cu`
- `inbox.md`
- `knowledge/candidates/gpu-memory-hierarchy-and-tiled-transpose.md`
- `sessions/2026-08-11-gpu-memory-hierarchy-and-tiled-transpose.md`
- `state/current.md`
- `state/mastery.md`
- `state/mistakes.md`
- `state/review-queue.md`
- `state/answer-history.csv`

## Next Review

- 2026-08-13：闭卷复测存储层级与 Shared Memory 两类用途；
- 2026-08-13：继续保存的 tiled-transpose 代码，完成 Block/tile 坐标和 padding bank 推导；
- 有 NVIDIA GPU 时：编译运行并 profiler 对比 naive、unpadded 和 padded 版本。

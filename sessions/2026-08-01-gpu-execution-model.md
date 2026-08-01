# Learning Session

- Date: 2026-08-01
- Topic: GPU 执行模型入门
- Duration: 未记录

## Learning Goals

- 理解 kernel 从 CPU 提交到 GPU 执行的基本过程。
- 理解 Grid、Block、Warp、Thread 的关系。
- 理解 Block 同步边界、Warp Divergence 和 CUDA 异步执行。

## Questions Asked

1. 根据 Block 数和每个 Block 的线程数计算 Thread 与 Warp 数量。
2. 使用 `blockIdx.x`、`blockDim.x` 和 `threadIdx.x` 计算全局线程索引。
3. 计算覆盖给定数据规模所需的 Block 数和空闲 Thread 数。
4. 判断条件分支是否导致 Warp Divergence。
5. 判断 `__syncthreads()` 能否跨 Block 同步。
6. 判断 PyTorch CUDA 操作计时是否需要同步。
7. 综合解释 CPU、kernel、Grid、Block、Warp、Thread 和同步边界。

## My Answers

- 正确计算 2 个 Block、每 Block 64 个 Thread 时共有 128 个 Thread 和 4 个 Warp。
- 正确计算全局线程索引 `256 * 3 + 10 = 778`。
- 正确计算处理 1000 个元素需要 4 个 Block、1024 个 Thread，其中 24 个不处理有效元素。
- 正确判断按 128 为边界的分支不会造成 Warp 内路径分裂。
- 正确指出不同 Block 不能通过 `__syncthreads()` 同步。
- 最初误以为只在计时前同步即可测量 GPU 计算时间，后理解 CUDA 工作是异步提交的。
- 综合回答能够正确描述 Grid、Block、Thread 是编程模型，Warp 是硬件执行分组。

## Evaluation

已掌握 GPU 执行模型的核心层级关系，能够完成基础线程索引和 Warp 数量计算，也能判断简单的 Warp Divergence 与 Block 同步边界。对 PyTorch eager execution 与 CUDA asynchronous execution 的区别经过纠正后能够理解，但仍需通过实际计时实验巩固。

## New Knowledge

- 一次 kernel launch 产生一个 Grid，Grid 包含多个 Block，Block 包含多个 Thread。
- NVIDIA GPU 通常将同一 Block 内每 32 个 Thread 组成一个 Warp 执行。
- Block 是 shared memory 和 `__syncthreads()` 的协作边界。
- 同一 Warp 内分支路径不同会导致 Warp Divergence。
- PyTorch eager execution 表示立即提交算子，不表示 CPU 会同步等待 CUDA 算子完成。

## Mistakes and Gaps

- 曾把“CPU 等待 GPU 完成”表述成“同步使 GPU 完成计算”。GPU 会独立执行完成，同步只是建立等待和可见性边界。
- 尚未在真实 GPU 环境中观察异步计时、kernel 和显存行为。
- 尚未学习 SM 调度、occupancy 和 GPU memory hierarchy。

## Mastery Changes

- GPU Execution Model: 0 → 3
- CUDA Kernel: 0 → 2

## Files Updated

- `sessions/2026-08-01-gpu-execution-model.md`
- `state/current.md`
- `state/mastery.md`
- `state/mistakes.md`
- `state/review-queue.md`
- `state/answer-history.csv`

## Next Review

- 下次学习开始时：先不查资料复述 Warp、Grid、Block、Thread 的关系与区别。
- 2026-08-04：复习 Warp Divergence、Block 同步边界和 CUDA 异步执行。
- 下一学习环节：完成 PyTorch GPU 计时观察实验。

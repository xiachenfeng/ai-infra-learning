# GPU Execution Hierarchy

- Status: 正式知识
- Evidence: `sessions/2026-08-01-gpu-execution-model.md`
- Last verified: 2026-08-01

## 一句话定义

一次 GPU kernel launch 创建一个 Grid；Grid 由多个 Block 组成，Block 包含多个 Thread，而 NVIDIA GPU 会在每个 Block 内把 Thread 按通常 32 个一组组织成 Warp 执行。

## 它解决什么问题

这套层级让同一个 kernel 扩展到大量数据：每个 Thread 处理一小份工作，Block 提供局部协作边界，Grid 表示一次 launch 的完整工作范围。

## 前置知识

- CPU 负责发起 GPU 工作。
- Kernel 是由大量 GPU Thread 执行的函数。
- 本卡只讨论一维 launch；二维、三维索引是同一模型的扩展。

## 核心机制

### Grid、Block、Thread

- Grid：一次 kernel launch 创建的全部 Thread 集合。
- Block：Grid 的分块，是 shared memory 和局部同步的重要边界。
- Thread：kernel 的一个逻辑执行实例，通过索引选择要处理的数据。

程序员直接指定 Grid 和 Block 的维度，由此确定 Thread 数量。

### Warp

Warp 是 NVIDIA GPU 的硬件执行分组，不是程序员在 Grid 与 Block 之间额外创建的对象。同一 Block 内连续的 Thread 通常每 32 个组成一个 Warp。

准确的关系是：

```text
Grid → Block → Thread
          └─ Block 内的 Thread 被硬件划分为 Warp
```

### Block 同步边界

同一 Block 内的 Thread 可以通过 `__syncthreads()` 建立屏障。不同 Block 可能位于不同 SM，也不能假设执行先后顺序，因此普通 kernel 中不能用 `__syncthreads()` 跨 Block 同步。

### Warp Divergence

同一 Warp 内的 Thread 选择不同控制流路径时，会产生 Warp Divergence。GPU 需要分别执行各条路径，并暂时屏蔽不走当前路径的 Thread；结果可以保持正确，但资源利用率可能下降。

只有同一个 Warp 内发生路径分裂才构成这一问题。若分支边界与 Warp 边界对齐，每个 Warp 内部仍走统一路径，就不会产生对应的分支发散。

## 系统流程

```text
CPU 发起 kernel launch
        ↓
创建一个 Grid
        ↓
Grid 划分为多个 Block
        ↓
Block 中包含多个 Thread
        ↓
硬件把 Block 内的 Thread 组成 Warp 执行
```

## 复杂度与性能影响

- 总 Thread 数至少要覆盖数据规模，超出的 Thread 必须经过边界检查。
- Thread 数不是 32 的整数倍时，最后一个 Warp 可能只有部分有效 Thread。
- 同一 Warp 内的分支发散会降低执行资源利用率。

## 最小示例

```cpp
kernel<<<2, 64>>>();
```

它创建 2 个 Block，每个 Block 有 64 个 Thread，共 128 个 Thread。若 Warp 大小为 32，则每个 Block 有 2 个 Warp，总计 4 个 Warp。

一维全局索引与边界检查：

```cpp
int i = blockIdx.x * blockDim.x + threadIdx.x;
if (i < n) {
    output[i] = input[i] * 2;
}
```

处理 1000 个元素、每个 Block 256 个 Thread 时：

```cpp
int blocks = (1000 + 256 - 1) / 256;  // 4
```

实际启动 1024 个 Thread，最后 24 个不处理有效元素。

## 常见误解

- Warp 不是程序员显式 launch 的层级，而是硬件对 Block 内 Thread 的执行分组。
- 所有 Thread 本来就运行同一份 kernel 代码；Warp Divergence 讨论的是同一 Warp 内是否选择不同控制流路径。
- `__syncthreads()` 只能同步同一 Block 内的 Thread。
- 多启动的 Thread 不能直接访问超出数据范围的元素，必须做边界检查。

## 与相关技术的区别

- Grid、Block、Thread 属于 CUDA 编程模型。
- Warp 属于 NVIDIA GPU 执行模型。
- Block 是协作和同步边界；Warp 是硬件发射与执行线程的分组。

## 代码或实验

本次完成了索引、Thread 数和 Warp 数的推导，尚未运行真实 CUDA/PyTorch GPU 实验。

## 我曾经答错的地方

本主题的层级、索引和同步范围问题均回答正确。用户主动要求下次再复习四个概念的关系与区别，以验证长期保持情况。

## 掌握证据

- 正确计算 Thread、Warp 和空闲 Thread 数量。
- 正确使用 `blockIdx.x * blockDim.x + threadIdx.x` 计算全局索引。
- 正确判断简单的 Warp Divergence。
- 正确指出不同 Block 不能通过 `__syncthreads()` 同步。
- 能用自己的语言复述 Grid、Block、Warp、Thread 的关系。

## 待验证内容

- 间隔复测后能否不查资料准确区分四个概念。

## 参考资料

待后续学习时补充 NVIDIA CUDA Programming Guide 对应章节。

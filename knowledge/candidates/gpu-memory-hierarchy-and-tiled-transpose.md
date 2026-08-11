# GPU Memory Hierarchy、Coalescing 与 Tiled Transpose

- Status: 候选知识，待独立复测与 GPU 实验
- Evidence: `sessions/2026-08-11-gpu-memory-hierarchy-and-tiled-transpose.md`
- Last discussed: 2026-08-11
- Code: `examples/cuda/tiled_transpose.cu`

## 一句话定义

GPU memory hierarchy 用容量换取延迟和带宽；tiling 把大数据分块搬到片上存储，通过数据复用或访问重排减少 HBM 流量与物理内存事务。

## 它解决什么问题

GPU 算力远高于片外 HBM 的单次访问速度。若 Warp 地址分散或同一数据被反复从 HBM 读取，执行单元会因数据供应不足而停顿。Register、Shared Memory 和 Cache 提供更近的数据路径，但容量和作用域受限。

## 前置知识

- Grid、Block、Warp、Thread 的层级；
- row-major 二维数组的一维索引 `row * width + col`；
- 同一 Warp 中线性 Thread 编号和 `threadIdx.x` 的变化；
- CUDA kernel 与 Stream 的异步提交模型。

## 核心机制

典型延迟从低到高、容量从小到大均可用以下层级建立第一版模型：

```text
Register → Shared Memory → L2 Cache → HBM
```

- Register 通常为 Thread 私有；
- Shared Memory 每个 Block 有独立实例，供 Block 内线程显式协作；
- L2 是 GPU 芯片上的硬件管理共享缓存，可服务多个 SM/Block；
- HBM 是设备显存，不应按“进程之间的存储”理解。

L2 miss 后由 GPU 内存子系统继续向内存控制器和 HBM 发请求，普通访存不需要 CPU 中断处理。

## 系统流程

```text
HBM 中的大矩阵
      ↓ 合并读取
Shared Memory tile
      ↓ 复用或重排
Register / 执行单元
      ↓ 合并写回
HBM 中的输出矩阵
```

Tile 是数据和计算的逻辑分块，不是一种固定物理内存。同一个逻辑 tile 可以依次存在于 HBM、Shared Memory 和 Register 中。

## 复杂度与性能影响

Shared Memory 的收益至少有两类：

1. 数据复用：一个元素从 HBM 读取一次后参与多次计算，降低 HBM 字节数并提高算术强度；
2. 访问重排：HBM 读写元素数不变，但把 Warp 的跨步地址变成连续地址，减少物理内存事务并提高有效带宽。

若数据没有复用，也没有改善 global-memory 访问模式，Shared Memory staging 会增加读写、同步和片上资源占用，可能更慢。

## 最小示例

完整可运行示例位于 `examples/cuda/tiled_transpose.cu`。输入是 row-major `[height, width]`，输出是 row-major `[width, height]`：

```cpp
tile[threadIdx.y + offset][threadIdx.x] =
    input[(input_row + offset) * width + input_col];

__syncthreads();

output[(output_row + offset) * height + output_col] =
    tile[threadIdx.x][threadIdx.y + offset];
```

其中 `threadIdx.x → col` 使同一 Warp 读取 row-major 的连续列。输入 tile `(tile_row, tile_col)` 转置后位于输出 `(tile_col, tile_row)`，因此输出坐标交换 `blockIdx.x/y`；Shared Memory 读取交换局部 `threadIdx.x/y`，完成 tile 内部转置。

## Shared Memory Bank

简化模型中，32-bit word `i` 映射到 `Bank (i % 32)`：

- `Thread t → word t` 分散到 Bank 0～31，无冲突；
- `Thread t → word (t×32)` 访问不同地址但全部落到 Bank 0，形成严重冲突；
- 所有 Thread 读取完全相同的 word 才属于广播特例。

`tile[32][32]` 按列读取时行跨度是 32 word；使用 `tile[32][33]` 增加一列 padding，把行跨度改为 33，使相邻行的 bank 映射错位。逻辑 tile 仍是 32×32，代价是每个 Block 多使用 32 个 float 的 Shared Memory。

## 常见误解

- Coalescing 减少的是物理内存事务，不一定减少 Thread 的逻辑 load/store 数量；
- 有用/requested bytes 不变时，实际覆盖的内存片段和事务仍可能下降；
- Shared Memory 不只用于数据复用，也可用于访问重排；
- bank 是 Shared Memory 的内部组织，不是独立存储层级；
- bank 编号相同不等于地址相同；
- 交换 `blockIdx` 只移动整个 tile，还需交换 tile 内局部坐标才能完成完整转置。

## 与相关技术的区别

- Cache 由硬件自动管理；Shared Memory 由 kernel 显式分配、装载和同步；
- Global-memory coalescing 关注一个 Warp 的地址覆盖多少内存片段；Shared Memory bank conflict 关注一个 Warp 的地址映射到多少个 bank；
- 数据复用主要降低 HBM 字节，访问重排主要降低完成相同有用访问所需的物理事务。

## 代码或实验

- `examples/cuda/tiled_transpose.cu` 保存 padded tiled-transpose、边界处理、启动代码和 CPU 结果校验；
- 已用 CPU 索引模拟验证 `45×70` 输入到 `70×45` 输出的坐标映射；
- 当前环境没有 `nvcc`，尚未编译或运行 CUDA kernel。

## 我曾经答错的地方

- 把 HBM 访问称为需要 CPU 参与的中断；
- 把 tiled transpose 的访问重排误认为减少 HBM 读取次数；
- 把 word 0、32、64 误认为同一地址并错误套用广播；
- 对 `threadIdx`、`blockDim`、输入/输出 Block 坐标交换需要多次补充完整上下文。

## 掌握证据

- 能完成 Register、Shared Memory、L2、HBM 的延迟和容量排序；
- 能计算 tile 复用将 2048 个 float 的 HBM 读取降为 256 个；
- 能判断 row-major 中相邻列映射具有更好 coalescing；
- 能计算 tiled transpose 连续写入的一维位置，并区分逻辑 store 与物理事务；
- 经引导后能用 profiler 指标区分数据复用与访问重排；
- 能在对比题中区分 Shared Memory 同地址广播与同 bank 不同地址冲突。

## 待验证内容

1. 闭卷解释输入 tile `(blockIdx.y, blockIdx.x)` 到输出 tile `(blockIdx.x, blockIdx.y)` 的映射；
2. 独立计算 `tile[32][32]` 与 `tile[32][33]` 在转置读取时的 bank 编号；
3. 在 NVIDIA GPU 上编译运行保存的示例；
4. 增加 naive、unpadded、padded 三个版本，用 profiler 比较 HBM 事务、Shared Memory bank conflict 和运行时间；
5. 用 CUDA 官方资料核验架构相关的事务粒度、bank 和广播细节。

## 转入 Canonical 的条件

- 能脱离提示解释层级、coalescing、复用、重排和 bank conflict；
- 独立通过 tiled transpose 坐标与 padding 迁移题；
- 完成至少一次真实 GPU 编译、正确性验证和 profiler 对比；
- 核心架构结论由 CUDA 官方资料或实验结果支持，且不存在影响结论的未解决冲突。

## 参考资料

- 待核验：CUDA C++ Programming Guide 中的 device memory access、Shared Memory 与 bank conflict 章节。

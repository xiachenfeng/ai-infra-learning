# 第二轮重学：Grid、Block、Thread

- 日期：2026-09-13
- 状态：首个映射练习已回答；后续学习见 [[sessions/2026-09-15-thread-index-relearning|9 月 15 日编号复习]]
- 前一小节：[[sessions/2026-09-13-cpu-gpu-relearning|CPU/GPU 执行入口]]
- 总计划：[[sessions/2026-09-13-relearning-plan|第二轮重学计划]]

## 本次教学范围

一个逐元素加 10 的任务，拆为 2 个 Block，每个 Block 4 个 Thread；讲解 Thread 是 kernel 的逻辑执行实例、Block 是线程分组、Grid 是本次 launch 的全部线程组织。暂不加入 Warp 和硬件调度细节。

## 完整相关代码与图例

- 新建独立 CUDA 教学实现：[[examples/cuda/thread_block_grid.cu|完整可运行源码]]。这不是 PyTorch 内部实际 kernel 配置。
- 教学展示完整 `add_ten` 与 `launch_add_ten` 函数；其余 `main` 负责分配、复制、同步、输出校验与释放，完整保存在源码中。
- 交互图追踪 8 个逻辑 Thread 的局部编号、元素编号和输入/输出值；箭头表示本例中 Thread 负责的元素，不表示线程顺序执行。
- 每 Block 4 个 Thread 仅用于缩小模型，不是性能推荐；Thread 数不等于 GPU 物理核心数，也不保证全体同时执行。

## 核心公式与示范

本例是一维逐元素映射，每 Thread 处理一个元素，且编号从 0 开始：

$$
i_{\mathrm{global}} = b \times T + t_{\mathrm{local}}
$$

$b$ 对应 `blockIdx.x`，$T$ 对应 `blockDim.x`，$t_{\mathrm{local}}$ 对应 `threadIdx.x`。

教师示范 Block 1、Thread 1：Block 起点为 $1\times4=4$，全局元素编号为 $4+1=5$；输入元素 5 的值为 6，输出为 16。

## 练习与澄清

同一完整代码与图例中，Block 1 的 Thread 2 负责哪个全局元素？请给出编号计算过程。这是引导练习，不评分。

用户回答“7，1*4+2=6”。算式和结果编号 6 正确；开头的 7 含义不明确，教师区分了全局编号 6、第 7 个元素和输入值 7，不将其直接判为概念错误。

用户随后指出聊天公式显示乱码。教师改用普通文本显示 `1 × 4 + 2 = 6`；属于显示澄清，不计答错。Obsidian 知识卡继续使用原生数学语法。

## 验证边界

源码尚未做真实 CUDA 编译与执行。局部坐标、全局索引和预期结果只能作为推导证据，不作为实机性能或调度证据。

## 参考资料

- [NVIDIA CUDA Programming Model](https://docs.nvidia.com/cuda/cuda-programming-guide/01-introduction/programming-model.html)
- [NVIDIA Writing SIMT Kernels](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/writing-cuda-kernels.html)

## 保存归档

2026-09-15随本轮学习统一保存，收尾与知识提取见 [[sessions/2026-09-15-thread-index-relearning#Session End — 2026-09-15|本轮收尾]]。本记录保留过程中的下一步描述作为历史，不作为当前待答题；当前安排以 [[state/current]] 为准。

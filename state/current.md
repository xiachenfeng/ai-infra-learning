# Current Learning State

Last updated: 2026-08-07

## Long-term Goal

在 6 个月内系统理解大模型训练与推理基础设施，达到 AI Infra 入门岗位所需水平，重点具备读懂并修改训练/推理框架代码的能力。

## Learner Context

- 10 年算法工程经验，熟悉 Python、Java，能够阅读 C++。
- 熟悉 TensorFlow、XGBoost 和 DNN CTR/CVR 模型训练。
- 有修改 XGBoost C++ 推理代码并上线服务的经历。
- 不负责日常线上运维和推理基础设施。
- 系统、网络和分布式知识以使用经验为主，理论与诊断方法需要补齐。
- CUDA、GPU thread/warp/block 和 GPU memory hierarchy 接近零基础。
- 每周可投入 3–4 小时，偏好先理解原理再进行实验。
- 可以按需租赁 NVIDIA GPU 环境。

## Current Stage

初始化完成，进入第 1 阶段：系统与 GPU 执行基础。

## Current Focus

完成多 Stream Tensor 生命周期、PyTorch CUDA caching allocator 与 `record_stream()` 的迁移复测；下一步用最小 GPU 实验验证显存复用行为，然后进入 GPU memory hierarchy。

## Diagnostic Summary

- 进程与线程：理解隔离与共享的核心区别，但对线程独占状态的描述不完整。
- 虚拟内存：知道换页和文件映射，缺少 TLB、页表、page fault 与非法访问处理的完整链路。
- 网络排障：能区分网络侧和服务端资源侧，但缺少分层指标体系。
- AllReduce：正确理解数据并行中的梯度聚合与模型同步目的。
- GPU 执行模型：初始诊断时未掌握；本次学习后能解释 Grid、Block、Warp、Thread 的关系，待间隔复测。
- KV Cache：理解 K/V 在逐 token 解码中的复用和加速作用，尚未涉及显存与调度细节。

## Recent Progress

- 完成背景采访和首次基础知识诊断。
- 明确半年目标、每周时间预算、学习方式和实验环境方案。
- 建立 24 周课程主线。
- 完成 GPU 执行模型入门学习，掌握 Grid、Block、Warp、Thread 的关系。
- 能够判断简单的 Warp Divergence 和 Block 同步边界。
- 区分了 PyTorch eager execution 与 CUDA asynchronous execution。
- 完成 Grid、Block、Thread、Warp 间隔复测，能够分析部分有效 Warp 和跨 Block 调度死锁。
- 能解释 LLM 用户请求与 kernel/Grid 的多对多关系，并初步理解 Continuous Batching 的吞吐—延迟权衡。
- 在 RTX 3090 上完成 PyTorch CUDA 异步计时实验，验证未同步 CPU 计时主要测到任务提交时间。
- 能区分 `wait_event()`、`wait_stream()` 与 Event/Stream/Device `synchronize()` 的等待对象和范围。
- 用中间 Event 实验验证精确跨 Stream 依赖：等待 Event 不要求生产 Stream 的后续工作完成。
- 用 PyTorch Profiler 观察两个 Stream 的 kernel 时间线，确认不同 Stream 允许并发，但大型 GEMM 仅出现部分重叠。
- 通过 2026-08-06 间隔复测，能够区分 Thread 逻辑实例数与 Warp 硬件执行分组，并分析部分有效 Warp 和 Block 边界。
- 能区分 `wait_stream()` 建立的执行依赖与 `record_stream()` 登记的显存生命周期。
- 能分析 `del x`、allocator 延迟回收、内部 CUDA Event 完成和显存块重新可用的因果顺序。
- 能分析手动同步方案中等待位置对并发重叠的影响，并解释创建 Stream 上的后续写入为何不会覆盖侧 Stream 的未完成读取。
- 通过 2026-08-07 复测，能闭卷区分 `record`/`wait_event` 队列操作与 `synchronize()` CPU 阻塞，并能分析双侧 Stream、view alias、手动 Event 替代方案和 `record_stream()` 的保守性。
- 能说明 `record_stream()` 不是精确位置依赖，而是 Storage 对 Stream 的生命周期登记；保护范围取决于 Tensor 释放时 recorded Stream 上已排队的工作。

## Next Recommended Action

完成 `record_stream()` 最小 GPU 实验，观察缺少登记、使用 `record_stream()` 和手动 Event 三种方案的显存复用行为；实验后若结论稳定，将 CUDA Tensor Lifetime 候选知识提升为 canonical，并进入 GPU memory hierarchy。

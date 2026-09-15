# Current Learning State

Last updated: 2026-09-15（已保存；R2编号复测通过，下一课Warp内分支）

## Long-term Goal

在 6 个月内建立 AI Infra 整体知识地图，以推理基础设施为深入主线，在一个框架中完成问题定位、局部修改和验证。训练方向保留核心概念和按需补充内容。

## Confirmed Learning Preferences

- 2026-09-13 用户确认选择推理主线。
- 新知识默认先讲机制并完整示范，再引导练习和独立检查；不能每次上来直接考尚未讲解的内容。
- 2026-09-13 用户明确希望尽可能多的图例：适合视觉表达的新机制默认配图，复杂过程拆为连续小图，状态变化优先用可逐步查看的交互图。先解释图例再练习，并对应到真实代码。
- 前置诊断只检查直接相关且已有记录无法确认的知识；用户要求讲解时立即讲解，不要求先答错。
- 2026-09-13 用户要求将此前学过的全部知识按新方法从头重学。增加连贯讲解与视觉示范，减少零碎提问；仍保留少量独立检查。
- 2026-09-13 用户确认知识库以 Obsidian 阅读：内部引用使用 wikilink，数学用原生 MathJax 语法，图形要求美观、清晰且可在笔记中独立阅读。具体规范见 AGENTS.md，旧知识随重学修订逐步迁移。
- 用户反馈聊天中的行内公式出现乱码；聊天计算改用普通文本或代码格式，Obsidian 知识卡仍按原生数学规范沉淀。显示问题不计为答错。

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

启动第二轮系统重学，暂缓原“Phase 1 收尾后直接进入 PyTorch”的安排。详见 `sessions/2026-09-13-relearning-plan.md`；R1 已讲解、独立验收待复核，当前进入 R2，本轮 0/8 单元完成验收。历史掌握度和产物保留，不清零；新版课程进度待按验收证据核对。

## Current Focus

R2 已完成一维与二维编号、Warp/Lane、部分Warp与Block分组边界的基础应用检查。下一课从完整代码和图例讲解Warp内分支执行，再练习与独立检查。R1数据依赖与二维编号解释放入间隔复习；本轮尚无新GPU实验。

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
- 设计并推演缺少生命周期登记、使用 `record_stream()` 和手动 Event 三种最小实验，能区分地址复用、实际显存访问与结果异常三类证据。
- 通过 PyTorch 官方 API 文档和 native allocator 源码说明核验：`record_stream()` 会阻止 block 在 recorded Stream 工作完成前被复用；真实 GPU 实验仍待执行。
- 能区分手动 Event 方案中的两条依赖边：旧 Tensor 在侧 Stream 的最后使用，以及新 Tensor 从创建 Stream 转交消费者 Stream 的 allocator 顺序。
- 开始 GPU memory hierarchy：理解算术强度、HBM 带宽瓶颈、register 线程私有、shared memory 属于 Block、L2 可跨 Block 自动缓存。
- 能说明一次 kernel launch 对应一个 Grid，多个 Block 可访问同一 global-memory 地址；普通 kernel 内 `__syncthreads()` 不能作为跨 Block barrier。
- 能用同 Stream kernel 边界或跨 Stream Event 建立 producer Grid 到 consumer Grid 的执行顺序。
- 完成 Register、Shared Memory、L2、HBM 的典型延迟和容量排序，能区分 Thread 私有、Block 共享、全 GPU 缓存和设备显存。
- 能计算 Shared Memory tile 复用将 HBM 读取量降至原来的 `1/8`，并判断无复用且不改善访问模式时 staging 可能更慢。
- 能用 row-major 地址分布判断 Warp global-memory coalescing，并区分逻辑 load/store 数量与物理内存事务数量。
- 经引导后能用 profiler 指标区分数据复用与访问重排：HBM 字节下降对应复用，字节基本不变但事务下降对应 coalescing 改善。
- 初步理解 Shared Memory bank 的模 32 映射，能区分同地址广播与同 bank 不同地址冲突；stride-32 与 padding 的迁移分析待复测。
- 保存了可处理非整 tile 边界的 padded tiled-transpose CUDA 示例，并通过 `45×70` CPU 索引模拟；本机缺少 `nvcc`，尚未实机编译和 profiler 验证。

## Next Recommended Action

下次先讲Warp内分支执行，提供完整相关代码及分步图示；不继续重复编号算术题。二维组合复测已独立答对77、2、13，算式未提供已按要求记录。2026-09-18起间隔复习零基编号、二维行宽解释和R1数据依赖。R2整体未验收，重学完成数仍0/8；GPU Execution Model维持3。

本次记录：[[sessions/2026-09-15-thread-index-relearning]]。正式知识已更新 [[knowledge/canonical/gpu-execution-hierarchy]]；二维独立解释证据待补，保存在 [[knowledge/candidates/2d-thread-warp-lane-mapping]]。未在Obsidian实际预览；未完成新CUDA实机验证。

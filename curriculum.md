# AI Infra Curriculum

## Learner Profile

- 10 年算法工程经验，主要使用 Python、Java，能够阅读 C++。
- 熟悉 TensorFlow、XGBoost，以及 DNN CTR/CVR 模型训练。
- 曾修改 XGBoost C++ 推理代码并提供线上服务。
- Linux、网络和分布式系统有使用经验，但缺少系统性研究。
- CUDA 和 GPU 内部执行模型接近零基础。
- 目标是在 6 个月内具备训练/推理基础设施岗位的入门能力，重点是读懂并修改框架代码。
- 每周投入 3–4 小时，采用“先理解原理，再动手验证”的方式。
- 实验环境按需租赁中国大陆 NVIDIA GPU 云实例。

## Learning Principles

1. 每周只设一个主主题，避免在有限时间内铺得过宽。
2. 原理、代码、资料阅读的默认比例为 50% / 40% / 10%；论文仅在能解释关键设计时精读。
3. 每个主题必须形成可验证产物：口头解释、代码追踪、最小实验或框架改动。
4. 优先补齐阅读 PyTorch、CUDA、NCCL、分布式训练和推理框架源码所需的知识。
5. 已有的 TensorFlow、XGBoost 和推荐模型经验作为迁移基础，不重复学习通用机器学习课程。

## Six-Month Path

### Phase 1（第 1–4 周）：系统与 GPU 执行基础

- Linux 进程、线程、虚拟内存和性能分析
- CPU/GPU 异构执行流程
- CUDA thread、warp、block、grid
- GPU memory hierarchy、同步和基本 kernel
- 使用 profiler 建立“现象—指标—瓶颈”的分析方法

阶段产物：能够解释一个 CUDA/PyTorch 算子如何在 GPU 上执行，并完成一次基础性能分析。

### Phase 2（第 5–8 周）：PyTorch 与算子实现

- PyTorch eager execution、autograd、dispatcher 和 ATen
- Python 调用如何进入 C++/CUDA 实现
- Tensor、内存布局、算子注册与设备分发
- 编写和调试最小 PyTorch C++/CUDA extension
- 对照 TensorFlow/XGBoost 理解框架边界

阶段产物：能够追踪一个 PyTorch 算子的完整调用链，并完成一个小型算子修改。

### Phase 3（第 9–12 周）：分布式训练基础

- Data Parallel 与 DistributedDataParallel
- collective communication：Broadcast、Reduce、AllReduce、AllGather、ReduceScatter
- Ring AllReduce、带宽与延迟模型
- NCCL 的 communicator、拓扑和调试方法
- checkpoint、故障恢复和训练一致性

阶段产物：运行并分析一个多 GPU DDP 训练任务，能够定位基础通信问题。

### Phase 4（第 13–16 周）：大模型训练并行

- Tensor Parallel、Pipeline Parallel、Sequence Parallel
- ZeRO、FSDP 与参数/梯度/优化器状态分片
- activation checkpointing 与显存估算
- DeepSpeed、Megatron-LM 或 PyTorch FSDP 源码路径
- 计算、通信和显存之间的权衡

阶段产物：读懂一种并行策略的关键实现，并对小模型完成配置或局部修改。

### Phase 5（第 17–20 周）：大模型推理系统

- Prefill 与 Decode
- KV Cache 的布局、容量和带宽影响
- Continuous Batching、Paged Attention
- Quantization、Speculative Decoding
- vLLM 请求调度、模型执行和 cache management 源码

阶段产物：部署一个小型 vLLM 服务，分析吞吐与延迟，并追踪或修改一条核心代码路径。

### Phase 6（第 21–24 周）：综合源码项目与岗位准备

- 训练或推理框架中的真实问题定位
- observability、benchmark、容量和成本分析
- Docker、Kubernetes/Slurm/Ray 的必要概念
- 选择一个小型功能、性能问题或可观测性问题完成修改
- 整理设计说明、实验数据和源码阅读记录

阶段产物：完成一个可展示的框架级修改，并能解释其设计、验证方法和性能影响。

## Deferred Topics

以下内容保留在知识地图中，但不作为前 4 个月主线：

- 深入网络协议实现与内核网络栈
- 文件系统和存储引擎细节
- Kubernetes、Slurm、Ray 的生产级运维
- 大规模 GPU 调度、多租户隔离和集群容量规划
- 非主线框架的全面源码阅读

这些主题在综合项目需要时按需补充。

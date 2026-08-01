# Mastery

掌握度：0 = 未学习或未测试，1 = 能够识别概念，2 = 能够用自己的语言解释，3 = 能够应用和分析，4 = 能够迁移、设计和排查问题。

| Knowledge Point | Importance | Mastery | Last Tested | Evidence |
|---|---:|---:|---|---|
| Linux Process and Thread | 5 | 2 | 2026-08-01 | 理解进程隔离、线程共享上下文；未完整区分共享地址空间与线程私有栈、寄存器等状态 |
| Virtual Memory | 5 | 1 | 2026-08-01 | 能识别页面置换和文件调入；缺少 TLB、页表、page fault 与非法地址处理的完整链路 |
| Network Troubleshooting | 4 | 1 | 2026-08-01 | 能区分网络延迟与服务端 CPU/内存问题；尚未形成连接、重传、排队和依赖的分层指标体系 |
| GPU Execution Model | 5 | 2 | 2026-08-01 | 能用自己的语言解释 Grid、Block、Warp、Thread 的关系并完成基础计算；需间隔复测，不因单次学习直接评为应用级 |
| GPU Memory Hierarchy | 5 | 0 | - | 未测试 |
| CUDA Kernel | 5 | 2 | 2026-08-01 | 理解 kernel launch、线程全局索引和边界检查，能计算 launch 配置；尚未编写或分析真实 kernel |
| CUDA Asynchronous Execution | 5 | 1 | 2026-08-01 | 能识别 eager execution 不等于同步执行，但仍混淆 GPU 自行完成与 CPU 同步等待；待独立复述和实验 |
| AllReduce | 5 | 2 | 2026-08-01 | 能用自己的语言解释数据并行中的梯度聚合与 AllReduce 的同步目的；尚未测试算法和通信分析 |
| NCCL | 5 | 0 | - | 未测试 |
| Tensor Parallel | 5 | 0 | - | 未测试 |
| KV Cache | 5 | 2 | 2026-08-01 | 理解自回归逐 token 推理中复用 K/V 以避免重复计算；未验证缓存布局和资源权衡 |
| Continuous Batching | 4 | 0 | - | 未测试 |

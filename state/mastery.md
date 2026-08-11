# Mastery

掌握度：0 = 未学习或未测试，1 = 能够识别概念，2 = 能够用自己的语言解释，3 = 能够应用和分析，4 = 能够迁移、设计和排查问题。

| Knowledge Point | Importance | Mastery | Last Tested | Evidence |
|---|---:|---:|---|---|
| Linux Process and Thread | 5 | 2 | 2026-08-01 | 理解进程隔离、线程共享上下文；未完整区分共享地址空间与线程私有栈、寄存器等状态 |
| Virtual Memory | 5 | 1 | 2026-08-01 | 能识别页面置换和文件调入；缺少 TLB、页表、page fault 与非法地址处理的完整链路 |
| Network Troubleshooting | 4 | 1 | 2026-08-01 | 能区分网络延迟与服务端 CPU/内存问题；尚未形成连接、重传、排队和依赖的分层指标体系 |
| GPU Execution Model | 5 | 3 | 2026-08-09 | 能说明一次 kernel launch 对应一个 Grid，计算 Block/Thread 数量，并区分同 Stream 整 Grid 顺序与不同 Stream 缺少 happens-before |
| GPU Memory Hierarchy | 5 | 2 | 2026-08-11 | 能完成 Register、Shared Memory、L2、HBM 的延迟与容量排序，分析 coalescing、物理事务和 Shared Memory 复用/访问重排；tiled transpose 坐标交换与 bank conflict 仍需引导，尚无真实 GPU profiler 证据 |
| CUDA Kernel | 5 | 2 | 2026-08-11 | 能阅读 tiled transpose 的 Thread/Block 坐标和连续地址，计算局部输出位置；对 tile 的全局/局部转置仍需完整上下文，尚未独立编写和运行真实 kernel |
| CUDA Asynchronous Execution | 5 | 3 | 2026-08-04 | 能解释 eager 立即提交、GPU 异步执行和 CPU 同步等待；在 RTX 3090 上完成 CPU 同步计时与 CUDA Event 计时实验 |
| CUDA Stream and Grid Concurrency | 4 | 3 | 2026-08-04 | 能分析 Stream/Event 依赖图，区分 wait 与 synchronize，并用 profiler 验证不同 Stream 允许但不保证充分并发 |
| CUDA Tensor Lifetime Across Streams | 5 | 3 | 2026-08-09 | 能分析地址复用实验、pending block、手动 Event 精确复用及创建 Stream/消费者 Stream 两条依赖边；官方资料已核验，独立 GPU 实验未完成，暂不升 4 |
| AllReduce | 5 | 2 | 2026-08-01 | 能用自己的语言解释数据并行中的梯度聚合与 AllReduce 的同步目的；尚未测试算法和通信分析 |
| NCCL | 5 | 0 | - | 未测试 |
| Tensor Parallel | 5 | 0 | - | 未测试 |
| KV Cache | 5 | 2 | 2026-08-01 | 理解自回归逐 token 推理中复用 K/V 以避免重复计算；未验证缓存布局和资源权衡 |
| Continuous Batching | 5 | 2 | 2026-08-03 | 经引导后能解释 batching 的权重复用、kernel 开销和吞吐—延迟权衡；尚未独立设计或 benchmark |

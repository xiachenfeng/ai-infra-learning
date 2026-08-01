# Mastery

掌握度：0 = 未掌握或未验证，1 = 初步接触，2 = 部分理解，3 = 核心概念正确，4 = 能独立应用，5 = 能深入解释和修改实现。

| Knowledge Point | Importance | Mastery | Last Tested | Evidence |
|---|---:|---:|---|---|
| Linux Process and Thread | 5 | 2 | 2026-08-01 | 理解进程隔离、线程共享上下文；未完整区分共享地址空间与线程私有栈、寄存器等状态 |
| Virtual Memory | 5 | 2 | 2026-08-01 | 知道页面置换和文件调入；缺少 TLB、页表、page fault 与非法地址处理的完整链路 |
| Network Troubleshooting | 4 | 1 | 2026-08-01 | 能区分网络延迟与服务端 CPU/内存问题；尚未形成连接、重传、排队和依赖的分层指标体系 |
| GPU Execution Model | 5 | 3 | 2026-08-01 | 能解释 Grid、Block、Warp、Thread 的关系，正确判断简单 Warp Divergence 与 Block 同步边界；异步执行仍需实验巩固 |
| GPU Memory Hierarchy | 5 | 0 | - | 未测试 |
| CUDA Kernel | 5 | 2 | 2026-08-01 | 理解 kernel launch、线程全局索引和边界检查，能计算 launch 配置；尚未编写或分析真实 kernel |
| AllReduce | 5 | 3 | 2026-08-01 | 能解释数据并行中本地梯度需要聚合，并理解 AllReduce 完成聚合与同步 |
| NCCL | 5 | 0 | - | 未测试 |
| Tensor Parallel | 5 | 0 | - | 未测试 |
| KV Cache | 5 | 2 | 2026-08-01 | 理解自回归逐 token 推理中复用 K/V 以避免重复计算；未验证缓存布局和资源权衡 |
| Continuous Batching | 4 | 0 | - | 未测试 |

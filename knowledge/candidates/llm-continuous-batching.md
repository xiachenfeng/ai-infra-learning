# LLM Continuous Batching

- Status: 候选知识，尚未验证
- Evidence: `sessions/2026-08-03-gpu-hierarchy-review.md`
- Last discussed: 2026-08-03

## 候选理解

线上 LLM serving 通常不为每个用户固定分配一个 CUDA Stream。Serving scheduler 管理请求状态、生成进度和 KV Cache，并在每个推理 step 选择若干活跃请求组成动态 batch；完成的请求退出，新请求可在后续 step 加入。

一次 batched forward 会启动许多共享 kernel/Grid。用户请求与 Grid、Block、Warp 是多对多关系，具体执行映射由 tensor shape、kernel tiling 和数据布局决定。

## 为什么 Batching 通常提高吞吐

相比执行许多次 `[1, H] × [H, H]`，一次 `[B, H] × [H, H]` 通常具有：

- 更大的权重数据复用机会；
- 更少的 kernel launch 和调度开销；
- 更多可并行的矩阵 tile；
- 更适合高性能 GEMM/Tensor Core kernel 的问题规模。

这并不保证降低单请求延迟。等待成批会影响 TTFT，更大的单步计算可能影响 ITL，KV Cache 容量也会限制可同时运行的请求数。

## 尚未进入正式知识库的原因

- 初始回答把主要收益归因于不同 Stream 竞争和 Warp 执行相同代码，未抓住矩阵规模、权重复用和启动开销。
- 经过引导后能解释权重读取、kernel 数量和吞吐/延迟权衡，但尚未独立完成系统设计分析。
- 尚未运行 vLLM/TensorRT-LLM 或观察调度指标。

## 需要完成的验证

1. 独立画出请求队列、scheduler、dynamic batch、model runner 和 KV Cache 的关系。
2. 对比一请求一 Stream、静态 batching 和 continuous batching。
3. 运行 serving benchmark，观察 batch size、TTFT、ITL、吞吐和 KV Cache 使用率。

## 转入 canonical 的条件

- 能独立解释调度循环及吞吐来源；
- 能分析至少一个吞吐—延迟权衡场景；
- 完成一次框架配置或 benchmark。

## 参考资料

- https://docs.vllm.ai/en/stable/index.html
- https://docs.vllm.ai/en/stable/api/vllm/config/scheduler/
- https://docs.vllm.ai/en/stable/configuration/optimization/
- https://nvidia.github.io/TensorRT-LLM/torch/scheduler.html

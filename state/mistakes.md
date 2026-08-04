# Mistakes and Misconceptions

## 2026-08-01：CUDA 同步与计算完成

- 日期：2026-08-01
- 知识点：PyTorch eager execution 与 CUDA asynchronous execution
- 原回答：只在计时开始前同步即可测量 GPU 实际计算时间；同步后 GPU 才结束计算。
- 错误原因：混淆了“立即提交算子”“GPU 独立执行”和“CPU 等待 GPU”三个概念。
- 正确理解：CUDA 工作提交后 GPU 会独立执行并最终完成；同步使 CPU 等待并确认此前 GPU 工作完成。使用 CPU 时钟计时 GPU 操作时，通常需要在测量区间前后同步。
- 是否已复测：2026-08-04 通过。能够独立区分 eager 提交、Stream 顺序、GPU 执行和 CPU 等待，并在 RTX 3090 上完成同步计时与 CUDA Event 计时实验。

## 2026-08-03：Thread 逻辑实例数与 Warp 数量

- 日期：2026-08-03
- 知识点：Thread 与 Warp 的本质区别
- 原回答：一个 Block 有 256 个 Thread、Warp 大小为 32 时，有 8 个逻辑执行实例。
- 错误原因：把硬件执行分组数量误当成 kernel 的逻辑执行实例数量。
- 正确理解：256 个 Thread 对应 256 个逻辑执行实例；硬件把它们组成 8 个 Warp 发射指令。
- 是否已复测：当场追问后通过，需 2026-08-06 间隔复测。

## 2026-08-03：Continuous Batching 的吞吐来源

- 日期：2026-08-03
- 知识点：LLM Continuous Batching
- 原回答：主要因为不同 Stream 会并发竞争，以及同一 Warp 执行相同代码更高效。
- 错误原因：把 CUDA 调度现象当成 batching 的主要收益，忽略矩阵规模、权重数据复用和 kernel launch 开销。
- 正确理解：更大的 batch 把多个 token 合成更大的矩阵计算，提供更多 tile、更好的权重复用并分摊启动开销；代价可能是排队和单步延迟增加。
- 是否已复测：引导题通过，尚未独立分析或实验。

## 2026-08-04：把 Stream 等待误认为 CPU 阻塞

- 日期：2026-08-04
- 知识点：CUDA Stream、Event 与同步范围
- 原回答：`wait_event()` 中 CPU 需要停下来；`wait_stream()` 会阻塞 CPU。
- 错误原因：没有区分“向目标 Stream 插入 GPU 依赖”和“调用线程同步等待 GPU”。
- 正确理解：`wait_event()` 和 `wait_stream()` 都只约束目标 Stream 后续提交的工作，调用本身通常很快返回；`Event.synchronize()`、`Stream.synchronize()` 和 `torch.cuda.synchronize()` 才分别使 CPU 等待 Event、Stream 或整个设备范围的工作。
- 是否已复测：2026-08-04 通过。选择题能正确识别 CPU 阻塞 API，并用实验测得 `wait_event()` 和 `wait_stream()` 调用仅约 0.016 ms 与 0.064 ms。

## 2026-08-04：CUDA Event 计时与倍率计算

- 日期：2026-08-04
- 知识点：CUDA benchmark 计时
- 原回答：同一 Stream 的 Event 计时还需 `end.wait_event(start)`；把 100 次矩阵乘法的 0.947 ms 提交时间直接与单次 5.829 ms 比较，误判为约 6 倍。
- 错误原因：忽略同一 Stream 已保证 Event 与 kernel 的顺序，并混用了批量总时间与单次时间。
- 正确理解：同一 Stream 中按 `start.record()`、kernel、`end.record()` 排队即可建立区间，CPU 在读取 elapsed time 前等待 `end`；比较倍率时必须统一为总时间或单次时间。本次未同步 CPU 计时约低估 `582.9 / 0.947 ≈ 615` 倍。
- 是否已复测：2026-08-04 通过。经追问后纠正倍率，并能解释预热、CPU 时钟噪声、Device 同步污染和 CUDA Event 的测量范围。

每条错误应包含：

- 日期
- 知识点
- 原回答
- 错误原因
- 正确理解
- 是否已复测

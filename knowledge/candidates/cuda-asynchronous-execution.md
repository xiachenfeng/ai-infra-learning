# CUDA Asynchronous Execution

- Status: 已验证，2026-08-04 提升为正式知识
- Evidence: `sessions/2026-08-01-gpu-execution-model.md`, `sessions/2026-08-04-cuda-streams-events.md`
- Canonical: `knowledge/canonical/cuda-streams-events-and-timing.md`
- Last verified: 2026-08-04

## 提升前的候选理解

CPU 提交 CUDA 工作后通常可以继续执行，而 GPU 在对应 Stream 中异步完成工作；同步操作的作用是让 CPU 等待此前提交的 GPU 工作完成。

PyTorch eager execution 表示运行到某个操作时立即准备并提交它，不等于 CPU 必须等待 CUDA 操作完成。

## 候选最小示例

使用 CPU 时钟测量 CUDA 矩阵乘法时：

```python
torch.cuda.synchronize()
start = time.time()

y = torch.matmul(a, b)

torch.cuda.synchronize()
elapsed = time.time() - start
```

- 前一次同步用于排除测量前尚未完成的 GPU 工作。
- 后一次同步用于等待本次操作完成，避免只测到 CPU 提交时间。
- 正式 benchmark 还应考虑预热，并比较 CUDA Event 计时。

## 提升前的验证缺口

- 最初误认为只在计时开始前同步即可测量 GPU 实际计算时间。
- 纠正后仍把同步表述为“引发 GPU 完成”，尚未稳定区分 GPU 自行完成与 CPU 同步等待。
- 尚未在真实 GPU 上完成计时实验。

## 验证清单（2026-08-04 已完成）

1. 不查资料解释 eager execution、异步提交、Stream 顺序和同步等待的区别。
2. 比较无同步、仅前同步、前后同步三种 CPU 计时结果。
3. 使用 CUDA Event 重做计时，并解释预热的作用。
4. 根据一段 PyTorch 代码判断同步点和计时错误。

## 转入 canonical 的条件（已满足）

- 独立解释通过；
- GPU 计时实验完成；
- 能正确分析同步点和错误计时。

## 验证结果

- 已独立解释 eager 立即提交、GPU 异步执行、同一 Stream 顺序和 CPU 同步等待。
- 已在 RTX 3090 上完成 100 次 4096×4096 矩阵乘法实验：CPU 未同步计时 0.947 ms，CUDA Event 计时 582.912 ms。
- 已正确分析 `.item()`、`Event.synchronize()`、`Stream.synchronize()` 和设备级同步点。

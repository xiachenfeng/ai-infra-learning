# CUDA Streams、Events 与正确计时

- Status: 正式知识
- Evidence: `sessions/2026-08-01-gpu-execution-model.md`, `sessions/2026-08-04-cuda-streams-events.md`
- Last verified: 2026-08-04

## 一句话定义

PyTorch eager execution 会在代码运行到算子时立即提交工作，但 CUDA 工作通常在有序的 Stream 中异步执行；Event 用来标记 Stream 中的精确位置，wait API 建立 GPU 侧依赖，synchronize API 让 CPU 等待相应范围的 GPU 工作。

## 核心对象

### Stream

CUDA Stream 是设备工作队列。一个 Python 进程可以使用默认 Stream，也可以创建多个自定义 Stream，并非“一进程一 Stream”。

- 同一 Stream 中的工作按提交顺序执行。
- 不同 Stream 之间默认没有相对顺序；如有数据依赖，需要显式建立依赖。
- 不同 Stream 允许工作并发，但是否实际重叠、重叠多少取决于依赖和 GPU 剩余资源。

### Event

CUDA Event 是插入某个 Stream 时间线中的标记。它既能表达精确的跨 Stream 依赖，也能由 GPU 时间戳测量两个 Event 之间的执行时间。

## Wait 与 Synchronize

| API | 谁等待 | 等待范围 | CPU 调用是否通常阻塞 |
|---|---|---|---|
| `stream_b.wait_event(ready)` | Stream B 后续工作 | 直到 `ready` Event | 否 |
| `stream_b.wait_stream(stream_a)` | Stream B 后续工作 | 调用时已提交到 Stream A 的工作 | 否 |
| `event.synchronize()` | CPU 调用线程 | 直到该 Event | 是 |
| `stream.synchronize()` | CPU 调用线程 | 该 Stream 中此前提交的工作 | 是 |
| `torch.cuda.synchronize()` | CPU 调用线程 | 指定设备全部 Stream 中此前提交的工作 | 是 |

`wait_event()` 和 `wait_stream()` 的关键作用是向目标 Stream 插入依赖，而不是让 CPU 原地等待。`.item()`、把 CUDA Tensor 拷贝到 CPU 等操作也可能产生隐式同步。

## 精确依赖示例

```python
stream_a = torch.cuda.Stream()
stream_b = torch.cuda.Stream()
ready = torch.cuda.Event()

with torch.cuda.stream(stream_a):
    a1 = operation_1()
    ready.record()
    a2 = operation_2()

with torch.cuda.stream(stream_b):
    stream_b.wait_event(ready)
    b1 = consume(a1)
```

依赖图为：

```text
Stream A: a1 → ready → a2
                 ↓
Stream B:     wait → b1
```

`b1` 必须等待 `a1` 和 `ready`，但不需要等待 `a2`。若 CPU 只等待 `b1` 后记录的 `b_done`，可以确认 `a1`、`ready` 和 `b1` 完成，不能据此确认 `a2` 完成。

如果改用 `stream_b.wait_stream(stream_a)`，且调用前 `a1`、`ready`、`a2` 都已提交到 Stream A，那么 Stream B 后续工作要等待这三项工作。

## 正确测量 CUDA 执行时间

### CPU 时钟

使用 CPU 时钟测量 CUDA 区间时，需要在区间前后同步：

```python
torch.cuda.synchronize()
start = time.perf_counter()

y = torch.matmul(a, b)

torch.cuda.synchronize()
elapsed = time.perf_counter() - start
```

- 前同步排除测量前遗留的 GPU 工作。
- 后同步使 CPU 等待被测工作完成。
- 没有后同步时，通常主要测到 CPU 提交开销。
- 设备级同步可能把其他 Stream 的工作也混入测量。

### CUDA Event

同一 Stream 的顺序已经建立 `start → kernels → end`，不需要额外让 `end` 等待 `start`：

```python
start = torch.cuda.Event(enable_timing=True)
end = torch.cuda.Event(enable_timing=True)

start.record()
for _ in range(iterations):
    y = torch.matmul(a, b)
end.record()

end.synchronize()
elapsed_ms = start.elapsed_time(end)
```

正式 benchmark 应先预热并丢弃预热结果，再多次测量，报告均值、中位数或分位数。比较批量总时间和单次时间时必须统一单位。

## 实验结果

### 异步提交与 Event 计时

环境：NVIDIA GeForce RTX 3090、PyTorch 2.12.1+cu130；100 次 4096×4096 矩阵乘法。

| 测量方式 | 结果 |
|---|---:|
| 未同步 CPU 提交时间 | 0.947 ms |
| CPU 等待全部完成的墙钟时间 | 579.428 ms |
| CPU 前后同步计时 | 591.462 ms |
| CUDA Event 计时 | 582.912 ms |
| CUDA Event 单次矩阵乘法 | 5.829 ms |

未同步计时比 Event 总时间小约 `582.912 / 0.947 ≈ 615` 倍，证明它测到的主要是提交，而不是 GPU 完成 100 次矩阵乘法所需的时间。

### Event 与 Stream 依赖范围

- `wait_event()` CPU 调用耗时约 0.016 ms；等待 Stream A 中间 Event 后，CPU 等待约 113.386 ms，此时 Stream A 尚未全部完成。
- `wait_stream()` CPU 调用耗时约 0.064 ms；等待调用前已提交到 Stream A 的完整工作后，CPU 等待约 580.694 ms，此时 Stream A 已完成。

这说明两个 wait API 自身都不阻塞 CPU，但建立的 GPU 依赖范围不同。

### 多 Stream 时间线

PyTorch Profiler 观察到两个 CUDA Stream ID（21、25）上的 10 个矩阵乘法 kernel。第一对 kernel 重叠约 0.086 ms；10 个 kernel 的持续时间总和约 7.7 ms，而整体时间跨度约 6.962 ms。

实验只证明了部分重叠和资源共享，不能据此断言发生了 CPU 风格的抢占。大型 GEMM 已使用大量计算资源，因此多个 Stream 不会自动带来近似倍数的吞吐提升。

## 常见误解

- eager execution 的“立即执行”指立即发起/提交，不等于 CPU 等待 CUDA kernel 完成。
- 同一 Stream 的依赖由 Stream 顺序保证，不是单靠 Python 代码顺序这一抽象保证。
- 不同 Stream 没有依赖不等于一定同时运行，只表示具备并发机会。
- `wait_event()` 和 `wait_stream()` 等待的是目标 Stream 的后续 GPU 工作，不是 CPU。
- `torch.cuda.synchronize()` 范围过大时可能把无关 Stream 的工作计入墙钟时间。
- Profiler 中 kernel 时间重叠表明 concurrent execution，不能仅凭重叠证明抢占机制。

## 掌握证据

- 能闭卷解释 eager、异步执行、Stream 顺序与 CPU 同步等待。
- 能分析中间 Event 的跨 Stream 依赖图和完成条件。
- 能正确选择 Event、Stream 或 Device 同步范围。
- 已运行同步计时、CUDA Event、`wait_event()`、`wait_stream()` 和 profiler 实验，并解释结果。

## 待学习内容

- 多 Stream Tensor 生命周期和 `record_stream()`。
- Stream priority、CUDA Graph 与更复杂的跨设备依赖。
- 使用 Nsight Systems/Compute 分析 launch、occupancy、memory 与 kernel overlap。

## 参考资料

- [PyTorch CUDA semantics](https://docs.pytorch.org/docs/main/notes/cuda.html)
- [torch.cuda.synchronize](https://docs.pytorch.org/docs/stable/generated/torch.cuda.synchronize)
- [torch.cuda.Event](https://docs.pytorch.org/docs/stable/generated/torch.cuda.streams.Event.html)
- [torch.cuda.Stream](https://docs.pytorch.org/docs/main/generated/torch.cuda.Stream_class.html)
- [PyTorch Profiler](https://docs.pytorch.org/docs/stable/profiler.html)

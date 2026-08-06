# CUDA `record_stream()` 与跨 Stream Tensor 生命周期

- Status: 候选知识，尚未验证
- Evidence: `sessions/2026-08-06-cuda-record-stream-lifetime.md`
- Last discussed: 2026-08-06
- Related canonical: `knowledge/canonical/cuda-streams-events-and-timing.md`

## 一句话定义

`Tensor.record_stream(stream)` 告诉 PyTorch CUDA caching allocator 某块 Tensor 显存被指定侧 Stream 使用，使最后一个 Storage 引用消失后，显存块仍保持 pending，直到 allocator 在已登记 Stream 上的完成检查通过才允许复用。

## 它解决什么问题

PyTorch CUDA 操作异步执行。CPU 可以在侧 Stream 尚未读完 Tensor 时删除最后一个 Python 引用；如果 allocator 只知道 Tensor 的创建 Stream，可能过早把同一显存块交给新 Tensor，造成覆盖和错误结果。

## 前置知识

- PyTorch eager execution 与 CUDA 异步执行；
- 同一 Stream 有序、不同 Stream 默认无相对顺序；
- CUDA Event 表示 Stream 时间线中的完成位置；
- PyTorch CUDA caching allocator 会复用显存块，而非每次立即 `cudaFree`。

## 当前候选结论

跨 Stream 使用 Tensor 时必须分别处理两类约束：

1. 数据就绪：消费者 Stream 通过 `wait_stream()` 或 `wait_event()` 等待生产者；
2. 显存生命周期：使用 `record_stream()` 登记每个侧 Stream，或手动把最后一次侧 Stream 使用同步回创建 Stream。

`record_stream()` 调用本身主要登记显存块的 Stream 使用关系，不等同于 CPU 同步，也不自动建立生产者到消费者的数据依赖。

## 核心机制

以默认 native CUDA caching allocator 为例：

1. Tensor 在创建 Stream 上分配显存块；
2. `x.record_stream(s1)` 将 `s1` 加入该显存块的侧 Stream 使用记录；
3. 最后一个 Storage 引用消失，allocator 启动回收流程；
4. allocator 在已登记 Stream 当前队列尾部记录 CUDA Event；
5. Event 未完成时，显存块保持 pending，不进入可复用池；
6. Event 完成说明该 Stream 在释放时已经排队的工作全部完成，显存块随后可以复用。

Python 引用计数只触发回收流程；GPU Event 完成才解除显存块的 pending 状态。显存块变得可复用也不等于立即通过 `cudaFree` 归还给 CUDA。

## 系统流程

```text
CPU 提交侧 Stream 工作
        ↓
record_stream 登记 Stream 使用关系
        ↓
最后一个 Storage 引用消失
        ↓
allocator 在已登记 Stream 尾部记录 Event
        ↓
Event 未完成：显存块 pending
        ↓
Event 完成：显存块可复用
```

## 复杂度与性能影响

- CPU 不需要同步等待，GPU 也不会停止；
- allocator 需要维护 Stream 使用记录并轮询完成状态；
- 回收时的 Event 会覆盖该 Stream 在释放时已经排队的全部工作，可能包含与 Tensor 无关的工作；
- 因此显存复用可能比精确的手动 Event 更晚，增加峰值显存和复用时机的不确定性。

## 最小示例

```python
import torch

s0 = torch.cuda.default_stream()
s1 = torch.cuda.Stream()

x = torch.randn(4096, device="cuda")

# 数据就绪：s1 读取前等待 s0 的生产工作。
s1.wait_stream(s0)

with torch.cuda.stream(s1):
    y = x.sin()

    # 生命周期：allocator 知道 s1 仍在使用 x 的显存。
    x.record_stream(s1)

del x
torch.cuda.synchronize()
```

## 手动替代方案

如果能够准确定位侧 Stream 对 Tensor 的最后一次使用，可以在该位置记录 Event，并让创建 Stream 等待该 Event 后再删除 Tensor：

```python
done = torch.cuda.Event()

with torch.cuda.stream(s1):
    y = x.sin()
    done.record()

s0.wait_event(done)
del x
```

手动方案可能更早复用显存，但漏掉任何后续使用都会产生竞态。若使用 `s0.wait_stream(s1)`，等待放得过早会损失创建 Stream 与侧 Stream 的重叠机会。

## 常见误解

- `record_stream()` 不是让侧 Stream 等待创建 Stream；
- `record_stream()` 不是 CPU 阻塞 API；
- 调用 `record_stream()` 时不等于立即在该位置记录最终回收 Event；
- `del x` 不要求 GPU 已经完成，但显存块在 GPU 使用完成前不能复用；
- Event 完成不会解除 Python 引用，而是解除 allocator 对显存块的 pending 状态；
- 只登记一个侧 Stream 不能保护其他未登记 Stream 对同一显存的使用。

## 与相关技术的区别

| 机制 | 主要作用 |
|---|---|
| `s1.wait_stream(s0)` | 约束 `s1` 后续 GPU 工作等待 `s0` 已提交工作，解决数据就绪 |
| `x.record_stream(s1)` | 登记 `s1` 对 `x` 显存的使用，解决延迟复用 |
| `s0.wait_event(done)` | 手动把精确完成位置同步回创建 Stream |
| `torch.cuda.synchronize()` | 让 CPU 等待设备工作，范围更大且通常不适合作为细粒度生命周期方案 |

## 已有证据

- 2026-08-06 能正确分析手动创建 Stream 等待侧 Stream 时，复用显存后的写入为何不会覆盖未完成读取；
- 能比较过早等待与释放前等待，判断后者保留更多并发机会；
- 能正确排列 `del x → allocator 记录 Event → kernel 完成 → Event 完成 → 显存可复用`；
- 关键机制已由 PyTorch 官方文档和 native allocator 源码结构支持。

## 尚未进入 Canonical 的原因

- 最初无法独立区分 `wait_stream()` 与 `record_stream()`，核心机制主要在引导和解释后掌握；
- 尚未完成两个侧 Stream 同时使用同一 Tensor 时的独立分析；
- 尚未运行最小实验观察 `record_stream()` 对显存地址复用或 allocator 状态的影响；
- 尚未独立比较 `record_stream()` 与精确手动 Event 的完整安全条件。

## 尚需完成的验证

1. 闭卷分析同一 Tensor 被两个侧 Stream 使用时需要登记哪些 Stream；
2. 完成最小 GPU 实验，对比缺少登记、使用 `record_stream()` 和手动 Event 三种方案；
3. 解释别名/View 共享 Storage 时，最后一个引用与显存回收的关系；
4. 独立说明 `record_stream()` 的安全性成本和手动 Event 的适用条件。

## 转入 Canonical 的条件

- 能脱离提示解释数据依赖与显存生命周期依赖；
- 独立通过双侧 Stream 故障分析题；
- 完成至少一个真实 GPU 实验或 allocator 源码追踪，并保存可复现结果；
- 能正确设计 `record_stream()` 和手动 Event 两种安全方案，并分析内存与并发权衡。

## 参考资料

- [PyTorch `Tensor.record_stream()`](https://docs.pytorch.org/docs/stable/generated/torch.Tensor.record_stream.html)
- [PyTorch CUDA semantics](https://docs.pytorch.org/docs/main/notes/cuda.html)
- [PyTorch native CUDACachingAllocator source](https://github.com/pytorch/pytorch/blob/main/c10/cuda/CUDACachingAllocator.cpp)

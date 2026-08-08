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
- 是否已复测：2026-08-06 间隔复测通过。能够正确区分 512 个 Thread 逻辑实例与 16 个 Warp 硬件执行分组。

## 2026-08-06：部分 Warp 计数与 Block 边界因果

- 日期：2026-08-06
- 知识点：部分有效 Warp、Warp 与 Block 的关系
- 原回答：100 个 Thread 的 Block 中，最后一个 Warp 有 6 个有效 Thread；Warp 不能跨 Block 是因为 Block 内可以同步。
- 错误原因：部分 Warp 余数计算错误，并把 `__syncthreads()` 的作用范围误当成 Warp 硬件分组规则的原因。
- 正确理解：前三个完整 Warp 覆盖 96 个 Thread，最后一个 Warp 有 4 个有效 Thread；Warp 是同一 Block 内 Thread 的硬件执行分组，Block 同步范围和 Warp 分组边界都是 Block 作为调度与协作边界的结果。
- 是否已复测：2026-08-06 通过反事实题和独立计数题复测。即使 kernel 不调用 `__syncthreads()`，Warp 仍不能跨 Block。

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
- 是否已复测：2026-08-07 闭卷复测通过。能正确区分 `event.record()`、`wait_event()` 为队列操作，`Stream.synchronize()` 为 CPU 阻塞等待，并说明 `wait_event()` 等待的是 Event 之前的生产 Stream 工作。

## 2026-08-04：CUDA Event 计时与倍率计算

- 日期：2026-08-04
- 知识点：CUDA benchmark 计时
- 原回答：同一 Stream 的 Event 计时还需 `end.wait_event(start)`；把 100 次矩阵乘法的 0.947 ms 提交时间直接与单次 5.829 ms 比较，误判为约 6 倍。
- 错误原因：忽略同一 Stream 已保证 Event 与 kernel 的顺序，并混用了批量总时间与单次时间。
- 正确理解：同一 Stream 中按 `start.record()`、kernel、`end.record()` 排队即可建立区间，CPU 在读取 elapsed time 前等待 `end`；比较倍率时必须统一为总时间或单次时间。本次未同步 CPU 计时约低估 `582.9 / 0.947 ≈ 615` 倍。
- 是否已复测：2026-08-04 通过。经追问后纠正倍率，并能解释预热、CPU 时钟噪声、Device 同步污染和 CUDA Event 的测量范围。

## 2026-08-05：过早放置反向 Stream 等待

- 日期：2026-08-05
- 知识点：手动管理跨 Stream Tensor 生命周期
- 原回答：创建 Stream 在侧 Stream 提交工作后立即反向等待，可能造成死锁。
- 错误原因：没有区分 `wait_stream()` 只等待调用时对方已经提交的工作，把有序的双向依赖误认为无法解除的循环依赖。
- 正确理解：先有创建 Stream 的生产工作，侧 Stream 等待并消费，随后创建 Stream 再等待侧 Stream，依赖链可以依次推进，不会死锁；但反向等待放得过早会阻塞创建 Stream 后续的独立工作，损失重叠机会。
- 是否已复测：2026-08-06 通过。能够比较提前等待和释放前等待两个完整版本，并正确指出后者保留更多并发机会。

## 2026-08-06：`wait_stream()` 与 `record_stream()` 混淆

- 日期：2026-08-06
- 知识点：跨 Stream 数据依赖与 Tensor 显存生命周期
- 原回答：不清楚两个 API 的区别；一度认为 `record_stream()` 主要依靠引用计数判断 GPU 是否用完显存。
- 错误原因：混淆了 Stream 工作顺序、Python/Storage 引用归零和 allocator 判断 GPU 完成这三个层次。
- 正确理解：`wait_stream()` 给目标 Stream 的后续工作建立执行依赖；`record_stream()` 登记显存块被哪些侧 Stream 使用。最后一个 Storage 引用消失后，allocator 在已登记 Stream 上记录 CUDA Event，Event 完成后显存块才从 pending 变为可复用。
- 是否已复测：2026-08-07 通过。能分析双侧 Stream 需要分别登记，漏登 `s2` 只保护 `s1`；能说明 `record_stream()` 的保护边界取决于释放时 recorded Stream 上已排队工作，且手动 Event 必须放在最后一次使用之后。

## 2026-08-07：把 `del x` 误认为共享 Storage 最后引用释放

- 日期：2026-08-07
- 知识点：View alias 与 Tensor Storage 生命周期
- 原回答：`alias_x = x.view(-1)` 后，`del x` 会使底层 storage 进入 allocator 回收流程；真正触发回收的是 `s1` 上使用完 `alias_x`。
- 错误原因：混淆了 Python 变量名、Tensor 对象和共享 Storage 引用；把 GPU 使用完成误认为触发 allocator 回收的条件。
- 正确理解：`del x` 只删除一个 Tensor 引用。只要 `alias_x` 仍然持有同一 storage，底层显存不会进入 allocator 回收流程；真正触发回收的是最后一个持有该 Storage 的 Tensor/Storage 引用消失。`record_stream()` 绑定的是 Storage 与 Stream 的关系，不是变量名与 Stream 的关系。
- 是否已复测：2026-08-07 当场复测通过。能够判断 `x.record_stream(s1)` 可以保护 `alias_x` 读取的同一块共享 storage。

## 2026-08-09：只按显存读写判断跨 Stream 分配安全

- 日期：2026-08-09
- 知识点：CUDA caching allocator 的创建 Stream 语义
- 原回答：如果 `torch.empty()` 不写显存，就可以删除创建 Stream `s0` 到消费者 Stream `s2` 的等待。
- 错误原因：正确区分了地址分配与实际显存访问，但忽略 allocator 将分配和释放也视为带有 Stream 顺序的逻辑使用；缓存块可能仍依赖创建 Stream 上的旧操作完成。
- 正确理解：Tensor 在 `s0` 分配后交给 `s2` 首次使用时，消费者通常需要 `s2.wait_stream(s0)`；若复用的同一显存还被旧 Tensor 在 `s1` 使用，则另需 `s2.wait_event(done)`。两条依赖分别保护创建 Stream 顺序和旧 Tensor 最后使用，不能互相替代。
- 是否已复测：2026-08-09 当场通过。能把 `s2.wait_stream(s0)` 放在首次写入前，并说明它保护显存申请/创建到写入的顺序；同时保留 Event 依赖保证 `s1` 读完旧 `x`。

每条错误应包含：

- 日期
- 知识点
- 原回答
- 错误原因
- 正确理解
- 是否已复测

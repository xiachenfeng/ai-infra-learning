# Learning Inbox

- [ ] 当前优先：按新教学方法将旧知识完整重学一遍，从 CPU/GPU 执行入口开始；清单见 `sessions/2026-09-13-relearning-plan.md`。以下旧待办并入本轮相应单元，不抢先执行。
- [x] Warp 的概念，以及 Warp 与 Block、Thread、Grid 的本质区别（2026-08-03 已复测）
- [x] 学习 CUDA Stream 概念（2026-08-04 已完成理论、依赖实验与 profiler 验证）
- [ ] GPU 基础收尾：先讲解并示范 row-major 与连续访存，再完成练习和独立检查；核对已有计时/profiler 产物，随后进入 PyTorch 算子调用链。
- [ ] 选修保留：继续 CUDA tiled transpose。以 `examples/cuda/tiled_transpose.cu` 为上下文，先示范两层坐标交换，再练习 coalescing 和 `tile[32][33]` padding；恢复学习时不直接把旧题作为开场测评。此前输入 `blockIdx=(x=2, y=3)` 的题目保留为历史题目，后续独立测评使用新变式。

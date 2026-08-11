# Learning Inbox

- [x] Warp 的概念，以及 Warp 与 Block、Thread、Grid 的本质区别（2026-08-03 已复测）
- [x] 学习 CUDA Stream 概念（2026-08-04 已完成理论、依赖实验与 profiler 验证）
- [ ] 继续学习 CUDA tiled transpose：从 `examples/cuda/tiled_transpose.cu` 开始，复习 row-major、`threadIdx.x → col`、输入/输出 tile 的 `blockIdx` 坐标交换、tile 内部转置、coalescing，以及 `tile[32][33]` padding 对 bank conflict 的作用。先回答待完成问题：输入 `blockIdx=(x=2, y=3)` 时，转置后的 `output tile_row` 和 `output tile_col` 分别是多少？

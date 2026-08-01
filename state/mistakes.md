# Mistakes and Misconceptions

## 2026-08-01：CUDA 同步与计算完成

- 日期：2026-08-01
- 知识点：PyTorch eager execution 与 CUDA asynchronous execution
- 原回答：只在计时开始前同步即可测量 GPU 实际计算时间；同步后 GPU 才结束计算。
- 错误原因：混淆了“立即提交算子”“GPU 独立执行”和“CPU 等待 GPU”三个概念。
- 正确理解：CUDA 工作提交后 GPU 会独立执行并最终完成；同步使 CPU 等待并确认此前 GPU 工作完成。使用 CPU 时钟计时 GPU 操作时，通常需要在测量区间前后同步。
- 是否已复测：尚未通过。纠正后能识别异步提交，但综合复述仍把同步描述为“引发 GPU 完成”；需独立复述和代码实验。

每条错误应包含：

- 日期
- 知识点
- 原回答
- 错误原因
- 正确理解
- 是否已复测

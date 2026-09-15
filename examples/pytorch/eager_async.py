import torch

if not torch.cuda.is_available():
    raise RuntimeError("本示例需要可用的 NVIDIA GPU 和支持 CUDA 的 PyTorch。")

device = torch.device("cuda:0")

# 准备输入，并确认准备工作已完成。
input_gpu = torch.tensor([1.0, 2.0, 3.0, 4.0], device=device)
torch.cuda.synchronize(device)

# [1] 普通 eager 模式：现在发起加法操作。
output_gpu = input_gpu + 10

# [2] CPU 只打印文字，不读取 GPU 计算结果。
print("CPU: 已提交加法")

# [3] CPU 等待该设备此前的 GPU 工作完成。
torch.cuda.synchronize(device)

# [4] 将结果复制到 CPU，再显示数值。
output_cpu = output_gpu.cpu()
print(output_cpu.tolist())

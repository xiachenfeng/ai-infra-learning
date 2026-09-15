// 教学模型：8 个元素，每个 Block 4 个 Thread；不是性能配置建议。
// NVIDIA GPU + CUDA Toolkit：
// nvcc -std=c++17 thread_block_grid.cu -o thread_block_grid
// ./thread_block_grid
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>

void check_cuda(cudaError_t status, const char* operation) {
    if (status != cudaSuccess) {
        std::fprintf(stderr, "%s: %s\n", operation, cudaGetErrorString(status));
        std::exit(EXIT_FAILURE);
    }
}

// 每个 Thread 都执行这一份函数，但拥有自己的编号。
__global__ void add_ten(const float* input, float* output, int element_count) {
    const int block_index = blockIdx.x;
    const int threads_per_block = blockDim.x;
    const int local_thread_index = threadIdx.x;

    // [1] 当前 Block 负责的数据起点。
    const int block_start_index = block_index * threads_per_block;

    // [2] 当前 Thread 负责的全局元素编号。
    const int global_element_index = block_start_index + local_thread_index;

    // [3] 本例中每个有效 Thread 处理一个元素。
    if (global_element_index < element_count) {
        output[global_element_index] = input[global_element_index] + 10.0f;
    }
}

// CPU 调用：输入和输出都必须指向至少 element_count 个 float 的 GPU 空间。
void launch_add_ten(const float* input, float* output, int element_count) {
    if (element_count <= 0) {
        return;
    }
    const int threads_per_block = 4;
    const int block_count = (element_count + threads_per_block - 1)
                            / threads_per_block;

    // [4] 一次提交：block_count 个 Block，每个有 threads_per_block 个 Thread。
    add_ten<<<block_count, threads_per_block>>>(input, output, element_count);
}

int main() {
    constexpr int element_count = 8;
    const float input_cpu[element_count] = {1, 2, 3, 4, 5, 6, 7, 8};
    float output_cpu[element_count] = {};
    const size_t byte_count = sizeof(input_cpu);
    float* input_gpu = nullptr;
    float* output_gpu = nullptr;

    // 准备 GPU 存储和输入，本节不展开内存 API 的细节。
    check_cuda(cudaMalloc(reinterpret_cast<void**>(&input_gpu), byte_count), "allocate input");
    check_cuda(cudaMalloc(reinterpret_cast<void**>(&output_gpu), byte_count), "allocate output");
    check_cuda(cudaMemcpy(input_gpu, input_cpu, byte_count, cudaMemcpyHostToDevice), "copy input");

    launch_add_ten(input_gpu, output_gpu, element_count);
    check_cuda(cudaGetLastError(), "launch add_ten");
    check_cuda(cudaDeviceSynchronize(), "wait for completion");
    check_cuda(cudaMemcpy(output_cpu, output_gpu, byte_count, cudaMemcpyDeviceToHost), "copy output");

    bool correct = true;
    for (int index = 0; index < element_count; ++index) {
        std::printf("element %d: %.0f -> %.0f\n", index, input_cpu[index], output_cpu[index]);
        correct = correct && (output_cpu[index] == input_cpu[index] + 10.0f);
    }
    check_cuda(cudaFree(input_gpu), "free input");
    check_cuda(cudaFree(output_gpu), "free output");
    return correct ? EXIT_SUCCESS : EXIT_FAILURE;
}

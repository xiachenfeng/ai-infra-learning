#include <cuda_runtime.h>

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <vector>

#define CUDA_CHECK(call)                                                     \
    do {                                                                     \
        cudaError_t error = (call);                                          \
        if (error != cudaSuccess) {                                          \
            std::cerr << "CUDA error: " << cudaGetErrorString(error)         \
                      << " at " << __FILE__ << ':' << __LINE__ << '\n';      \
            std::exit(EXIT_FAILURE);                                         \
        }                                                                    \
    } while (0)

constexpr int TILE_DIM = 32;
constexpr int BLOCK_ROWS = 8;

// input is a row-major [height, width] matrix.
// output is its row-major [width, height] transpose.
__global__ void transpose_padded(
    const float* input,
    float* output,
    int width,
    int height
) {
    // The extra column changes the row stride from 32 to 33 words,
    // avoiding the stride-32 bank conflict during transposed reads.
    __shared__ float tile[TILE_DIM][TILE_DIM + 1];

    // [Position 1] Map CUDA x to matrix column and y to matrix row.
    int input_col = blockIdx.x * TILE_DIM + threadIdx.x;
    int input_row = blockIdx.y * TILE_DIM + threadIdx.y;

    // [Position 2] Coalesced global-memory reads into Shared Memory.
    for (int offset = 0; offset < TILE_DIM; offset += BLOCK_ROWS) {
        if (input_col < width && input_row + offset < height) {
            tile[threadIdx.y + offset][threadIdx.x] =
                input[(input_row + offset) * width + input_col];
        }
    }

    __syncthreads();

    // [Position 3] Swap the input tile's block coordinates in the output.
    int output_col = blockIdx.y * TILE_DIM + threadIdx.x;
    int output_row = blockIdx.x * TILE_DIM + threadIdx.y;

    // [Position 4] Swap the tile-local coordinates while keeping
    // global-memory writes coalesced.
    for (int offset = 0; offset < TILE_DIM; offset += BLOCK_ROWS) {
        if (output_col < height && output_row + offset < width) {
            output[(output_row + offset) * height + output_col] =
                tile[threadIdx.x][threadIdx.y + offset];
        }
    }
}

void launch_transpose(
    const float* input,
    float* output,
    int width,
    int height,
    cudaStream_t stream
) {
    dim3 block(TILE_DIM, BLOCK_ROWS);
    dim3 grid(
        (width + TILE_DIM - 1) / TILE_DIM,
        (height + TILE_DIM - 1) / TILE_DIM
    );

    transpose_padded<<<grid, block, 0, stream>>>(
        input,
        output,
        width,
        height
    );
    CUDA_CHECK(cudaGetLastError());
}

int main() {
    constexpr int width = 70;
    constexpr int height = 45;
    constexpr int element_count = width * height;
    constexpr size_t bytes = element_count * sizeof(float);

    std::vector<float> host_input(element_count);
    std::vector<float> host_output(element_count);

    for (int row = 0; row < height; ++row) {
        for (int col = 0; col < width; ++col) {
            host_input[row * width + col] =
                static_cast<float>(row * width + col);
        }
    }

    float* device_input = nullptr;
    float* device_output = nullptr;
    cudaStream_t stream = nullptr;

    CUDA_CHECK(cudaMalloc(&device_input, bytes));
    CUDA_CHECK(cudaMalloc(&device_output, bytes));
    CUDA_CHECK(cudaStreamCreate(&stream));

    CUDA_CHECK(cudaMemcpyAsync(
        device_input,
        host_input.data(),
        bytes,
        cudaMemcpyHostToDevice,
        stream
    ));

    launch_transpose(
        device_input,
        device_output,
        width,
        height,
        stream
    );

    CUDA_CHECK(cudaMemcpyAsync(
        host_output.data(),
        device_output,
        bytes,
        cudaMemcpyDeviceToHost,
        stream
    ));
    CUDA_CHECK(cudaStreamSynchronize(stream));

    bool correct = true;
    for (int row = 0; row < height && correct; ++row) {
        for (int col = 0; col < width; ++col) {
            float expected = host_input[row * width + col];
            float actual = host_output[col * height + row];
            if (std::fabs(expected - actual) > 1e-6f) {
                std::cerr << "Mismatch at input[" << row << ", " << col
                          << "]: expected " << expected
                          << ", got " << actual << '\n';
                correct = false;
                break;
            }
        }
    }

    std::cout << (correct ? "transpose verified\n" : "transpose failed\n");

    CUDA_CHECK(cudaStreamDestroy(stream));
    CUDA_CHECK(cudaFree(device_output));
    CUDA_CHECK(cudaFree(device_input));

    return correct ? EXIT_SUCCESS : EXIT_FAILURE;
}

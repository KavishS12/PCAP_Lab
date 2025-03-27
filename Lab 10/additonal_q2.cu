#include <stdio.h>
#include <cuda_runtime.h>

#define TILE_SIZE 16  
#define MAX_MASK_WIDTH 10  

__constant__ int d_mask[MAX_MASK_WIDTH];  

__global__ void tiled_convolution_1D(int *d_input, int *d_output, int width, int mask_width) {
    extern __shared__ int shared_mem[];  
    int radius = mask_width / 2;
    int tx = threadIdx.x;
    int idx = blockIdx.x * blockDim.x + tx;

    int shared_idx = tx + radius;
    
    if (idx < width) {
        shared_mem[shared_idx] = d_input[idx];
    } else {
        shared_mem[shared_idx] = 0;
    }

    if (tx < radius) {
        shared_mem[tx] = (idx - radius >= 0) ? d_input[idx - radius] : 0;
        shared_mem[shared_idx + TILE_SIZE] = (idx + TILE_SIZE < width) ? d_input[idx + TILE_SIZE] : 0;
    }

    __syncthreads();

    if (idx < width) {
        int sum = 0;
        for (int i = -radius; i <= radius; i++) {
            sum += shared_mem[shared_idx + i] * d_mask[i + radius];
        }
        d_output[idx] = sum;
    }
}

int main() {
    int width, mask_width;

    printf("Enter the size of the input array: ");
    scanf("%d", &width);
    printf("Enter the mask width (odd number, max %d): ", MAX_MASK_WIDTH);
    scanf("%d", &mask_width);
    
    if (mask_width > MAX_MASK_WIDTH || mask_width % 2 == 0) {
        printf("Invalid mask size! It must be an odd number <= %d.\n", MAX_MASK_WIDTH);
        return 1;
    }

    int input[width], output[width], mask[mask_width];
    int *d_input, *d_output;

    printf("Enter the input array:\n");
    for (int i = 0; i < width; i++) {
        scanf("%d", &input[i]);
    }

    printf("Enter mask:\n");
    for (int i = 0; i < mask_width; i++) {
        scanf("%d", &mask[i]);
    }

    cudaMalloc((void**)&d_input, width * sizeof(int));
    cudaMalloc((void**)&d_output, width * sizeof(int));

    cudaMemcpy(d_input, input, width * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(d_mask, mask, mask_width * sizeof(int));

    int blocks = (width + TILE_SIZE - 1) / TILE_SIZE;
    int shared_mem_size = (TILE_SIZE + 2 * (mask_width / 2)) * sizeof(int);
    
    tiled_convolution_1D<<<blocks, TILE_SIZE, shared_mem_size>>>(d_input, d_output, width, mask_width);

    cudaMemcpy(output, d_output, width * sizeof(int), cudaMemcpyDeviceToHost);

    printf("\nConvolved Output:\n");
    for (int i = 0; i < width; i++) {
        printf("%d ", output[i]);
    }
    printf("\n");

    cudaFree(d_input);
    cudaFree(d_output);

    return 0;
}
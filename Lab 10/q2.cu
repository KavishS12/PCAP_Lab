#include <stdio.h>
#include <cuda_runtime.h>

#define N 8   
#define K 3   
#define THREADS_PER_BLOCK 16

__constant__ int d_kernel[K];

__global__ void convolution_1D(int *d_arr, int *d_res, int width) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx >= width) return;

    int sum = 0.0;
    int kernel_radius = K / 2;
    for (int i = -kernel_radius; i <= kernel_radius; i++) {
        int index = idx + i;
        if (index >= 0 && index < width) {
            sum += d_arr[index] * d_kernel[i + kernel_radius];
        }
    }
    
    d_res[idx] = sum;
}

int main() {
    int arr[N], res[N], kernel[K];
    int *d_arr, *d_res;

    printf("Enter the array : ");
    for(int i=0;i<N;i++){
        scanf("%d",&arr[i]);
    }

    printf("Enter the kernel : ");
    for(int i=0;i<K;i++){
        scanf("%d",&kernel[i]);
    }

    cudaMalloc((void**)&d_arr, N * sizeof(int));
    cudaMalloc((void**)&d_res, N * sizeof(int));

    cudaMemcpy(d_arr, arr, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(d_kernel, kernel, K * sizeof(int));

    int blocks = (N + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    convolution_1D<<<blocks, THREADS_PER_BLOCK>>>(d_arr, d_res, N);

    cudaMemcpy(res, d_res, N * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Input Array:\n");
    for (int i = 0; i < N; i++) printf("%d ",arr[i]);
    printf("\n\nConvolved Output:\n");
    for (int i = 0; i < N; i++) printf("%d ",res[i]);
    printf("\n");

    cudaFree(d_arr);
    cudaFree(d_res);

    return 0;
}

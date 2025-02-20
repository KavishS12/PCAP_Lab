#include <stdio.h>
#include <stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define THREADS_PER_BLOCK 16

__global__ void oddPhase(int *d_array, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx % 2 == 1 && idx < n - 1) {
        if (d_array[idx] > d_array[idx + 1]) {
            int temp = d_array[idx];
            d_array[idx] = d_array[idx + 1];
            d_array[idx + 1] = temp;
        }
    }
}

__global__ void evenPhase(int *d_array, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx % 2 == 0 && idx < n - 1) {
        if (d_array[idx] > d_array[idx + 1]) {
            int temp = d_array[idx];
            d_array[idx] = d_array[idx + 1];
            d_array[idx + 1] = temp;
        }
    }
}

int main() {
    int N;
    printf("Enter size of the array : ");
    scanf("%d",&N);

    int *arr = (int*)malloc(N*sizeof(int));

    printf("Enter the array : ");
    for(int i=0;i<N;i++){
        scanf("%d",&arr[i]);
    }

    int *d_arr;
    cudaMalloc((void **)&d_arr,N*sizeof(int));
    cudaMemcpy(d_arr,arr,N*sizeof(int), cudaMemcpyHostToDevice);

    int numBlocks = (N + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    for (int i=0;i<N;i++) {
        oddPhase<<<numBlocks, THREADS_PER_BLOCK>>>(d_arr,N);
        cudaDeviceSynchronize();
        evenPhase<<<numBlocks, THREADS_PER_BLOCK>>>(d_arr,N);
        cudaDeviceSynchronize();
    }

    cudaMemcpy(arr, d_arr,N*sizeof(int),cudaMemcpyDeviceToHost);

    printf("Sorted Array:\n");
    for(int i=0;i<N;i++){
        printf("%d ",arr[i]);
    }
    printf("\n");

    cudaFree(d_arr);

    return 0;
}


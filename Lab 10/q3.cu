#include <stdio.h>
#include <cuda_runtime.h>

__global__ void inclusive_scan(int *arr, int *res, int n) {
    extern __shared__ int temp[];
    int thid = threadIdx.x;

    int index1 = 2 * thid;
    int index2 = 2 * thid + 1;

    if (index1 < n) temp[index1] = arr[index1];
    else temp[index1] = 0;

    if (index2 < n) temp[index2] = arr[index2];
    else temp[index2] = 0;

    __syncthreads();

    // Up-sweep (reduce)
    for (int d = 1; d < n; d *= 2) {
        __syncthreads();
        int k = (thid + 1) * d * 2 - 1;
        if (k < n) {
            temp[k] += temp[k - d];
        }
    }

    __syncthreads();

    // Down-sweep (inclusive scan)
    for (int d = n / 2; d > 0; d /= 2) {
        __syncthreads();
        int k = (thid + 1) * d * 2 - 1;
        if (k + d < n) {
            temp[k + d] += temp[k];
        }
    }

    __syncthreads();
    if (index1 < n) res[index1] = temp[index1];
    if (index2 < n) res[index2] = temp[index2];
}

int main() {
    int N;
    printf("Enter N: ");
    scanf("%d", &N);

    int *arr = (int *)malloc(N * sizeof(int));
    int *res = (int *)malloc(N * sizeof(int));
    int *d_arr, *d_res;

    printf("Enter the array: ");
    for (int i = 0; i < N; i++) {
        scanf("%d", &arr[i]);
    }

    cudaMalloc((void**)&d_arr, N * sizeof(int));
    cudaMalloc((void**)&d_res, N * sizeof(int));
    cudaMemcpy(d_arr, arr, N * sizeof(int), cudaMemcpyHostToDevice);

    int threadsPerBlock = (N + 1) / 2;
    inclusive_scan<<<1, threadsPerBlock, 2 * N * sizeof(int)>>>(d_arr, d_res, N);

    cudaMemcpy(res, d_res, N * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Resultant Array after Inclusive Scan: ");
    for (int i = 0; i < N; i++) {
        printf("%d ", res[i]);
    }
    printf("\n");

    cudaFree(d_arr);
    cudaFree(d_res);
    free(arr);
    free(res);

    return 0;
}

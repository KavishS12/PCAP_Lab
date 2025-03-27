#include <stdio.h>
#include <cuda.h>

#define M 3
#define N 4

__global__ void modify_matrix_kernel(float *A, int rows, int cols) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < rows && col < cols) {
        float val = A[row * cols + col];
        for (int i = 0; i < row; i++) { 
            val *= A[row * cols + col];
        }
        A[row * cols + col] = val;
    }
}

int main() {
    float A[M][N] = {{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}};
    float *d_A;

    cudaMalloc((void **)&d_A, M * N * sizeof(float));

    cudaMemcpy(d_A, A, M * N * sizeof(float), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(N, M);
    dim3 blocksPerGrid(1, 1);
    modify_matrix_kernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, M, N);

    cudaMemcpy(A, d_A, M * N * sizeof(float), cudaMemcpyDeviceToHost);

    printf("Modified matrix:\n");
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            printf("%.2f ", A[i][j]);
        }
        printf("\n");
    }

    cudaFree(d_A);

    return 0;
}
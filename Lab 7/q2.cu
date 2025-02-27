#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N 1024

__global__ void repeatStringKernel(const char* str_S,char* str_RS,int lenS,int output_len) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int start = idx*(2*lenS+(idx-1)*(-1))/2;
    for(int i =0; i<lenS-idx; i++){
        str_RS[start+i] = str_S[i];
    }
}

int main() {
    char str_S[N];
    printf("Enter a string : ");
    scanf("%s",str_S);

    int lenS = strlen(str_S);
    int output_len = (lenS * (lenS+1))/2;

    char* str_RS = (char*)malloc((output_len + 1) * sizeof(char));
    str_RS[output_len] = '\0';

    char *d_S, *d_str_RS;
    cudaMalloc((void**)&d_S, lenS * sizeof(char));
    cudaMalloc((void**)&d_str_RS, (output_len + 1) * sizeof(char));

    cudaMemcpy(d_S, str_S, lenS * sizeof(char), cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (output_len + threadsPerBlock - 1) / threadsPerBlock;
    repeatStringKernel<<<blocksPerGrid, threadsPerBlock>>>(d_S, d_str_RS, lenS, output_len);

    cudaMemcpy(str_RS, d_str_RS, (output_len + 1) * sizeof(char), cudaMemcpyDeviceToHost);


    printf("Input string S: %s\n", str_S);
    printf("Output string str_RS: %s\n", str_RS);

    cudaFree(d_S);
    cudaFree(d_str_RS);
    free(str_RS);

    return 0;
}
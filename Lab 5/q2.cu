#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<stdio.h>

#define THREADS_PER_BLOCK 256

__global__ void add_vectors(int *v1,int *v2,int *res,int N){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i<N) {
        res[i] = v1[i] + v2[i];
    }
}

int main(void)
{
    int N;
    printf("Enter the value of N : ");
    scanf("%d",&N);

    int *v1 = (int*)malloc(N*sizeof(int));    
    int *v2 = (int*)malloc(N*sizeof(int));
    int *res = (int*)malloc(N*sizeof(int));

    int *d_v1,*d_v2,*d_res;
    cudaMalloc((void**)&d_v1,N*sizeof(int));
    cudaMalloc((void**)&d_v2,N*sizeof(int));
    cudaMalloc((void**)&d_res,N*sizeof(int));

    for(int i=0;i<N;i++){
        v1[i] = i;
        v2[i] = 2*i;
    }

    cudaMemcpy(d_v1,v1,N*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_v2,v2,N*sizeof(int),cudaMemcpyHostToDevice);  

    int numBlocks = (N+THREADS_PER_BLOCK-1) / THREADS_PER_BLOCK;
    add_vectors<<<numBlocks,THREADS_PER_BLOCK>>>(d_v1,d_v2,d_res,N);

    cudaMemcpy(res,d_res,N*sizeof(int),cudaMemcpyDeviceToHost);
    printf("Resultant vector using %d blocks (256 threads per block) : \n",numBlocks);
    for(int i=0;i<N;i++){
        printf("%d ",res[i]);
    }
    printf("\n");

    cudaFree(d_v1);
    cudaFree(d_v2);
    cudaFree(d_res);

    free(v1);
    free(v2);
    free(res);

    return 0;
}

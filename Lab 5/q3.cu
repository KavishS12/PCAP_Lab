#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<stdio.h>

#define THREADS_PER_BLOCK 256

__global__ void calc_sine(float *angles,float *sineValues,int N){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i<N) {
        sineValues[i] = sin(angles[i]);
    }
}

int main(void)
{
    int N;
    printf("Enter the value of N : ");
    scanf("%d",&N);

    float *angles = (float*)malloc(N*sizeof(float));    
    float *sineValues = (float*)malloc(N*sizeof(float));

    float *d_angles,*d_sineValues;
    cudaMalloc((void**)&d_angles,N*sizeof(float));
    cudaMalloc((void**)&d_sineValues,N*sizeof(float));

    for(int i=0;i<N;i++){
       angles[i] = i;
    }

    cudaMemcpy(d_angles,angles,N*sizeof(float),cudaMemcpyHostToDevice);

    int numBlocks = (N+THREADS_PER_BLOCK-1) / THREADS_PER_BLOCK;
    calc_sine<<<numBlocks,THREADS_PER_BLOCK>>>(d_angles,d_sineValues,N);

    cudaMemcpy(sineValues,d_sineValues,N*sizeof(float),cudaMemcpyDeviceToHost);
    printf("Resultant sine values using %d blocks (256 threads per block) : \n",numBlocks);
    for(int i=0;i<N;i++){
        printf("%f ",sineValues[i]);
    }
    printf("\n");

    cudaFree(d_angles);
    cudaFree(d_sineValues);

    free(angles);
    free(sineValues);

    return 0;
}

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define N 1024

__global__ void cuda_count(char *str,unsigned int *d_count){
    int i = threadIdx.x;
    if(str[i]=='a'){
        atomicAdd(d_count,1);
    }
}

int main(){
    char str[N];
    char *d_str;
    unsigned int *count = (unsigned int*)malloc(sizeof(unsigned int)), *d_count;
    *count = 0;

    printf("Enter a string : ");
    scanf("%s",str);

    cudaEvent_t start, stop;
    // Create the events
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    // Record the start event
    cudaEventRecord(start, 0);

    cudaMalloc((void**)&d_str,(strlen(str)+1)*sizeof(char));
    cudaMalloc((void**)&d_count,sizeof(unsigned int));

    // Initialize d_count to 0 on the device for atomic operation
    cudaMemcpy(d_count, count, sizeof(unsigned int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_str,str,(strlen(str)+1)*sizeof(char),cudaMemcpyHostToDevice);

    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("Cuda error : %s\n",cudaGetErrorString(error));
    }   
    
    cuda_count<<<1,strlen(str)>>>(d_str,d_count);

    error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("Cuda error : %s\n",cudaGetErrorString(error));
    }  

    //Record the stop event
    cudaEventRecord(stop, 0);
    // Wait for the stop event to complete
    cudaEventSynchronize(stop);
    // Calculate the time between start and stop events
    float elapsed_time;
    cudaEventElapsedTime(&elapsed_time, start, stop);

    cudaMemcpy(count,d_count,sizeof(unsigned int),cudaMemcpyDeviceToHost);

    printf("Total occurences : %u\n",*count);
    printf("Time taken : %f ms\n",elapsed_time);

    cudaFree(d_str);
    cudaFree(d_count);
    free(count);

    return 0;

}
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<stdio.h>

#define THREADS_PER_BLOCK 256

__global__ void convolution_1D(int width,int mask_width,int *arr,int *mask_arr,int* conv_arr){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i<width){
        int Pvalue = 0;
        int start_point = i-(mask_width/2);
        for(int j=0;j<mask_width;j++){
            if(start_point+j >=0 && start_point+j < width) {
                Pvalue += (arr[start_point+j]*mask_arr[j]);
            }
        }
        conv_arr[i] = Pvalue;
    }
}

int main(void)
{
    int width,mask_width;

    printf("Enter width of the array : ");
    scanf("%d",&width);
    
    printf("Enter mask width : ");
    scanf("%d",&mask_width);
    
    int *arr = (int*)malloc(width*sizeof(int));
    int *mask_arr = (int*)malloc(mask_width*sizeof(int));
    int *conv_arr = (int*)malloc(width*sizeof(int));  
    
    printf("Enter the one-dimensional array : ");
    for(int i=0;i<width;i++){
        scanf("%d",&arr[i]);
    }

    printf("Enter the mask array : ");
    for(int i=0;i<mask_width;i++){
        scanf("%d",&mask_arr[i]);
    }

    int *d_arr,*d_mask_arr,*d_conv_arr;
    cudaMalloc((void**)&d_arr,width*sizeof(int));
    cudaMalloc((void**)&d_conv_arr,width*sizeof(int));
    cudaMalloc((void**)&d_mask_arr,mask_width*sizeof(int));

    cudaMemcpy(d_arr,arr,width*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_mask_arr,mask_arr,mask_width*sizeof(int),cudaMemcpyHostToDevice);

    int numBlocks = (width+THREADS_PER_BLOCK-1) / THREADS_PER_BLOCK;
    convolution_1D<<<numBlocks,THREADS_PER_BLOCK>>>(width,mask_width,d_arr,d_mask_arr,d_conv_arr);

    cudaMemcpy(conv_arr,d_conv_arr,width*sizeof(int),cudaMemcpyDeviceToHost);

    printf("Resultant array after convolution : \n");
    for(int i=0;i<width;i++){
        printf("%d ",conv_arr[i]);
    }
    printf("\n");

    cudaFree(d_arr);
    cudaFree(d_conv_arr);
    cudaFree(d_mask_arr);

    free(arr);
    free(conv_arr);
    free(mask_arr);

    return 0;
}

#include <cuda_runtime.h>
#include<stdio.h>
#include<stdlib.h>

__global__ void addRowise(int *mat1,int *mat2,int *res,int n){
    int i = threadIdx.x;
    int m = blockDim.x;
    if(i<m){
        for(int j=0;j<n;j++){
            res[i*n+j] = mat1[i*n+j] + mat2[i*n+j];
        }
    }
}

__global__ void addColumnwise(int *mat1,int *mat2,int *res,int m){
    int j = threadIdx.x;
    int n = blockDim.x;
    if(j<n) {
        for(int i=0;i<m;i++){
            res[i*n+j] = mat1[i*n+j] + mat2[i*n+j];
        }
    }
}

__global__ void addElementwise(int *mat1,int *mat2,int *res){
    int i = blockIdx.x;
    int j = threadIdx.x;
    int m = gridDim.x;
    int n = blockDim.x;
    if(i<m && j<n) {
        res[i*n+j] = mat1[i*n+j] + mat2[i*n+j];
    }
}

int main()
{
    int *mat1,*mat2,*res,m,n;
    int *d_mat1,*d_mat2,*d_res;

    printf("Enter the value of m : ");
    scanf("%d",&m);
    printf("Enter the value of n : ");
    scanf("%d",&n);

    int size = m*n*sizeof(int);
    mat1 = (int*)malloc(size);
    mat2 = (int*)malloc(size);
    res = (int*)malloc(size);

    printf("Enter the first matrix : \n");
    for(int i=0;i<m*n;i++){
        scanf("%d",&mat1[i]);
    }

    printf("Enter the second matrix : \n");
    for(int i=0;i<m*n;i++){
        scanf("%d",&mat2[i]);
    }

    cudaMalloc((void**)&d_mat1,size);
    cudaMalloc((void**)&d_mat2,size);
    cudaMalloc((void**)&d_res,size);

    cudaMemcpy(d_mat1,mat1,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_mat2,mat2,size,cudaMemcpyHostToDevice);

    //addRowise<<<1,m>>> (d_mat1,d_mat2,d_res,n);
    //addColumnwise<<<1,n>>>(d_mat1,d_mat2,d_res,m);
    addElementwise<<<m,n>>> (d_mat1,d_mat2,d_res);

    cudaMemcpy(res,d_res,size,cudaMemcpyDeviceToHost);

    printf("Resultant matrix : \n");
    for(int i=0;i<m;i++){
        for(int j=0;j<n;j++){
            printf("%d ",res[i*n+j]);
        }
        printf("\n");
    }

    cudaFree(d_mat1);
    cudaFree(d_mat2);
    cudaFree(d_res);

    free(mat1);
    free(mat2);
    free(res);

    return 0;

}
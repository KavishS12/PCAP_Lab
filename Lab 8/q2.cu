#include <cuda_runtime.h>
#include<stdio.h>
#include<stdlib.h>

__global__ void multiplyRowwise(int *mat1, int *mat2, int *res, int n1, int n2)
{
    int ridA = blockIdx.x * blockDim.x + threadIdx.x;
    int sum = 0;
    if (ridA < n1) {
        for (int cidB=0;cidB<n2;cidB++) {
            sum = 0;
            for (int k=0;k<n1;k++) {
                sum += (mat1[ridA*n1+k] * mat2[k*n2+cidB]);
            }
            res[ridA*n2+cidB] = sum;
        }
    }
}

__global__ void multiplyColumnwise(int *mat1, int *mat2, int *res, int m1, int n1)
{
    int cidB = blockIdx.x * blockDim.x + threadIdx.x;
    int sum = 0;
    if (cidB < n1) {
        for (int ridA = 0; ridA < m1; ridA++) {
            sum = 0;
            for (int k = 0; k < n1; k++) {
                sum += (mat1[ridA*n1+k] * mat2[k*n1+cidB]);
            }
            res[ridA*n1+cidB] = sum;
        }
    }
}

__global__ void multiplyElementwise(int *mat1, int *mat2, int *res, int n1)
{
    int ridA = blockIdx.y * blockDim.y + threadIdx.y;
    int cidB = blockIdx.x * blockDim.x + threadIdx.x;
    int sum = 0;
    if (ridA < n1 && cidB < n1) {
        for (int k = 0; k < n1; k++) {
            sum += (mat1[ridA*n1+k] * mat2[k*n1+cidB]);
        }
        res[ridA*n1+cidB] = sum;
    }
}


int main()
{
    int *mat1,*mat2,*res,m1,n1,m2,n2;
    int *d_mat1,*d_mat2,*d_res;

    printf("Enter the value of m1 : ");
    scanf("%d",&m1);
    printf("Enter the value of n1 : ");
    scanf("%d",&n1);

    printf("Enter the value of m2 : ");
    scanf("%d",&m2);
    printf("Enter the value of n2 : ");
    scanf("%d",&n2);

    if(m2 != n1) {
        printf("Dimensions do not match. Aborting...\n");
        fflush(stdout); 
        abort();
    }

    mat1 = (int*)malloc(m1*n1*sizeof(int));
    mat2 = (int*)malloc(m2*n2*sizeof(int));
    res = (int*)malloc(m1*n2*sizeof(int));

    printf("Enter the first matrix : \n");
    for(int i=0;i<m1*n1;i++){
        scanf("%d",&mat1[i]);
    }

    printf("Enter the second matrix : \n");
    for(int i=0;i<m2*n2;i++){
        scanf("%d",&mat2[i]);
    }

    cudaMalloc((void**)&d_mat1,m1*n1*sizeof(int));
    cudaMalloc((void**)&d_mat2,m2*n2*sizeof(int));
    cudaMalloc((void**)&d_res,m1*n2*sizeof(int));

    cudaMemcpy(d_mat1,mat1,m1*n1*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_mat2,mat2,m2*n2*sizeof(int),cudaMemcpyHostToDevice);

    //multiplyRowwise<<<(m1+255)/256,256>>>(d_mat1, d_mat2, d_res, n1, n2);
    //multiplyColumnwise<<<(n2+255)/256,256>>>(d_mat1, d_mat2, d_res, m1, n1);
    multiplyElementwise<<<dim3((n2+15)/16,(m1+15)/16),dim3(16,16)>>>(d_mat1, d_mat2, d_res, n1);

    cudaMemcpy(res,d_res,m1*n2*sizeof(int),cudaMemcpyDeviceToHost);

    printf("Resultant matrix : \n");
    for(int i=0;i<m1;i++){
        for(int j=0;j<n2;j++){
            printf("%d ",res[i*n2+j]);
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
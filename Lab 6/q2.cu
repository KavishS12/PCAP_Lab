#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<stdio.h>

__global__ void selectionSort(int *arr, int n) {
    int idx = blockIdx.x;
    if (idx < n) {
        for (int i=idx;i<n-1;i++) {
            int minIndex = i;
            for (int j=i+1;j<n;j++) {
                if(arr[j]<arr[minIndex]) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                int temp = arr[i];
                arr[i] = arr[minIndex];
                arr[minIndex] = temp;
            }
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
    cudaMalloc((void**)&d_arr,N*sizeof(int));
    cudaMemcpy(d_arr,arr,N*sizeof(int),cudaMemcpyHostToDevice);

    selectionSort<<<N,1>>>(d_arr,N);

    cudaMemcpy(arr,d_arr,N*sizeof(int),cudaMemcpyDeviceToHost);

    printf("Sorted Array:\n");
    for (int i=0;i<N;i++) {
        printf("%d ",arr[i]);
    }
    printf("\n");

    cudaFree(d_arr);

    return 0;
}

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 1024

__global__ void cuda_count_word(char *sentence,char *word,unsigned int *d_count,int slen,int wlen) {
    int i = threadIdx.x;
    if (i < slen) {
        int match = 1;
        for (int j = 0; j < wlen; j++) {
            if (sentence[i+j] != word[j]) {
                match = 0;
                break;
            }
        }
        if (match == 1) {
            atomicAdd(d_count, 1);
        }
    }
}

int main() {
    char sentence[N];
    char word[N];
    char *d_sentence, *d_word;
    unsigned int *count = (unsigned int*)malloc(sizeof(unsigned int)),*d_count;
    *count = 0;

    printf("Enter a sentence: ");
    fgets(sentence, N, stdin);

    printf("Enter the word to search: ");
    scanf("%s", word);

    int slen = strlen(sentence);
    int wlen = strlen(word);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    cudaMalloc((void**)&d_sentence,(slen+1)*sizeof(char));
    cudaMalloc((void**)&d_word, (wlen+1)*sizeof(char));
    cudaMalloc((void**)&d_count, sizeof(unsigned int));

    cudaMemcpy(d_sentence,sentence,(slen+1)*sizeof(char),cudaMemcpyHostToDevice);
    cudaMemcpy(d_word,word,(wlen+1)*sizeof(char),cudaMemcpyHostToDevice);
    cudaMemcpy(d_count,count,sizeof(unsigned int),cudaMemcpyHostToDevice);

    cuda_count_word<<<1, slen>>>(d_sentence, d_word, d_count, slen, wlen);

    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        printf("Cuda error: %s\n", cudaGetErrorString(error));
    }

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsed_time;
    cudaEventElapsedTime(&elapsed_time, start, stop);

    cudaMemcpy(count,d_count,sizeof(unsigned int),cudaMemcpyDeviceToHost);

    printf("Total occurrences of the word '%s': %u\n",word,*count);
    printf("Time taken: %f ms\n", elapsed_time);

    cudaFree(d_sentence);
    cudaFree(d_word);
    cudaFree(d_count);
    free(count);

    return 0;
}

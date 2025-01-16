#include "mpi.h"
#include <stdio.h>

int reverse(int num){
    int rev = 0;
    while(num!=0){
        rev = rev*10 + num%10;
        num /= 10;
    }
    return rev;
}

int main(int argc,char* argv[]){
    int rank;
    int arr[] = {18, 523, 301, 1234, 2, 14, 108, 150, 1928};
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    arr[rank] = reverse(arr[rank]);
    printf("Reversed number at index %d : %d\n",rank,arr[rank]);
    MPI_Finalize();
    return 0;
}
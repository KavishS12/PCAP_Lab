#include "mpi.h"
#include <stdio.h>

int fact(int n){
    if (n==0 || n==1) return 1;
    else return n*fact(n-1);
}

int fibonacci(int n){
    if(n==0) return 1;
    if(n==1) return 2;
    return fibonacci(n-1)+fibonacci(n-2);
}

int main(int argc,char* argv[]){
    int rank;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    if(rank%2==0){
        printf("Rank : %d - Factorial : %d\n",rank,fact(rank));
    }
    else printf("Rank : %d - Fibonacci : %d\n",rank,fibonacci(rank));
    MPI_Finalize();
    return 0;
}
#include "mpi.h"
#include <stdio.h>

int main(int argc,char* argv[]){
    int rank;
    int a=5,b=8;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    int val;
    char *op;
    if(rank == 0) {val = a+b;op="sum";}
    if(rank == 1) {val = a-b;op="difference";}
    if(rank == 2){val = a*b;op="product";}
    if(rank == 3) {val = a/b;op="division";}
    if(rank == 4) {val = a%b;op="modulus";}
    printf("Rank : %d , Operation : %s , Result = %d\n",rank,op,val);
    MPI_Finalize();
    return 0;
}
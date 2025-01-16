#include "mpi.h"
#include <stdio.h>

int main(int argc,char* argv[]){
    int rank;
    char str[] = "hello";
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    if(str[rank]>90)str[rank] = str[rank] - 32;
    else str[rank] = str[rank] + 32;
    printf("Rank : %d , String : %s\n",rank,str);
    MPI_Finalize();
    return 0;
}
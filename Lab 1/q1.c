// add the option -lm while executing this program - this links the math library to the mpicc compiler
// mpicc -o q1.out q1.c -lm

#include "mpi.h"
#include <stdio.h>
#include<math.h>

int power(int x, int rank){
    return pow(x,rank);
}

int main(int argc, char *argv[])
{
    int rank;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    printf("Rank : %d,Power : %d\n", rank, power(3,rank));
    MPI_Finalize();
    return 0;
}
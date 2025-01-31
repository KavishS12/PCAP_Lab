#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int fact(int n) {
    if (n == 0 || n == 1) return 1;
    return n*fact(n-1);
}

void handle_error(int err) {
    char error_string[256];
    int length_of_error_string;

    MPI_Error_string(err, error_string, &length_of_error_string);
    fprintf(stderr, "MPI Error: %s\n", error_string);
}

int main(int argc, char *argv[]) {
    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int N = size;
    if (rank == 0) {
        printf("Calculating the sum of factorials from 1! to %d!\n", N);
    }

    int factorial = fact(rank+1);

    int global_sum = 0;
    int err = MPI_Scan(&factorial,&global_sum,1,MPI_INT,MPI_SUM,MPI_COMM_WORLD);
    if (err != MPI_SUCCESS) {
        handle_error(err);
        MPI_Abort(MPI_COMM_WORLD, err);
    }

    printf("Rank %d: Factorial = %d, Global sum = %d\n",rank,factorial,global_sum);

    MPI_Finalize();
    return 0;
}
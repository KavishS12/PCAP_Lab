#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc,char* argv[]) {
    int rank,size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank==0 && size!=3) {
        fprintf(stderr,"3 processes required.\n");
        MPI_Abort(MPI_COMM_WORLD,1);
    }

    int mat[3][3];
    int k;
    int local_count = 0,total_count = 0;    
    if(rank == 0){
        printf("Enter the elements of a 3*3 matrix : ");
        for(int i=0;i<3;i++){
            for(int j=0;j<3;j++){
                scanf("%d",&mat[i][j]);
            }
        }

        printf("Enter the element to be searched : ");
        scanf("%d",&k);
    }

    MPI_Bcast(&k,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Bcast(mat,3*3,MPI_INT,0,MPI_COMM_WORLD);

    for(int i=0;i<3;i++){
        if(mat[rank][i] == k) local_count++;
    }
    MPI_Reduce(&local_count,&total_count,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Number of occurences of %d : %d\n",k,total_count);
    }

    MPI_Finalize();
    return 0;
}
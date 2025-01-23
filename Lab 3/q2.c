#include "mpi.h"
#include<stdio.h>
#include<stdlib.h>

int main(int argc,char *argv[]){
    int rank,size;
    int N,M,*A,*B,*C,avg,sum;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    if(rank == 0) {
        N=size;
        fprintf(stdout,"Rank : %d - Enter value of M : ",rank);
        fflush(stdout);
        scanf("%d",&M);
        A = (int*)malloc(N*M*sizeof(int));
        C = (int*)malloc(size*sizeof(int));
        fprintf(stdout,"Rank : %d - Enter N*M values : ",rank);
        fflush(stdout);
        for(int i=0;i<N*M;i++){
            scanf("%d",&A[i]);
        }
    }

    MPI_Bcast(&M,1,MPI_INT,0,MPI_COMM_WORLD);
    B = (int *)malloc(M * sizeof(int));

    MPI_Scatter(A,M,MPI_INT,B,M,MPI_INT,0,MPI_COMM_WORLD);
    fprintf(stdout,"\nRank : %d - Numbers received : ",rank);
    fflush(stdout);

    avg = 0;
    for(int i=0;i<M;i++){
        fprintf(stdout,"%d ",B[i]);
        fflush(stdout);
        avg += B[i];
    }
    avg /= M;

    MPI_Gather(&avg,1,MPI_INT,C,1,MPI_INT,0,MPI_COMM_WORLD);

    if(rank == 0) {
        sum = 0;
        fprintf(stdout,"\nRank : %d - Averages gathered : ",rank);
        fflush(stdout);
        for(int i=0;i<N;i++){
            fprintf(stdout,"%d ",C[i]);
            fflush(stdout);
            sum += C[i];
        }
        fprintf(stdout,"\nTotal Average : %d\n",sum);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
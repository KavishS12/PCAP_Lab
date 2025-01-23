#include "mpi.h"
#include<stdio.h>

int fact(int n){
    if(n==0 || n==1) return 1;
    else return n*fact(n-1);
}

int main(int argc,char *argv[]){
    int rank,size;
    int A[10],B[10],c,d,N,sum;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    if(rank == 0) {
        N=size;
        fprintf(stdout,"Rank : %d - Enter N values : ",rank);
        fflush(stdout);
        for(int i=0;i<N;i++){
            scanf("%d",&A[i]);
        }
    }
    MPI_Scatter(A,1,MPI_INT,&c,1,MPI_INT,0,MPI_COMM_WORLD);
    fprintf(stdout,"Rank : %d - Number received : %d\n",rank,c);
    fflush(stdout);
    d = fact(c);
    MPI_Gather(&d,1,MPI_INT,B,1,MPI_INT,0,MPI_COMM_WORLD);
    if(rank == 0) {
        sum = 0;
        fprintf(stdout,"Rank : %d - Result gathered : ",rank);
        fflush(stdout);
        for(int i=0;i<N;i++){
            fprintf(stdout,"%d ",B[i]);
            fflush(stdout);
            sum += B[i];
        }
        fprintf(stdout,"\nSum of factorials : %d\n",sum);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
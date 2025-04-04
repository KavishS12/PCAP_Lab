#include "mpi.h"
#include<stdio.h>

int main(int argc,char *argv[]){
    int rank,size;
    int num;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;
    if(rank==0){
        printf("Rank : %d - Enter the number to be sent :",rank);
        scanf("%d",&num);
        for(int i=1;i<size;i++){
            MPI_Send(&num,1,MPI_INT,i,1,MPI_COMM_WORLD);
        }
    }
    else {
        MPI_Recv(&num,1,MPI_INT,0,1,MPI_COMM_WORLD,&status);
        printf("Rank : %d - Number received : %d\n",rank,num);
    }

    MPI_Finalize();
    return 0;
}
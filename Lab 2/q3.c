#include "mpi.h"
#include<stdio.h>
#include<stdlib.h>

int main(int argc,char *argv[]){
    int rank,size;
    int *arr;
    int received_num,res;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;

    int buffer_size = size * sizeof(int) + MPI_BSEND_OVERHEAD;
    void *buffer = malloc(buffer_size);
    MPI_Buffer_attach(buffer,buffer_size);

    if(rank==0){
        arr = (int*)malloc(size*sizeof(int));
        printf("Rank : %d - Enter the elements of the array : ",rank);
        for(int i=0;i<size;i++){
            scanf("%d",&arr[i]);
        }
        for(int i=1;i<size;i++){
            MPI_Bsend(&arr[i],1,MPI_INT,i,1,MPI_COMM_WORLD);
        }
    }
    else if(rank%2==0) {
        MPI_Recv(&received_num,1,MPI_INT,0,1,MPI_COMM_WORLD,&status);
        res = received_num*received_num;
        printf("Rank : %d - Number received : %d   Square of the number : %d\n",rank,received_num,res);
    }
    else {
        MPI_Recv(&received_num,1,MPI_INT,0,1,MPI_COMM_WORLD,&status);
        res = received_num*received_num*received_num;
        printf("Rank : %d - Number received : %d   Cube of the number : %d\n",rank,received_num,res);
    }

    MPI_Buffer_detach(&buffer,&buffer_size);
    free(buffer);

    MPI_Finalize();
    return 0;
}
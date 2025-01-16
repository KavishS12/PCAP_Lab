#include "mpi.h"
#include<stdio.h>
#include<string.h>

int main(int argc,char *argv[]){
    int rank,size;
    char str[20];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;

    if(rank == 0) {
        printf("Rank : %d - Enter the word : ",rank);
        scanf("%s",str);
        MPI_Ssend(&str,strlen(str)+1,MPI_CHAR,1,1,MPI_COMM_WORLD);
    }

    if(rank == 1) {
        MPI_Recv(&str,20,MPI_CHAR,0,1,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Rank : %d - Word received : %s\n",rank,str);
        fflush(stdout);
        int i = 0;
        while(i < strlen(str)){
            if(str[i]>90) str[i] = str[i] - 32;
            else str[i] = str[i] + 32;
            i++;
        }
        MPI_Ssend(&str,strlen(str)+1,MPI_CHAR,0,2,MPI_COMM_WORLD);
    }
    
    if(rank ==0) {
        MPI_Recv(&str,20,MPI_CHAR,1,2,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Rank : %d - Word received after toggle: %s\n",rank,str);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
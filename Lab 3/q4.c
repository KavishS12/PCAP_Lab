#include "mpi.h"
#include<stdio.h>
#include<string.h>

int main(int argc,char *argv[]){
    int rank,size;
    char str1[100],str2[100],sub1[50],sub2[50],res[100],result[100];
    int len,chunk_size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    if(rank == 0) {
        fprintf(stdout,"Rank : %d - Enter first string : ",rank);
        fflush(stdout);
        scanf("%s",str1);
        fprintf(stdout,"Rank : %d - Enter second string : ",rank);
        fflush(stdout);
        scanf("%s",str2);
        if (strlen(str1) != strlen(str2)) {
            printf("Error: str1 and str2 must be of equal length\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        if (strlen(str1) % size != 0) {
            printf("Error: String length must be evenly divisible by the number of processes.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        } 
        len = strlen(str1);
    }

    MPI_Bcast(&len,1,MPI_INT,0,MPI_COMM_WORLD);

    chunk_size = len/size;
    MPI_Scatter(str1,chunk_size,MPI_CHAR,sub1,chunk_size,MPI_CHAR,0,MPI_COMM_WORLD);
     MPI_Scatter(str2,chunk_size,MPI_CHAR,sub2,chunk_size,MPI_CHAR,0,MPI_COMM_WORLD);

    for (int i=0;i<chunk_size;i++) {
        res[2*i] = sub1[i];
        res[2*i + 1] = sub2[i];
    }

    MPI_Gather(res,2*chunk_size,MPI_CHAR,result,2*chunk_size,MPI_CHAR,0,MPI_COMM_WORLD);

    if(rank == 0) {
       result[2*len] = '\0';
       printf("Resultant string : %s\n",result);
    }

    MPI_Finalize();
    return 0;
}
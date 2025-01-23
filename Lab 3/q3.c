#include "mpi.h"
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int main(int argc,char *argv[]){
    int rank,size;
    char str[100],*substr;
    int len,chunk_size,count,sum,*arr;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    arr = malloc(size*sizeof(int));

    if(rank == 0) {
        fprintf(stdout,"Rank : %d - Enter the string : ",rank);
        fflush(stdout);
        scanf("%s",str);
        if(strlen(str) % size != 0) {
            printf("Error: String length must be evenly divisible by the number of processes.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        } 
        len = strlen(str);
    }

    MPI_Bcast(&len,1,MPI_INT,0,MPI_COMM_WORLD);

    chunk_size = len/size;
    substr = malloc((chunk_size+1)*sizeof(char));

    MPI_Scatter(str,chunk_size,MPI_CHAR,substr,chunk_size,MPI_CHAR,0,MPI_COMM_WORLD);
    substr[chunk_size] = '\0';

    fprintf(stdout,"\nRank : %d - String received : %s\n",rank,substr);
    fflush(stdout);

    count = 0;
    for(int i=0;i<strlen(substr);i++){
        if(substr[i]=='a'||substr[i]=='e'||substr[i]=='i'||substr[i]=='o'||substr[i]=='u'||substr[i]=='A'||substr[i]=='E'||substr[i]=='I'||substr[i]=='O'||substr[i]=='U'){
            count++;
        }
    }

    MPI_Gather(&count,1,MPI_INT,arr,1,MPI_INT,0,MPI_COMM_WORLD);

    if(rank == 0) {
        sum = 0;
        fprintf(stdout,"\nRank : %d - Vowel count in each : ",rank);
        fflush(stdout);
        for(int i=0;i<size;i++){
            fprintf(stdout,"%d ",arr[i]);
            fflush(stdout);
            sum += arr[i];
        }
        fprintf(stdout,"\nTotal vowel count : %d\n",sum);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
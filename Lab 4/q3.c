#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

void ErrorHandler(int error_code)
{
    if (error_code != MPI_SUCCESS)
    {
        char error_string[BUFSIZ];
        int length_of_error_string, error_class;
        MPI_Error_class(error_code, &error_class);
        MPI_Error_string(error_code, error_string, &length_of_error_string);
        printf("%d %s\n",  error_class, error_string);
   }
}

int main(int argc,char* argv[]) {
    int rank,size,error_code;

    MPI_Init(&argc, &argv);
    error_code = MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    error_code = MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank==0 && size!=4) {
        fprintf(stderr,"4 processes required.\n");
        MPI_Abort(MPI_COMM_WORLD,1);
    }

    int mat[4][4],temp[4][4];
    int local_row[4]; 
    if(rank == 0){
        printf("Enter the elements of a 4*4 matrix : ");
        for(int i=0;i<4;i++){
            for(int j=0;j<4;j++){
                scanf("%d",&mat[i][j]);
            }
        }
    }

    error_code = MPI_Scatter(mat,4,MPI_INT,temp,4,MPI_INT,0,MPI_COMM_WORLD);
    error_code = MPI_Scan(temp, local_row, 4, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    ErrorHandler(error_code);

    for(int j=0;j<4;j++){
        printf("%d ",local_row[j]);
    }
    printf("\n");

    MPI_Finalize();
    return 0;
}
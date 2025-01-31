#include <stdio.h>
#include <mpi.h>
#include <string.h>

#define MAX_LENGTH 100

int main(int argc, char* argv[]) {
    int rank, size;
    char word[MAX_LENGTH], result[MAX_LENGTH * 2];
    int word_len;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank == 0) {
        printf("Enter a word: ");
        scanf("%s", word);
        word_len = strlen(word);
    }

    MPI_Bcast(&word_len, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(word, word_len, MPI_CHAR, 0, MPI_COMM_WORLD);

    for(int i = 0; i < word_len; i++) {
        if(rank == i) {
            for(int j = 0; j <= i; j++) {
                result[j] = word[i];
            }
            result[i + 1] = '\0';
            printf("%s", result);
        }
    }
    MPI_Finalize();
    return 0;
}

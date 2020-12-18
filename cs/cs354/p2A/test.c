#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void printstruct(int **store_winner, int size){
	for(int r = 0; r < size; r++){
		printf("%d\n", **store_winner);
		printf("(%d,%d)", *(*(store_winner + r) + 0),store_winner[r][1]);
		//		printf("(%d,%d)", store_winner[r][0],store_winner[r][1]);

	}
	printf("\n");

}

int main(int argc, char *argv[]) {   
	int size = 3;
	int **store_winner1 = malloc(sizeof(int*)*size);
	int **store_winner2 = malloc(sizeof(int*)*size);
	if(store_winner1 == NULL || store_winner2 == NULL ){
		printf("Memory allocation failed for storing winners\n");
	}
	//Allocate each row with "size" number of ints 
	for(int i = 0; i < size; i++){
		*(store_winner1 + i) = malloc(sizeof(int)*2);
		*(store_winner2 + i) = malloc(sizeof(int)*2);
		// malloc check 
		if(*store_winner1 + i == NULL){
			printf("Memory allocation failed");
		}
	}
	for(int r = 0; r < size; r++){
		store_winner1[r][0] = -100; // set row to -1
		store_winner1[r][1] = -1; // set row to -1

		store_winner2[r][0] = -1; // set col to -1
		store_winner2[r][1] = -1; // set col to -1
	}

	printstruct(store_winner1, size);

	return 0;
}
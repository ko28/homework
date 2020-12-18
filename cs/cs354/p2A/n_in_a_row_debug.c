///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Jim Skrentny
// Posting or sharing this file is prohibited, including any changes/additions.
// Used by permission for CS 354 Fall 2020, Deb Deppeler
//
////////////////////////////////////////////////////////////////////////////////
// Main File:        n_in_a_row.c
// This File:        n_in_a_row.c
// Other Files:      
// Semester:         CS 354 Fall 2020
//
// Author:           Daniel Ko
// Email:            ko28@wisc.edu
// CS Login:         ko
//
/////////////////////////// OTHER SOURCES OF HELP //////////////////////////////
//                   Fully acknowledge and credit all sources of help,
//                   other than Instructors and TAs.
//
// Persons:          Identify persons by name, relationship to you, and email.
//                   Describe in detail the the ideas and help they provided.
//
// Online sources:   Avoid web searches to solve your problems, but if you do
//                   search, be sure to include Web URLs and description of
//                   of any information you find.
////////////////////////////////////////////////////////////////////////////////
   
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
     
char *DELIM = ",";  // commas ',' are a common delimiter character for data strings
     
/* COMPLETED:       
 * Retrieves from the first line of the input file,
 * the size of the board (number of rows and columns).
 * 
 * fp: file pointer for input file
 * size: pointer to size
 */
void get_dimensions(FILE *fp, int *size) {      
    char *line = NULL;
    size_t len = 0;
    if (getline(&line, &len, fp) == -1) {
        printf("Error in reading the file.\n");
        exit(1);
    }

    char *token = NULL;
    token = strtok(line, DELIM);
    *size = atoi(token);
}       
 

void printstruct(int **store_winner, int size){
	for(int r = 0; r < size; r++){
		printf("(%d,%d)", *(*(store_winner + r) + 0), *(*(store_winner + r) + 1));
	}
	printf("\n");
}

//	wrapper to free array 
void free2darray(int **arr, int size){
	for(int i = 0; i < size; i++){
		free(*(arr + i));
	}
	free(arr);
}

/* TODO:
 * Returns 1 if and only if the board is in a valid state.
 * Otherwise returns 0.
 * 
 * board: heap allocated 2D board
 * size: number of rows and columns
 */
int n_in_a_row(int **board, int size) {
	// CASE 1: an odd size; even size boards are invalid
	if(size % 2 == 0){
		return 0;
	}

	// CASE 2: either the same number Xs as Os, or 1 more X than O since we're assuming X always moves first
	int num_x = 0;
	int num_o = 0;
	for(int r = 0; r < size; r++){
		for(int c = 0; c < size; c++){
			int val = *(*(board + r) + c);
			if(val == 1){
				num_x++;
			}
			else if(val == 2){
				num_o++;
			}
		}
	}
	// printf("num x: %d\n", num_x);
	// printf("num o: %d\n", num_o);
	if(!(num_x == num_o || num_x - 1 == num_o)){
		return 0;
	}

	// Assuming there is only 2 winning lines MAX
	// These array of ints are used to store indices of winning lines
	// Each row is a new point, store_winner[i][0] represents the row, store_winner[i][1] represents the col
	// Initialized to -1 to represent that they are empty 
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
		*(*(store_winner1 + r) + 0) = -1; // set row to -1
		*(*(store_winner1 + r) + 1) = -1; // set col to -1

		*(*(store_winner2 + r) + 0) = -1; // set row to -1
		*(*(store_winner2 + r) + 1) = -1; // set col to -1
	}


	// CASE 3: either no winner or one winner; X and O cannot both be winners
	int x_win = 0;
	int o_win = 0;
	// Check board horizontally for winners 
	printf("\nHORIZONTAL:\n");
	for(int r = 0; r < size; r++){
	printf("win x: %d\n", x_win);
	printf("win o: %d\n", o_win);
		int num_x = 0;
		int num_o = 0;
		for(int c = 0; c < size; c++){
			int val = *(*(board + r) + c);
			//printf("%d ", val);
			if(val == 1){
				num_x++;
			}
			else if(val == 2){
				num_o++;
			}
		}
		//printf("\n");

		if(num_x == size || num_o == size){
			// Store winning line 
			int **to_store = store_winner1;
			if(**to_store != -1){
				to_store = store_winner2;
			}
			for(int c = 0; c < size; c++){
				*(*(to_store + c) + 0) = r; 
				*(*(to_store + c) + 1) = c;
			}


			if(num_x == size){
				x_win++;
			}
			else if(num_o == size){
				o_win++;
			}
		}

	}

	// Check board vertically for winners 
	printf("\nVERTICAL:\n");
		printf("win x: %d\n", x_win);
	printf("win o: %d\n", o_win);
	for(int c = 0; c < size; c++){
		// printf("start of c:%d\n", c);
		// printf("winner1\n");
		// printstruct(store_winner1, size);
		// printf("winner2\n");
		// printstruct(store_winner2, size);
		int num_x = 0;
		int num_o = 0;
		for(int r = 0; r < size; r++){
			int val = *(*(board + r) + c);
			if(val == 1){
				num_x++;
			}
			else if(val == 2){
				num_o++;
			}
		}
		// printf("num x: %d\n", num_x);
		// printf("num o: %d\n", num_o);

		if(num_x == size || num_o == size){
			// Store winning line 
			int **to_store = store_winner1;
			if(**to_store != -1){
				to_store = store_winner2;
			}
			for(int r = 0; r < size; r++){
				*(*(to_store + r) + 0) = r; 
				*(*(to_store + r) + 1) = c;
			}
			

			if(num_x == size){
				x_win++;
			}
			else if(num_o == size){
				o_win++;
			}
		}
		
	}
	

	// Check board diagonally for winners 
	num_x = 0;
	num_o = 0;
	// Top right to bottom left 
	for(int d = 0; d < size; d++){
		int val = *(*(board + d) + d);
		if(val == 1){
			num_x++;
		}
		else if(val == 2){
			num_o++;
		}
	}

	if(num_x == size || num_o == size){
		// Store winning line 
		int **to_store = store_winner1;
		if(**to_store != -1){
			to_store = store_winner2;
		}
		for(int d = 0; d < size; d++){
			*(*(to_store + d) + 0) = d; 
			*(*(to_store + d) + 1) = d;
		}
	
		if(num_x == size){
			x_win++;
		}	
		else if(num_o == size){
			o_win++;
		}
	} 
	


	// Top right to bottom left 
	num_x = 0;
	num_o = 0;
	for(int d = 0; d < size; d++){
		int val = *(*(board + (size - d - 1)) + d);
		if(val == 1){
			num_x++;
		}
		else if(val == 2){
			num_o++;
		}
	}
	if(num_x == size || num_o == size){
		// Store winning line 
		int **to_store = store_winner1;
		if(**to_store != -1){
			to_store = store_winner2;
		}
		for(int d = 0; d < size; d++){
			*(*(to_store + d) + 0) = (size - d - 1); 
			*(*(to_store + d) + 1) = d;
		}

		if(num_x == size){
			x_win++;
		}	
		else if(num_o == size){
			o_win++;
		}
	} 

	printf("win x: %d\n", x_win);
	printf("win o: %d\n", o_win);

	// Check if there is no winner 
	if(o_win == 0 && x_win == 0){
		free2darray(store_winner1,size);
		free2darray(store_winner2,size);
		return 1;
	}
	// Check if both players won
	if(o_win > 0 && x_win > 0){
		free2darray(store_winner1,size);
		free2darray(store_winner2,size);
		return 0;
	}


	// CASE 4: either one winning line (i.e., row, column, or diagonal), or two winning lines that intersect on one mark; two parallel winning lines are invalid
	
	// 4a: one winning line 
	if((x_win == 1 && o_win == 0) || (x_win == 0 && o_win == 1)){
		free2darray(store_winner1,size);
		free2darray(store_winner2,size);
		return 1;
	}

	// 4c: two winning lines that intersect on one mark
	int num_of_intersect = 0;
	printstruct(store_winner1, size);
	printstruct(store_winner2, size);

	for(int i = 0; i < size; i++){
		for(int j = 0; j < size; j++){
			printf("(%d,%d) vs (%d,%d)\n", 
				*(*(store_winner1 + i) + 0), *(*(store_winner1 + i) + 1), *(*(store_winner2 + j) + 0),*(*(store_winner2 + j) + 1));

			if(*(*(store_winner1 + i) + 0) == *(*(store_winner2 + j) + 0) &&
			   *(*(store_winner1 + i) + 1) == *(*(store_winner2 + j) + 1)){
				
				num_of_intersect++;		
			}
		}
	}
	printf("num_of_intersect: %d\n", num_of_intersect);
	if(num_of_intersect != 1){
		free2darray(store_winner1,size);
		free2darray(store_winner2,size);
		return 0;
	}
	
	free2darray(store_winner1,size);
	free2darray(store_winner2,size);
    return 1;   
	
}    
  
 
   
/* PARTIALLY COMPLETED:
 * This program prints Valid if the input file contains
 * a game board with either 1 or no winners; and where
 * there is at most 1 more X than O.
 * 
 * argc: CLA count
 * argv: CLA value
 */
int main(int argc, char *argv[]) {              

    //TODO: Check if number of command-line arguments is correct.
	if(argc != 2){
		printf("Incorrect number of command line arguments. Enter only the name of file.\n");
		printf("%d\n", argc);
        exit(1);
	}

    //Open the file and check if it opened successfully.
    FILE *fp = fopen(*(argv + 1), "r");
    if (fp == NULL) {
        printf("Can't open file for reading.\n");
        exit(1);
    }

    //Declare local variables.
    int size;
	int **board;

    //TODO: Call get_dimensions to retrieve the board size.
	get_dimensions(fp, &size); 

    //TODO: Dynamically allocate a 2D array of dimensions retrieved above.
	//1D array of pointers which will point to the rows of our board
	board = malloc(sizeof(int*)*size);
	// malloc check 
	if(board == NULL){
		printf("Memory allocation failed");
	}

	//Allocate each row with "size" number of ints 
	for(int c = 0; c < size; c++){
		*(board + c) = malloc(sizeof(int)*size);
		// malloc check 
		if(*board + c == NULL){
			printf("Memory allocation failed");
		}
	}

/* 	for(int r = 0; r < size; r++){
		for(int c = 0; c < size; c++){
			board[r][c] = r;
		}
	}
	
	for(int r = 0; r < size; r++){
			for(int c = 0; c < size; c++){
				printf("%d ", board[r][c]);
			}
			printf("\n");
	}

	exit(1); */


    //Read the file line by line.
    //Tokenize each line wrt the delimiter character to store the values in your 2D array.
    char *line = NULL;
    size_t len = 0;
    char *token = NULL;
    for (int i = 0; i < size; i++) {

        if (getline(&line, &len, fp) == -1) {
            printf("Error while reading the file.\n");
            exit(1);
        }

        token = strtok(line, DELIM);
        for (int j = 0; j < size; j++) {
            //TODO: Complete the line of code below
            //to initialize your 2D array.
            /* ADD ARRAY ACCESS CODE HERE */ 
			*(*(board + i) + j) = atoi(token);
            token = strtok(NULL, DELIM);
        }
    }

    //TODO: Call the function n_in_a_row and print the appropriate
    //output depending on the function's return value.
	n_in_a_row(board, size) ? printf("valid\n") : printf("invalid\n");


    //TODO: Free all dynamically allocated memory.
	//Free each 1d array
	for(int c = 0; c < size; c++){
		free(*(board + c));
	}
	//Free pointer to 2d array
	free(board);
	board = NULL;


    //Close the file.
    if (fclose(fp) != 0) {
        printf("Error while closing the file.\n");
        exit(1);
    } 
     
    return 0;       
}       



                                        // FIN

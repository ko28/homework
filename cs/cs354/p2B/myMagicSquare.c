///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Jim Skrentny
// Posting or sharing this file is prohibited, including any changes/additions.
// Used by permission, CS 354 Fall 2020, Deb Deppeler
//
////////////////////////////////////////////////////////////////////////////////
// Main File:        myMagicSquare.c
// This File:        myMagicSquare.c
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

// Structure that represents a magic square
typedef struct {
    int size;      // dimension of the square
    int **magic_square; // pointer to heap allocated magic square
} MagicSquare;

/* Prompts the user for the magic square's size, reads it,
 * checks if it's an odd number >= 3 (if not display the required
 * error message and exit), and returns the valid number.
 */
int getSize() {
	printf("Enter magic square's size (odd integer >=3)\n");
	int size;
	scanf("%d", &size);
	if(size < 3){
		printf("Size must be >= 3.\n");
		exit(1);
	}
	if(size % 2 == 0){
		printf("Size must be odd.\n");
		exit(1);
	}
    return size;   
} 

/* 
 * Makes a magic square of size n using the alternate 
 * Siamese magic square algorithm from assignment and 
 * returns a pointer to the completed MagicSquare struct.
 *
 * n the number of rows and columns
 */
MagicSquare *generateMagicSquare(int n) {

	// initialize 2d array with empty values (represented by 0)
	int **square_arr = malloc(sizeof(int *)*n);
	// malloc check 
	if(square_arr == NULL){
		printf("Memory allocation failed");
		exit(1);
	}
	for(int i = 0; i < n; i++){
		*(square_arr + i) = malloc(sizeof(int)*n);
		// malloc check 
		if(*(square_arr + i) == NULL){
			printf("Memory allocation failed");
			exit(1);
		}
		// default value
		for(int j = 0; j < n; j++){
			*(*(square_arr + i) + j) = 0;
		}
	}

	// Run alternate Siamese magic square algorithm
	// Starting row and col (central row in the last column)
	int r =  n/2;
	int c =  n-1;
	for(int i = 1; i <= n*n;){
		
		*(*(square_arr + r) + c) = i++;
		// Move diagonally bottom-right, by one row and column, and place the next number in that position.
		// Wrap around if needed
		int new_r = r;
		int new_c = c;
		if(new_r + 1 >= n){
			new_r = 0;
		}
		else{
			new_r++;
		}
		if(new_c + 1 >= n){
			new_c = 0;
		}
		else{
			new_c++;
		}
		// If the next position is already filled with a number then place it one col before the current position.
		if(*(*(square_arr + new_r) + new_c) != 0){
			new_r = r;
			new_c = c - 1;
		}
		r = new_r;
		c = new_c;
	}


	// Instantiate magic square 
	MagicSquare *Square = malloc(sizeof(MagicSquare));
	Square->size = n;
	Square->magic_square = square_arr;
    return Square;    
} 

/* 
 * Opens a new file (or overwrites the existing file)
 * and writes the square in the specified format.
 *
 * magic_square the magic square to write to a file
 * filename the name of the output file
 */
void fileOutputMagicSquare(MagicSquare *magic_square, char *filename) {
	FILE *fp = fopen(filename, "w");
    if (fp == NULL) {
        printf("Can't open file for reading.\n");
        exit(1);
    }
	//*(*(square_arr + new_r) + new_c)
	int size =  magic_square->size;
	int **square_arr = magic_square->magic_square;
	fprintf(fp, "%d\n", size);
	
	for(int i = 0; i < size; i++){
		for(int j = 0; j < size; j++){
			fprintf(fp, "%d ", *(*(square_arr + i) + j));
		}
		// no need for extra empty line at the end
		if(i != size - 1){
			fprintf(fp, "\n");
		}
	}

}

/* 
 * Generates a magic square of the user specified size and
 * output the square to the output filename
 */
int main(int argc, char *argv[]) {
    // Check input arguments to get output filename
	if(argc != 2){
		printf("Usage: ./myMagicSquare <output_filename>\n");
		exit(1);
	}

    // Get magin square's size from user
	int size = getSize();

    // Generate the magic square
	MagicSquare *Square = generateMagicSquare(size);

    // Output the magic square
	fileOutputMagicSquare(Square, *(argv + 1));

	// Free magic square
	int **square_arr = Square->magic_square;
	for(int i = 0; i < size; i++){
		free(*(square_arr + i));
	}
	free(square_arr);
	free(Square);

    return 0;
} 


                                                         
//				myMagicSquare.c      


///////////////////////////////////////////////////////////////////////////////
// Main File:        mySigHandler.c
// This File:        division.c
// Other Files:		 sendsig.c 
// Semester:         CS 354 Fall 2020
// Instructor:       deppeler
//
// Discussion Group: DISC 633 
// Author:           Daniel Ko
// Email:            ko28@wisc.edu
// CS Login:         ko
//
/////////////////////////// OTHER SOURCES OF HELP //////////////////////////////
//                   fully acknowledge and credit all sources of help,
//                   other than Instructors and TAs.
//
// Persons:          Identify persons by name, relationship to you, and email.
//                   Describe in detail the the ideas and help they provided.
//
// Online sources:   avoid web searches to solve your problems, but if you do
//                   search, be sure to include Web URLs and description of 
//                   of any information you find.
//////////////////////////// 80 columns wide ///////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <signal.h> 
#include <string.h>

int num_divisions = 0;
const int BUFFER_SIZE = 100;

void handle_SIGFPE(){
	printf("Error: a division by 0 operation was attempted.\n");
	printf("Total number of operations completed successfully: %d\n", num_divisions);
	printf("The program will be terminated.\n");
	exit(0);
}

void handle_SIGINT(){
	printf("\nTotal number of operations completed successfully: %d\n", num_divisions);
	printf("The program will be terminated.\n");
	exit(0);
}

int main(){
	// Signal hander for SIGFPE + binding 
	struct sigaction act_fpe;
	memset(&act_fpe, 0, sizeof(act_fpe)); 	
	act_fpe.sa_handler = &handle_SIGFPE;
	if(sigaction(SIGFPE, &act_fpe, NULL) != 0){
    	printf("Error binding SIGFPE handler\n");
    	exit(1);
	}

	// Signal hander for SIGINT + binding 
	struct sigaction act_int;
	memset(&act_int, 0, sizeof(act_int)); 	
	act_int.sa_handler = &handle_SIGINT;
	if(sigaction(SIGINT, &act_int, NULL) != 0){
    	printf("Error binding SIGINT handler\n");
    	exit(1);
	}

	// Perform division until user quits or divide by 0 occurs.
	char buffer[BUFFER_SIZE]; 
	while(1){
		printf("Enter first integer: ");
		fgets(buffer , BUFFER_SIZE, stdin);
		int a = atoi(buffer);

		printf("Enter second integer: ");
		fgets(buffer , BUFFER_SIZE, stdin);
		int b = atoi(buffer);

		printf("%d / %d is %d with a remainder of %d\n", a, b, a / b, a % b);
		num_divisions++;
	}

}



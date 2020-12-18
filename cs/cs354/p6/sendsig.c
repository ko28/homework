///////////////////////////////////////////////////////////////////////////////
// Main File:        mySigHandler.c
// This File:        sendsig.c
// Other Files:		 division.c
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
#include <string.h>
#include <signal.h>
#include <stdlib.h>  

int main(int argc, char* argv[]) {

	// Check for correct input, assume pid is correct 
	if(argc != 3 || (strcmp(argv[1], "-u") && strcmp(argv[1], "-i"))){
		printf("Usage: <signal type> <pid>\n");
	}

	int pid = atoi(argv[2]);

	// Send SIGINT 
	if(strcmp(argv[1], "-i") == 0){
		kill(pid, SIGINT);
	}

	// Send SIGUSR1 
	if(strcmp(argv[1], "-u") == 0){
		kill(pid, SIGUSR1);
	}

	return 0;
}
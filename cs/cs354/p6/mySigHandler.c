///////////////////////////////////////////////////////////////////////////////
// Main File:        
// This File:        mySigHandler.c
// Other Files:		 division.c, sendsig.c 
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
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

static int DELAY = 3;
int sigusr1_count = 0;

void handle_SIGALRM(){
	time_t t;
	time(&t);
	printf("PID: %d CURRENT TIME: %s", getpid(), ctime(&t));
	alarm(DELAY);
}

void handle_SIGUSR1(){
	sigusr1_count++;
	printf("SIGUSR1 handled and counted!\n");
}

void handle_SIGINT(){
	printf("\nSIGINT handled.\n");
	printf("SIGUSR1 was handled %d times. Exiting now.\n", sigusr1_count);
	exit(0);
}

int main(){

	// Signal hander for SIGALRM + binding 
	printf("Pid and time print every 3 seconds.\n");
	printf("Enter Ctrl-C to end the program.\n");
	struct sigaction act;
	memset(&act, 0, sizeof(act)); 	
	act.sa_handler = &handle_SIGALRM;
	if(sigaction(SIGALRM, &act, NULL) != 0){
    	printf("Error binding SIGARM handler\n");
    	exit(1);
	}

	// Generate a SIGALRM signal
	alarm(DELAY);

	// Signal hander for SIGUSR1 + binding 
	struct sigaction act_usr;
	memset(&act_usr, 0, sizeof(act_usr)); 	
	act_usr.sa_handler = &handle_SIGUSR1;
	if(sigaction(SIGUSR1, &act_usr, NULL) != 0){
    	printf("Error binding SIGUSR1 handler\n");
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
	while(1);

	return 0;
}
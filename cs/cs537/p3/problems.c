#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdarg.h>

//static const int BUFFER_SIZE = 512;


int main(){
	const char *userline = "test";
	
}


// gcc -Wall -Werror -g -o problems problems.c
/*
	valgrind --leak-check=full \
		 --show-leak-kinds=all \
		 --track-origins=yes \
		 --verbose \
		 --log-file=problems-out.txt \
		 ./problems
*/
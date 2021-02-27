#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdarg.h>
#include "keyval.h"
/* void print(const char *string){
	// Use write() to avoid output buffering.
	ssize_t bytes = write(STDOUT_FILENO, string, strlen(string));
	assert(bytes > 0);
} */

// Perform clean up before calling exit 
void my_exit(int __status){
	free_list();	// For alias list
	exit(__status);
}

void print(const char *format, ...){
	// convert variadic param to va_list
	va_list vl;
	va_start(vl, format);

	char buffer[100];
	vsnprintf(buffer, 100, format, vl);
	
	// Use write() to avoid output buffering.
	ssize_t bytes = write(STDOUT_FILENO, buffer, strlen(buffer));
	va_end(vl);
	assert(bytes > 0);
}

void print_err(const char *format, ...){
	// convert variadic param to va_list
	va_list vl;
	va_start(vl, format);

	char buffer[100];
	vsnprintf(buffer, 100, format, vl);
	
	// Use write() to avoid output buffering.
	ssize_t bytes = write(STDERR_FILENO, buffer, strlen(buffer));
	va_end(vl);
	assert(bytes > 0);
}

// add whitespace around greater than sign: >
void space_gt(char *str){
    char buffer[512]; 
    int b = 0;
    for (int i = 0; i < strlen(str); i++){
        if(str[i] == '>'){
            buffer[b++] = ' ';
            buffer[b++] = '>';
            buffer[b++] = ' ';
        }
        else{
            buffer[b++] = str[i];
        }
    }
    buffer[b] = '\0';
	strcpy(str, buffer);
}

void handle_alias(char **args, int len){
/* 	for(int i = 0; i < len; i++){
		print("args[%d]: %s\n", i, args[i]);
	} */
	// Case 1: "alias"
	// Display all the aliases that have been set up with one per line
	if(len == 1){
		//print("Case 1\n");
		print_list();
	}

	// Case 2: "alias <word>"
	// If the word matches a current alias-name, print the alias-name and corresponding replacement value
	// If the word does not match a current alias-name, just continue
	else if(len == 2){
		//print("Case 2\n");
		const char *val = get(args[1]);
		if(val != NULL){
			print("%s %s\n", args[1], val);
		}
	}

	// Case 3: "alias <word> <replacement string>"
	// Set up an alias between the alias-name and the value (e.g. alias ll /bin/ls -l -a).
	// If the alias-name was already being used, just replace the old value with the new value.
	else{
		//print("Case 3\n");
		// Dangerous alias names
		if((strcmp("alias", args[1]) == 0) || (strcmp("unalias", args[1]) == 0) || (strcmp("exit", args[1]) == 0)){
			print_err("alias: Too dangerous to alias that.\n");
		}
		else{
			delete(args[1]);
			char buffer[512];
			strcpy(buffer,"");
			for(int i = 2; i < len; i++){
				strcat(buffer, args[i]);
				strcat(buffer, " ");
			}
			insert(args[1], buffer);
		}
	}
}

void handle_unalias(){

}

void handle_line(const char *userline)
{
    if (strlen(userline) <= 0)
        return;
    
	// Make a copy in case we need to modify in place.
    char *line = strndup(userline, 512);
    // Remove trailing newline.
    for (int i = strlen(line) - 1; i >= 0; --i) {
        if (line[i] == '\n')
            line[i] = '\0';
    }

	// redirection symbol format correction
	space_gt(line);

	// convert userline to list of args 
	char *args[100]; 
	char *word = strtok(line, " \t\n\v\f\r");
	int i;
	for (i = 0; word != NULL; i++){
		args[i] = word;
		word = strtok(NULL, " \t\n\v\f\r");
	}
	args[i] = NULL;

	// check for exit 
	if(args[0] && strcmp("exit", args[0]) == 0){
		free(line);
		my_exit(0);
	}

	// check for adding alias
	if(args[0] && strcmp("alias", args[0]) == 0){
		handle_alias(args, i);
		free(line);
		return;
	}

	// check if command is alias 
	if(args[0] && contains(args[0])){
		handle_line(get(args[0]));
		free(line);
		return;
	}

	// check for redirection 
	FILE *fp = NULL;
	int std_out = dup(STDOUT_FILENO);
	for(int j = 0; j < i; j++) {
		//print("%d: %s\n",j, args[j]);
		// (> exists) 
		if(strcmp(">", args[j]) == 0) {
			// (exists command to redirect) and (exactly 1 param after >) and (next param is not >) 
			if((j > 0) && (j+1 == i-1) && (strcmp(">", args[j+1]) != 0)) {
				fp = fopen(args[j+1], "w"); // discard old contents if exists and create file
				dup2(fileno(fp), STDOUT_FILENO); // redirect stdout to file 
				args[j] = NULL; // discard everything after > before running command
			}
			else {
				print_err("Redirection misformatted.\n");
				free(line);
				return;
			}
		}
		
	}
		
	//exit(0);

	// Run command in a child process 
	if(i > 0){
		pid_t pid = fork();
		if (pid != -1) {
			// is child
			if (pid == 0) {
				// printf("args[0]: %s\n", args[0]);
				execv(args[0], args);

				// if child reached here, exec failed
				print_err("%s: Command not found.\n", args[0]);
				_exit(1);
			}
			// wait for child to finish exec
			else {
				int status;
				waitpid(pid, &status, 0); 
			}
		}
		else {
			print_err("Fork failed. Cannot run  command\n");
		}
	}

	// Clean up
	free(line);
	// restore stdout and close file
	if (fp != NULL) {
		fclose(fp);
		dup2(std_out, STDOUT_FILENO);
	}
}

void handle_batch(const char *filename){
	//print(sprintf("fileeee is %s.\n",filename));
	//print("fileeee is %s.\n", filename, filename);
	char buffer[512];

	FILE *fp = fopen(filename, "r");
	
	if (fp == NULL) {
		print_err("Error: Cannot open file %s.\n", filename);
    	my_exit(1);
  	}

  	while (fgets(buffer, 512, fp) != NULL) {
   		print(buffer);
		handle_line(buffer);
	}

	fclose(fp);
}

void handle_interactive(){
	char userline[512];

    while (1)
    {
		print("mysh> ");

        // Wait for user input line.
        char *ret = fgets(userline, 512, stdin);
        if (ret == NULL) // EOF
            break;

        handle_line(userline);
    }
}

int main(int argc, char *argv[])
{
    // Incorrect args/input
	if (argc > 2){
		print_err("Usage: mysh [batch-file]\n");
		exit(1);
	}

	// Batch mode
	else if (argc == 2){
		handle_batch(argv[1]);
	}

	// Interactive mode 
    else{
		handle_interactive();
	}

    return 0;
}
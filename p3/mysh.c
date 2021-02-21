#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdarg.h>

/* void print(const char *string){
	// Use write() to avoid output buffering.
	ssize_t bytes = write(STDOUT_FILENO, string, strlen(string));
	assert(bytes > 0);
} */

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
		exit(0);
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
    	exit(1);
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
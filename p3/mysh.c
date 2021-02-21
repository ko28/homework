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

void printerr(const char *format, ...){
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

void handle_line(const char *userline)
{
    if (strlen(userline) <= 0)
        return;
    
	// Make a copy in case we need to modify in place.
    char *line = strdup(userline);
    // Remove trailing newline.
    for (int i = strlen(line) - 1; i >= 0; --i) {
        if (line[i] == '\n')
            line[i] = '\0';
    }

	// process userline
	char *args[100]; 
	char *word = strtok(line, " ");
	int i;
	for (i = 0; word != NULL; i++){
		args[i] = word;
		word = strtok(NULL, " ");
	}
	args[i] = NULL;

	// check for exit 
	if(args[0] && strcmp("exit", args[0]) == 0){
		free(line);
		exit(0);
	}

									// for(int j = 0; j < i; j++)
									//	printf("%d: %s\n",j, args[j]);

	// make sure args has a command 
	if(i > 0){
		pid_t pid = fork();
		if (pid != -1)
		{
			// is child
			if (pid == 0)
			{
				// printf("args[0]: %s\n", args[0]);
				execv(args[0], args);

				// if child reached here, exec failed
				printerr("%s: Command not found.\n", args[0]);
				_exit(1);
			}
			// wait for child to finish exec
			else
			{
				int status;
				waitpid(pid, &status, 0); 
			}
		}
		else
		{
			// failed fork
		}
	}

    // printf("inputted command was %s", userline);
	free(line);
}

void handle_batch(const char *filename){
	//print(sprintf("fileeee is %s.\n",filename));
	//print("fileeee is %s.\n", filename, filename);
	char buffer[100];

	FILE *fp = fopen(filename, "r");
	
	if (fp == NULL) {
		printerr("Error: Cannot open file %s.\n", filename);
    	exit(1);
  	}

  	while (fgets(buffer, 100, fp) != NULL) {
   		print(buffer);
		handle_line(buffer);
	}

	fclose(fp);
}

void handle_interactive(){
	char userline[512];

    while (1)
    {
        // Use write() to avoid output buffering.
        //ssize_t bytes = write(STDOUT_FILENO, "mysh> ", 6);
        //assert(bytes > 0);
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
		printerr("Usage: mysh [batch-file]\n");
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
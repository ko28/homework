#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

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

	for(int j = 0; j < i; j++)
		printf("%d: %s\n",j, args[j]);

	// make sure args has a command 
	if(i > 0){
		pid_t pid = fork();
		if (pid != -1)
		{
			// is child
			if (pid == 0)
			{
				printf("args[0]: %s\n", args[0]);
				execv(args[0], args);

				// if child reached here, exec failed
				printf("simplesh: exec failed\n");
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

    printf("inputted command was %s", userline);
	free(line);
}

int main(int argc, char *argv[])
{
    // handle_batch
	if (argc > 2){
		printf("Usage: mysh [batch-file]\n");
		exit(1);
	}


	// User mode 
    char userline[512];

    while (1)
    {
        // Use write() to avoid output buffering.
        ssize_t bytes = write(STDOUT_FILENO, "mysh> ", 6);
        assert(bytes > 0);

        // Wait for user input line.
        char *ret = fgets(userline, 512, stdin);
        if (ret == NULL) // EOF
            break;

        handle_line(userline);
    }

    return 0;
}
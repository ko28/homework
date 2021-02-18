#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

void handle_interactive(const char *userline)
{
    if (strlen(userline) <= 0)
        return;

    // process userline

    //
    pid_t pid = fork();
    if (pid != -1)
    {
        // is child
        if (pid == 0)
        {
			char *args[2] = {"/bin/ls", NULL};
            execv(args[0], args);
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

    printf("inputted command was %s", userline);
}

int main(int argc, char *argv[])
{
    // handle_batch

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

        handle_interactive(userline);
    }

    return 0;
}
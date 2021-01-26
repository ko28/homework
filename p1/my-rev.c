#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// if filename is null read from stdin 
void rev(char *filename){
	FILE *fp;
	if(filename == NULL){
		fp = stdin;
	}
	else{
		fp = fopen(filename, "r");
	}

	if (fp == NULL) {
		printf("my-rev: cannot open file\n");
		exit(1);
	}

	
	char buffer[100];
	char revbuf[100];
	memset(buffer, '\0', 100); // clear str
	memset(revbuf, '\0', 100); // clear str
	while(fgets(buffer, 100, fp) != NULL) {
		// reverse string in buffer
		int len = strlen(buffer) - 1;
		//printf("len: %d\n", len);
		//printf("buffer: %s", buffer);
		for(int i = 0; i < len; i++){
			//printf("i: %d  len-i: %d\n", i, len-i);
			//printf("buffer[len - i]: %c \n", buffer[len-i]);
			revbuf[i] = buffer[len - i - 1];
			//printf("revbuf[i]: %c\n", revbuf[i]); 
		}
		//printf("revbuf[0]: %c\n", revbuf[0]); 
		revbuf[len] = '\n';
		revbuf[len + 1] = '\0';
		printf("%s", revbuf);
		//exit(1);
		
		memset(revbuf, '\0', 100); // clear string 
   	}

	fclose(fp);
}

int main(int argc, char *argv[])
{
	if(argc >= 1){
		// -V : print information about this utility; 
		if(strcmp(argv[1], "-V") == 0){
			printf("my-rev from CS537 Spring 2021\n");
			return 0;
		}
		
		// -h: prints help information about this utility
		// TODO:
		if(strcmp(argv[1], "-h") == 0){
			printf("Usage: my-rev \n");
			return 0;
		}

		// specify file
		if(strcmp(argv[1], "-f") == 0 && argc == 3){
			rev(argv[2]);
			return 0;
		}

		// stdin
		if(argc == 1){
			rev(NULL);
			return 0;
		}

	}

	// unspecified commands 
	printf("my-rev: invalid command line\n");
	return 1;
}
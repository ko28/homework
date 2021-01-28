// Copyright 2021 Daniel Ko, ko@cs.wisc.edu
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// if filename is null read from stdin
void look(char *search, char *filename) {
  FILE *fp;
  if (filename == NULL) {
    fp = stdin;
  } else {
    fp = fopen(filename, "r");
  }

  if (fp == NULL) {
    printf("my-look: cannot open file\n");
    exit(1);
  }

  char buffer[100];
  int search_len = strlen(search);
  while (fgets(buffer, 100, fp) != NULL) {
    if (strncasecmp(buffer, search, search_len) == 0) {
      printf("%s", buffer);
    }
  }

  fclose(fp);
}

int main(int argc, char *argv[]) {
  if (argc > 1) {
    // -V : print information about this utility;
    if (strcmp(argv[1], "-V") == 0) {
      printf("my-look from CS537 Spring 2021\n");
      return 0;
    }

    // -h: prints help information about this utility
    // TODO:
    if (strcmp(argv[1], "-h") == 0) {
      printf("Usage: my-look \n");
      return 0;
    }

    // specify file
    if (strcmp(argv[1], "-f") == 0 && argc == 4) {
      look(argv[3], argv[2]);
      return 0;
    }

    // stdin
    if (argc == 2) {
      look(argv[1], NULL);
      return 0;
    }
  }

  // unspecified commands
  printf("my-look: invalid command line\n");
  return 1;
}

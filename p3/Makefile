# Build by running 'make mysh' or simply 'make'
# Clean by running 'make clean'

# A couple standard variables:
# C Compiler
CC=gcc
# C Flags
CFLAGS=-Wall -Werror -g
SANFLAG=-fsanitize=address -static-libasan

# Main build command
#mysh: mysh.c sample_module.c sample_module.h
#	$(CC) $(CFLAGS) -o mysh mysh.c sample_module.c
mysh: mysh.c
	$(CC) $(CFLAGS) -o mysh mysh.c

# .PHONY means this command does not actually produce an output file
.PHONY: clean mem memtext

clean:
	rm -rf mysh

mem:
	valgrind --leak-check=full \
		 --show-leak-kinds=all \
		 --track-origins=yes \
		 --verbose \
		 --log-file=valgrind-out.txt \
		 ./mysh 

memtext:
	valgrind --leak-check=full \
		 --show-leak-kinds=all \
		 --track-origins=yes \
		 --verbose \
		 --log-file=valgrind-out.txt \
		 ./mysh 19.in

san:
	$(CC) $(CFLAGS) $(SANFLAG) -o mysh mysh.c
	rm -rf mysh
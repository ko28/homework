#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
  if(argc != 3){
    printf(2, "usage: syscalls N g\n");
    exit();
  }
  if(!(atoi(argv[1]) >= 1 && atoi(argv[2]) >= 1)) {
	  exit();
  }
  int pid = getpid();
  printf(2, "%d %d\n", getnumsyscalls(pid), getnumsyscallsgood(pid));
  exit();
}

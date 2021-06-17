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
  int goodcalls = 1; // assume getpid() is good  
  int n = atoi(argv[1]);
  int g = atoi(argv[2]);
  
  for(int i = goodcalls; i < g; i++) {
	  if(i%2 == 0){
		  getpid();
	  }
	  else{
		  uptime();
	  }
  }
  for(int i = 0; i < n-g; i++){
	  kill(-1);
  }

  printf(2, "%d %d\n", getnumsyscalls(pid), getnumsyscallsgood(pid));
  exit();
}

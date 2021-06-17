#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
  if(argc != 2){
    printf(2, "usage: syscalls sleepT\n");
    exit();
  }
  
  int sleepT = atoi(argv[1]);
  
  if(sleepT <= 0){
    printf(2, "sleepT needs to be positive\n");
    exit();   
  }

  sleep(sleepT);
  
  int i = 0, j = 0;
  while (i < 80000000) {
    j += i * j + 1;
    i++;
  }
  
//printf(1, "%d\n", sleepT);
  exit();
}

// loop 96953 

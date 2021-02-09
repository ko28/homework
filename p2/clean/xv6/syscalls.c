#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
  if(argc < 2){
    printf(2, "usage: syscalls pid...\n");
    exit();
  }
  // printf(2, "ur num: %s\n", argv[1]);
  // printf("pid number is %d\n", getpid());
  printf(2, "daniel's number is %d\n", daniel(atoi(argv[1])));

  exit();
}

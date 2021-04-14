#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
  printf(2, "Welcome to Todd: %d %d\n", getpgtable(0, 0, 0), dump_rawphymem(0, 0));
  exit();
}
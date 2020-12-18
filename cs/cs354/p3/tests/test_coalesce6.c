// check for coalesce free space (last chunk)
#include <assert.h>
#include <stdlib.h>
#include "myHeap.h"

#define HEADER (4)
#define SLACK (8)

int main() {
   assert(myInit(4096) == 0);
   void * ptr[4];

   ptr[0] = myAlloc(884);
   assert(ptr[0] != NULL);

   ptr[1] = myAlloc(884);
   assert(ptr[1] != NULL);

   ptr[2] = myAlloc(884);
   assert(ptr[2] != NULL);

   ptr[3] = myAlloc(884);
   assert(ptr[3] != NULL);

   assert(myAlloc(884) == NULL);
   
   // last free chunk is at least this big
   int free = (4096 - (884 + HEADER) * 4) - SLACK;

   assert(myFree(ptr[3]) == 0);
   free += (884 + HEADER);
   ptr[3] = myAlloc(free - HEADER - 40);
   assert(ptr[3] != NULL);
   exit(0);
}

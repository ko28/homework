// check for coalesce free space
#include <assert.h>
#include <stdlib.h>
#include "myHeap.h"

int main() {
   assert(myInit(4096) == 0);
   void * ptr[7];

   ptr[0] = myAlloc(500);
   assert(ptr[0] != NULL);

   ptr[1] = myAlloc(500);
   assert(ptr[1] != NULL);

   ptr[2] = myAlloc(500);
   assert(ptr[2] != NULL);

   ptr[3] = myAlloc(500);
   assert(ptr[3] != NULL);

   ptr[4] = myAlloc(500);
   assert(ptr[4] != NULL);

   ptr[5] = myAlloc(500);
   assert(ptr[5] != NULL);

   ptr[6] = myAlloc(500);
   assert(ptr[6] != NULL);

   while (myAlloc(500) != NULL)
     ;

   assert(myFree(ptr[1]) == 0);
   assert(myFree(ptr[5]) == 0);
   assert(myFree(ptr[2]) == 0);
   assert(myFree(ptr[4]) == 0);
   assert(myFree(ptr[3]) == 0);

   ptr[2] = myAlloc(2500);
   assert(ptr[2] != NULL);

   exit(0);
}

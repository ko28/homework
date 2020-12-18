// a simple 8 byte allocation
#include <assert.h>
#include <stdlib.h>
#include "myHeap.h"

int main() {
    assert(myInit(4096) == 0);
    void* ptr = myAlloc(8);
    assert(ptr != NULL);
    exit(0);
}

///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2019-2020 Jim Skrentny
// Posting or sharing this file is prohibited, including any changes/additions.
// Used by permission Fall 2020, CS354-deppeler
//
///////////////////////////////////////////////////////////////////////////////

#ifndef __myHeap_h
#define __myHeap_h

int   myInit(int sizeOfRegion);
void* myAlloc(int size);
int   myFree(void *ptr);
void  dispMem();

void* malloc(size_t size) {
    return NULL;
}

#endif // __myHeap_h__

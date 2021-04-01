#include "types.h"
#include "ptentry.h"

int mencrypt(char* virtual_addr, int len);
int getpgtable(struct pt_entry* entries, int num);
int dump_rawphymem(uint physical_addr, char* buffer);
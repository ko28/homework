#include "types.h"
#include "defs.h"
#include "vm.h"

int
sys_mencrypt(void)
{
	char* virtual_addr;
	int len;

  	if(argptr(0, (void *)&virtual_addr, sizeof(*virtual_addr)) < 0 || argint(1, &len) < 0){
    	return -1;
  	}

	return mencrypt(virtual_addr, len);
}

int 
sys_getpgtable(void)
{
	struct pt_entry* entries;
	int num;
	
	if(argptr(0, (void *)&entries, sizeof(*entries)) < 0 || argint(1, &num) < 0){
    	return -1;
  	}

	return getpgtable(entries, num);
}

int sys_dump_rawphymem(void)
{
	uint physical_addr;
	char* buffer;

	if(argint(0, (int *)&physical_addr) < 0 || argptr(1, (void *)&buffer, sizeof(*buffer)) < 0){
    	return -1;
  	}

	return dump_rawphymem(physical_addr, buffer);
}
#include "types.h"
#include "stat.h"
#include "user.h"
#include "ptentry.h"
#include "mmu.h"
#define KERNBASE 0x80000000         // First kernel virtual address

void print_table(struct pt_entry* pt_entry){
	printf(
		1, "pdx: %d, ptx: %d, ppage: %d, present: %d, writable: %d, encrypted: %d\n", 
		pt_entry->pdx, 
		pt_entry->ptx,
		pt_entry->ppage, 
		pt_entry->present,
		pt_entry->writable,
		pt_entry->encrypted
	); 
	
}
int main(int argc, char **argv) {
	/*
	char *ptr = sbrk(PGSIZE); // Allocate one page
	sbrk(PGSIZE);
	sbrk(PGSIZE);
	sbrk(PGSIZE);
	mencrypt(ptr, 1); // Encrypt the pages
	struct pt_entry pt_entry; 
	getpgtable(&pt_entry, 10); // Get the page table information for newly allocated page
	print_table(&pt_entry);
	int w = mencrypt((char *)KERNBASE, 0);
	printf(1, "%d\n",w, 0);
	*/
    const uint PAGES_NUM = 5;

    // Allocate one pages of space
    char *ptr = sbrk(PGSIZE * sizeof(char));
    while ((uint)ptr != 0x6000)
        ptr = sbrk(PGSIZE * sizeof(char));

    ptr = sbrk(PAGES_NUM * PGSIZE);
    int ppid = getpid();
	
    if (fork() == 0) {
        // Should page fault as normally here
        ptr[PAGES_NUM * PGSIZE] = 0xAA;

        printf(1, "XV6_TEST_OUTPUT Seg fault failed to trigger\n");
        // Shouldn't reach here
        kill(ppid);
        exit();
    } else {
        wait();
    }

    printf(1, "XV6_TEST_OUTPUT TEST PASS\n");
	exit();
}
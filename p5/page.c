#include "types.h"
#include "stat.h"
#include "user.h"
#include "ptentry.h"
#include "mmu.h"

int main(int argc, char **argv) {
	char *ptr = sbrk(PGSIZE); // Allocate one page
	 // Encrypt the pages
	//struct pt_entry pt_entry; 
	//getpgtable(&pt_entry, 1); // Get the page table information for newly allocated page
	printf(1, "%d", mencrypt(ptr, 1));
}
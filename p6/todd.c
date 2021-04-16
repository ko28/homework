#include "types.h"
#include "stat.h"
#include "user.h"
#include "ptentry.h"

void print_table(struct pt_entry* pt_entry){
	printf(
		1, "pdx: %d, ptx: %d, ppage: %d, present: %d, writable: %d, encrypted: %d, user: %d, ref: %d\n", 
		pt_entry->pdx, 
		pt_entry->ptx,
		pt_entry->ppage, 
		pt_entry->present,
		pt_entry->writable,
		pt_entry->encrypted,
		pt_entry->user,
		pt_entry->ref
	); 
	
}

int
main(int argc, char **argv)
{
  printf(2, "Welcome to Todd: %d\n", dump_rawphymem(0, 0));
  struct pt_entry p;
  getpgtable(&p, 1 ,0);
  print_table(&p);
  exit();
}
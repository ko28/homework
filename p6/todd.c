/*
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
*/

#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "ptentry.h"

#define PGSIZE 4096

static int
err(char *msg, ...) {
    printf(1, "XV6_TEST_OUTPUT %s\n", msg);
    exit();
}

int main(void) {
    const uint PAGES_NUM = 1;
    char *buffer = sbrk(PGSIZE * sizeof(char));
    while ((uint)buffer != 0x6000)
        buffer = sbrk(PGSIZE * sizeof(char));

    // Allocate one pages of space
    sbrk(PAGES_NUM * PGSIZE);
    struct pt_entry pt_entries[PAGES_NUM];

    int retval = getpgtable(pt_entries, PAGES_NUM, 0);
    if (retval == PAGES_NUM) {
        for (int i = 0; i < retval; i++) {
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n",
                i,
                pt_entries[i].pdx,
                pt_entries[i].ptx,
                pt_entries[i].writable,
                pt_entries[i].encrypted,
                pt_entries[i].ref
            );

            if (dump_rawphymem(pt_entries[i].ppage * PGSIZE, buffer) != 0)
                err("dump_rawphymem return non-zero value\n");

            for (int j = 0; j < PGSIZE; j++) {
                if (buffer[j] != (char)0xFF) {
                    printf(1, "XV6_TEST_OUTPUT: content is incorrect at address 0x%x: expected 0x%x, got 0x%x\n", ((uint)(pt_entries[i].pdx) << 22 | (pt_entries[i].ptx) << 12) + j , 0xFF, buffer[j] & 0xFF);
                    exit();
                }

            }
        }
    } else
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", PAGES_NUM, retval);

    exit();
}
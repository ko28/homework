#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "mmu.h"
#include "param.h"


static void
mencrypt(int vpn, pte_t *pte)
{
    if (*pte & PTE_E)
        return;
    *pte |= PTE_E;
    *pte &= (~PTE_P);
    // Flip the bits...
}

static void
mdecrypt(int vpn, pte_t *pte)
{
    if (!(*pte & PTE_E))
        return;
    *pte &= (~PTE_E);
    *pte |= PTE_P;
    // Flip the bits...
}


typedef struct node {
    int vpn;
    pte_t *pte;
} node;

int clock_hand = -1;

node clock_queue[CLOCKSIZE];

void init_clock(){
	for(int i = 0; i < CLOCKSIZE; i++){
		clock_queue[i].vpn = -1;
	}
	clock_hand = -1;
}

void insert_clock(int vpn, pte_t *pte){
	while(1){
		// next index for clock 
		clock_hand = (clock_hand + 1) % CLOCKSIZE;
		node curr = clock_queue[clock_hand];

		// Case 1: Found empty spot in queue
		if(curr.vpn == -1){
			curr.vpn = vpn;
			curr.pte = pte;
			break;
		}
		// Case 2: Access bit is clear => Evict this page from queue, encrypt, and add new page  
		else if((*curr.pte & PTE_A) == 0){
			mencrypt(curr.vpn, curr.pte);
			curr.vpn = vpn;
			curr.pte = pte;
			break;
		}
		// Case 3: Access bit is set => Clear access bit and give this page a "second chance"
		else{
			*curr.pte &= ~PTE_A;
		}
	}

	mencrypt(vpn, pte);
} 


void remove_clock(int vpn){
	int match = -1;
	for(int i = 0; i < CLOCKSIZE; i++){
		if(clock_queue[i].vpn == vpn){
			match = i;
		}
	}

	if(match == -1)
		return;

	
} 

int
main(void) {
	printf(1, "clock!\n");
	init_clock();



	exit();
}
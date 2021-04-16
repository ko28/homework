#include "types.h"
#include "fs.h"
#include "mmu.h"
#include "param.h"
#include "clock.h"
#include "defs.h"

void init_clock(struct clock *c){
	for(int i = 0; i < CLOCKSIZE; i++){
		c->clock_queue[i].pte = (pte_t *)-1;
	}
	c->clock_hand = -1;
}

void insert_clock(struct clock *c, pte_t *pte){
	while(1){
		// next index for clock 
		c->clock_hand = (c->clock_hand + 1) % CLOCKSIZE;
		
		node *curr = &c->clock_queue[c->clock_hand];
		// curr <=> c->clock_queue[c->clock_hand]
		
		// Case 1: Found empty spot in queue
		if(curr->pte == (pte_t *)-1){
			curr->pte = pte;
			break;
		}

		// Case 2: Access bit is clear => Evict this page from queue, encrypt, and add new page  
		else if((*curr->pte & PTE_A) == 0){
			// TODO: aDD THIS 
			mencrypt_pte(curr->pte);
			curr->pte = pte;
			break;
		}
		
		// Case 3: Access bit is set => Clear access bit and give this page a "second chance"
		else{
			*curr->pte &= ~PTE_A;
		}
	}
} 

void
remove_clock(struct clock *c, pte_t *pte)
{
    int prev_tail = c->clock_hand;
    int match_idx = -1;

    // Search for the matching element.
    for (int i = 0; i < CLOCKSIZE; ++i) {
        int idx = (c->clock_hand + i) % CLOCKSIZE;
        if (c->clock_queue[idx].pte == pte) {
            match_idx = idx;
            break;
        }
    }

    if (match_idx == -1)
        return;

    // Shift everything from match_idx+1 to prev_tail to
    // one slot to the left.
    for (int idx = match_idx;
         idx != prev_tail;
         idx = (idx + 1) % CLOCKSIZE) {
        int next_idx = (idx + 1) % CLOCKSIZE;
        // c->clock_queue[idx].vpn = c->clock_queue[next_idx].vpn;
        c->clock_queue[idx].pte = c->clock_queue[next_idx].pte;
    }

    // Clear the element at prev_tail. Set clk_hand to
    // one entry to the left.
    c->clock_queue[prev_tail].pte = (pte_t *) -1;
    c->clock_hand = c->clock_hand == 0 ? CLOCKSIZE - 1
                             :  c->clock_hand - 1;
}

void print_clock(struct clock *c){
	cprintf("clock print!\n");
	for(int i = 0; i < CLOCKSIZE; i++){
		cprintf("i: %d\tpte: %p\n", i, c->clock_queue[i].pte);
	}
}
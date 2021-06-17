typedef struct node {
    //int vpn;
    pte_t *pte;
} node;

struct clock {
	node clock_queue[CLOCKSIZE];
	int clock_hand;
} clock;
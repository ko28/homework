#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h"
#include "ptentry.h"

extern char data[];  // defined by kernel.ld
pde_t *kpgdir;  // for use in scheduler()

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
  struct cpu *c;

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
  lgdt(c->gdt, sizeof(c->gdt));
}

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & (PTE_P | PTE_E))
      panic("remap");
    
    //"perm" is just the lower 12 bits of the PTE
    //if encrypted, then ensure that PTE_P is not set
    //This is somewhat redundant. If our code is correct,
    //we should just be able to say pa | perm
    if (perm & PTE_E)
      *pte = (pa | perm | PTE_E) & ~PTE_P;
    else
      *pte = pa | perm | PTE_P;


    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}


// There is one page table per process, plus one that's used when
// a CPU is not running any process (kpgdir). The kernel uses the
// current process's page table during system calls and interrupts;
// page protection bits prevent user code from using the kernel's
// mappings.
//
// setupkvm() and exec() set up every page table like this:
//
//   0..KERNBASE: user memory (text+data+stack+heap), mapped to
//                phys memory allocated by the kernel
//   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
//   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
//                for the kernel's instructions and r/o data
//   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP,
//                                  rw data + free physical memory
//   0xfe000000..0: mapped direct (devices such as ioapic)
//
// The kernel allocates physical memory for its heap and for user memory
// between V2P(end) and the end of physical memory (PHYSTOP)
// (directly addressable from end..P2V(PHYSTOP)).

// This table defines the kernel's mappings, which are present in
// every process's page table.
static struct kmap {
  void *virt;
  uint phys_start;
  uint phys_end;
  int perm;
} kmap[] = {
 { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // I/O space
 { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // kern text+rodata
 { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
 { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
}

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  kpgdir = setupkvm();
  switchkvm();
}

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");

  pushcli();
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
  mycpu()->ts.ss0 = SEG_KDATA << 3;
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
  popcli();
}

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
}

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
}

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
	  remove_clock(&myproc()->c, pte);
      *pte = 0;
    }
  }
  return newsz;
}

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
}

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
  *pte &= ~PTE_U;
}

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & (PTE_P | PTE_E)))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
      kfree(mem);
      goto bad;
    }
  }
  return d;

bad:
  freevm(d);
  return 0;
}

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  //TODO: uva2ka says not present if PTE_P is 0
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}

/*
int getpgtable_all(struct pt_entry* entries, int num){
	if(entries == (struct pt_entry*) 0)
		return -1;
	struct proc *p = myproc();	
	int i;
	for(i = 0; i < num; i++){
		char *va = (char*) PGROUNDDOWN((uint) p->sz - i*PGSIZE - 1);
		pte_t *pte = walkpgdir(p->pgdir, va, 0);
		entries->pdx = PDX(va);
		entries->ptx = PTX(va);
		entries->ppage = PTE_ADDR(*pte) >> 12;
		entries->present = (*pte & PTE_P) ? 1 : 0;
		entries->writable = (*pte & PTE_W) ? 1 : 0;
		entries->encrypted = (*pte & PTE_E) ? 1 : 0;
		entries->user = (*pte & PTE_U) ? 1 : 0;
		entries->ref = (*pte & PTE_A) ? 1 : 0;
		entries++;
	}

	return i;
}
*/


int getpgtable_all(struct pt_entry* entries, int num) {
  struct proc * me = myproc();

  int index = 0;
  pte_t * curr_pte;
  //reverse order

  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags
    curr_pte = walkpgdir(me->pgdir, i, 0);


    //currPage is 0 if page is not allocated
    //see deallocuvm
    if (curr_pte && *curr_pte) {//this page is allocated
      //this is the same for all pt_entries... right?
      entries[index].pdx = PDX(i); 
      entries[index].ptx = PTX(i);
      //convert to physical addr then shift to get PPN 
      entries[index].ppage = PTE_ADDR(*curr_pte) >> 12;
      //have to set it like this because these are 1 bit wide fields
      entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
      entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
      entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
	  entries[index].user = (*curr_pte & PTE_U) ? 1 : 0;
	  entries[index].ref = (*curr_pte & PTE_A) ? 1 : 0;
      index++;
    }
  }
  //index is the number of ptes copied
  return index;
}

int getpgtable(struct pt_entry* entries, int num, int wsetOnly){
	if(wsetOnly == 0)
		return getpgtable_all(entries, num);
	
	// TODO: add wsetOnly == 1 implementation 
	struct proc *p = myproc();	
	int n = 0;
	for(int i = 0; (i < num) && (i < CLOCKSIZE); i++){
		pte_t *pte = p->c.clock_queue[i].pte;
		if(pte != (pte_t *)-1){
			char* va = (char *)P2V(PTE_ADDR(*pte));
			entries->pdx = PDX(va);
			entries->ptx = PTX(va);
			entries->ppage = PTE_ADDR(*pte) >> 12;
			entries->present = (*pte & PTE_P) ? 1 : 0;
			entries->writable = (*pte & PTE_W) ? 1 : 0;
			entries->encrypted = (*pte & PTE_E) ? 1 : 0;
			entries->user = (*pte & PTE_U) ? 1 : 0;
			entries->ref = (*pte & PTE_A) ? 1 : 0;
			entries++;
			n++;
		}
	}
	return n;
}


/*
int inClockQueue(pte_t * pte){
  struct proc *p = myproc();
  for(int i = 0; i < CLOCKSIZE; i++){
    if(*(p->c.clock_queue[i].pte) == *pte){
      return 1;
    }
  }
  return 0;
}

int getpgtable(struct pt_entry* entries, int num, int wsetOnly) {
  struct proc * me = myproc();

  int index = 0;
  pte_t * curr_pte;
  //reverse order

  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags
    curr_pte = walkpgdir(me->pgdir, i, 0);


    //currPage is 0 if page is not allocated
    //see deallocuvm

    if (curr_pte && *curr_pte) {//this page is allocated
	  if(wsetOnly == 1 && !inClockQueue(curr_pte)) 
	    continue;
        
      	

      //this is the same for all pt_entries... right?
      entries[index].pdx = PDX(i); 
      entries[index].ptx = PTX(i);
      //convert to physical addr then shift to get PPN 
      entries[index].ppage = PTE_ADDR(*curr_pte) >> 12;
      //have to set it like this because these are 1 bit wide fields
      entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
      entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
      entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
	  entries[index].user = (*curr_pte & PTE_U) ? 1 : 0;
	  entries[index].ref = (*curr_pte & PTE_A) ? 1 : 0;
      index++;
    }
  }
  //index is the number of ptes copied
  return index;
}
*/


// TODO: The buffer might be encrypted, in which case you should decrypt that page
int dump_rawphymem(uint physical_addr, char* buffer){
	/*
	struct proc *p = myproc();
	pte_t *pte = walkpgdir(p->pgdir, P2V(physical_addr), 0);
	cprintf("p: %s\n", p->name);
	int o = copyout(p->pgdir, (uint) buffer, (char *)PGROUNDDOWN((uint)P2V(physical_addr)), PGSIZE);
	// is encrypted, so fliparoo
	cprintf("pte_p %d\tpte_w %d\tpte_e %d\tpte_u %d\tpte_a %d\n",  
			(*pte & PTE_P), 
			(*pte & PTE_W), 
			(*pte & PTE_E), 
			(*pte & PTE_U), 
			(*pte & PTE_A));
			
	if (*pte & PTE_E){
		for (int offset = 0; offset < PGSIZE; offset++) {
			*buffer = ~*buffer;
			buffer++;
		}
	}
	return o;
	*/
	//struct proc *p = myproc();
	//pte_t *pte = walkpgdir(p->pgdir, P2V(physical_addr), 0);
	*buffer = *buffer;
	/*
	// is encrypted, so fliparoo
	cprintf("pte_p %d\tpte_w %d\tpte_e %d\tpte_u %d\tpte_a %d\n",  
			(*pte & PTE_P), 
			(*pte & PTE_W), 
			(*pte & PTE_E), 
			(*pte & PTE_U), 
			(*pte & PTE_A));
	*/
	int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) P2V(physical_addr), PGSIZE);

	if (retval)
		return -1;
	return 0;
}

int mencrypt(char *virtual_addr, int len) {
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
  pde_t* mypd = p->pgdir;

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);

  //error checking first. all or nothing.
  char * slider = virtual_addr;
  for (int i = 0; i < len; i++) { 
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
    if (!kvp) {
      cprintf("mencrypt: Could not access address\n");
      return -1;
    }
    slider = slider + PGSIZE;
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
  for (int i = 0; i < len; i++) { 
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
    if (*mypte & PTE_E) {//already encrypted
      slider += PGSIZE;
      continue;
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
      *slider = ~*slider;
      slider++;
    }
    *mypte = *mypte & ~PTE_P;
    *mypte = *mypte | PTE_E;
	*mypte &= ~PTE_A; // for some reason..
  }

  switchuvm(myproc());
  return 0;
}

int mencrypt_all(char *virtual_addr, int len) {
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
  pde_t* mypd = p->pgdir;

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);

  //error checking first. all or nothing.
  char * slider = virtual_addr;

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
  for (int i = 0; i < len; i++) { 
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
    if (*mypte & PTE_E ||!(*mypte & PTE_U)) {//already encrypted
      slider += PGSIZE;
      continue;
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
      *slider = ~*slider;
      slider++;
    }
	cprintf("mencrypt_all %d\n", i);
    *mypte = *mypte & ~PTE_P;
    *mypte = *mypte | PTE_E;
  }

  switchuvm(myproc());
  return 0;
}

// decrypt 1 page 
int mdecrypt(char* virtual_addr){
	struct proc *p = myproc();	
	char *base_virtual_addr = (char*) PGROUNDDOWN((uint) virtual_addr);
	pte_t *pte = walkpgdir(p->pgdir, base_virtual_addr, 0);
	// is encrypted page 
	if(*pte & PTE_E){
		char *lower_physical = uva2ka(p->pgdir, base_virtual_addr);
		// decrypt 
		for(int p = 0; p < PGSIZE; p++){
			*(lower_physical + p) = ~ *(lower_physical + p);
		}
		*pte |= PTE_P;	// page is present 
		*pte &= ~PTE_E; // not encrypted 
		switchuvm(p);	// Flush tlb
		return 1; // decrypt succeeded  
	}
	
	return 0; // decrypt failed 
}

int access_page(char* virtual_addr){
	struct proc *p = myproc();	
	char *base_virtual_addr = (char*) PGROUNDDOWN((uint) virtual_addr);
	pte_t *pte = walkpgdir(p->pgdir, base_virtual_addr, 0);
	// if the page has PTE_P set, then nothing happens, no faults; the page must be in queue and in clear text
	//cprintf("(*pte & PTE_P) = %d\n", (*pte & PTE_P));
	if(*pte & PTE_P){
		return 1; 
	}
	// this is an encrypted page and needs to be inserted into the clock queue, possibly evicting another page
	else{
		insert_clock(&p->c, pte);
		//cprintf("data: %p\n", pte);
		//print_clock(&p->c);
		return mdecrypt(virtual_addr);

	}
}

void mencrypt_pte(pte_t* mypte) {
  char* slider = (char *)P2V(PTE_ADDR(*mypte));

  for (int offset = 0; offset < PGSIZE; offset++) {
      *slider = ~*slider;
      slider++;
  }

  *mypte = *mypte & ~PTE_P;
  *mypte = *mypte | PTE_E;
  // *mypte &= ~PTE_A; // for some reason..
  switchuvm(myproc());

}

void remove_from_clock(char* virtual_addr, int n){
	struct proc *p = myproc();	
	char *base_virtual_addr = (char*) PGROUNDDOWN((uint) virtual_addr + n);
	
	while(base_virtual_addr < virtual_addr){
		pte_t *pte = walkpgdir(p->pgdir, base_virtual_addr, 0);
		remove_clock(&p->c, pte);
		base_virtual_addr = (char*) PGROUNDDOWN((uint) base_virtual_addr + PGSIZE);
	}
}

void clock_fork_copy(struct proc* parent, struct proc* child){
  for(int i = 0; i < CLOCKSIZE; i++){
	if(parent->c.clock_queue[i].pte ==  (pte_t *) -1)
	  continue;
	char* addr = (char *)P2V(PTE_ADDR(*(parent->c.clock_queue[i].pte)));
	pte_t *pte = walkpgdir(child->pgdir, addr, 0);
	cprintf("parent %p, child %p\n", parent, child);
	child->c.clock_queue[i].pte = pte;
  }
  child->c.clock_hand = parent->c.clock_hand;
}
///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2019-2020 Jim Skrentny
// Posting or sharing this file is prohibited, including any changes/additions.
// Used by permission Fall 2020, CS354-deppeler
//
///////////////////////////////////////////////////////////////////////////////
// Main File:        myHeap.c
// This File:        myHeap.c
// Other Files:
// Semester:         CS 354 Fall 2020
//
// Author:           Daniel Ko
// Email:            ko28@wisc.edu
// CS Login:         ko
//
/////////////////////////// OTHER SOURCES OF HELP //////////////////////////////
//                   Fully acknowledge and credit all sources of help,
//                   other than Instructors and TAs.
//
// Persons:          Identify persons by name, relationship to you, and email.
//                   Describe in detail the the ideas and help they provided.
//
// Online sources:   Avoid web searches to solve your problems, but if you do
//                   search, be sure to include Web URLs and description of
//                   of any information you find.
////////////////////////////////////////////////////////////////////////////////

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdio.h>
#include <string.h>
#include "myHeap.h"

/*
 * This structure serves as the header for each allocated and free block.
 * It also serves as the footer for each free block but only containing size.
 */
typedef struct blockHeader
{
	int size_status;
	/*
    * Size of the block is always a multiple of 8.
    * Size is stored in all block headers and free block footers.
    *
    * Status is stored only in headers using the two least significant bits.
    *   Bit0 => least significant bit, last bit
    *   Bit0 == 0 => free block
    *   Bit0 == 1 => allocated block
    *
    *   Bit1 => second last bit 
    *   Bit1 == 0 => previous block is free
    *   Bit1 == 1 => previous block is allocated
    * 
    * End Mark: 
    *  The end of the available memory is indicated using a size_status of 1.
    * 
    * Examples:
    * 
    * 1. Allocated block of size 24 bytes:
    *    Header:
    *      If the previous block is allocated, size_status should be 27
    *      If the previous block is free, size_status should be 25
    * 
    * 2. Free block of size 24 bytes:
    *    Header:
    *      If the previous block is allocated, size_status should be 26
    *      If the previous block is free, size_status should be 24
    *    Footer:
    *      size_status should be 24
    */
} blockHeader;

/* Global variable - DO NOT CHANGE. It should always point to the first block,
 * i.e., the block at the lowest address.
 */
blockHeader *heapStart = NULL;

/* Size of heap allocation padded to round to nearest page size.
 */
int allocsize;

/* Location of the block recently allocated. 
 */
blockHeader *recent;

/* 
 * Function for allocating 'size' bytes of heap memory.
 * Argument size: requested size for the payload
 * Returns address of allocated block on success.
 * Returns NULL on failure.
 * This function should:
 * - Check size - Return NULL if not positive or if larger than heap space.
 * - Determine block size rounding up to a multiple of 8 and possibly adding padding as a result.
 * - Use NEXT-FIT PLACEMENT POLICY to chose a free block
 * - Use SPLITTING to divide the chosen free block into two if it is too large.
 * - Update header(s) and footer as needed.
 * Tips: Be careful with pointer arithmetic and scale factors.
 */
void *myAlloc(int size)
{
	// Check size
	if (size <= 0 || size > allocsize)
	{
		return NULL;
	}

	// 4 needed for the header
	int header_size = sizeof(blockHeader);

	// Block size we need to allocate, closest multiple of 8 (rounded up), includes header + padding + size
	int block_size = (((size + header_size) + 7) & (-8));

	// Loop through heap to find next free block
	blockHeader *curr = recent;

	do
	{
		// Length of current block (to be computed below), contains header size + available size
		int curr_size = curr->size_status;

		// check if prev block is used and remove the p-bit for real size
		int prev = 0;
		if (curr_size & 2)
		{
			curr_size = curr_size - 2;
			prev = 1;
		}

		// curr block is free and we can allocate
		if ((curr->size_status & 1) == 0 && (curr_size >= block_size))
		{

			int split_size = curr_size - block_size;
			// need to split
			if (split_size != 0)
			{
				curr->size_status = block_size;
				// re add p bit if needed
				if (prev)
				{
					curr->size_status += 2;
				}

				blockHeader *next_block = (blockHeader *)((char *)curr + block_size);
				// mark curr being used
				next_block->size_status = split_size + 2;
				// update footer
				int *next_block_footer = (int *)((char *)next_block + split_size - header_size);
				*next_block_footer = split_size;
			}

			// Mark this block as used
			curr->size_status++;
			// Update recently allocated block
			recent = curr;
			return (blockHeader *)((char *)curr + header_size);
		}
		// curr block is used, remove bit
		else
		{
			curr_size--;
		}

		// Go to next block
		curr = (blockHeader *)((char *)curr + curr_size);
		// Loop back to front if at end
		if ((char *)curr >= ((char *)heapStart + allocsize))
		{
			curr = heapStart;
		}
	} while (curr != recent);

	// Wasn't able to find a open block to allocate memory
	return NULL;
}

/* 
 * Function for freeing up a previously allocated block.
 * Argument ptr: address of the block to be freed up.
 * Returns 0 on success.
 * Returns -1 on failure.
 * This function should:
 * - Return -1 if ptr is NULL.
 * - Return -1 if ptr is not a multiple of 8.
 * - Return -1 if ptr is outside of the heap space.
 * - Return -1 if ptr block is already freed.
 * - USE IMMEDIATE COALESCING if one or both of the adjacent neighbors are free.
 * - Update header(s) and footer as needed.
 */
int myFree(void *ptr)
{	
	// ptr is null
	if (ptr == NULL)
	{
		return -1;
	}

	// ptr is not a multiple of 8
	if (((int)ptr) % 8 != 0)
	{
		return -1;
	}

	// ptr is outside of the heap space.
	if (((char *)ptr < ((char *)heapStart)) || ((char *)ptr >= ((char *)heapStart + allocsize)))
	{
		return -1;
	}

	int header_size = sizeof(blockHeader);
	// block to be freed
	blockHeader *block = (blockHeader *)((char *)ptr - header_size);
	int block_size;

	// ptr block is already freed
	if ((block->size_status & 1) == 0)
	{
		return -1;
	}
	// We can free block
	else
	{
		// Mark block as freed
		block->size_status--;

		block_size = block->size_status;
		if (block_size & 2)
		{
			block_size = block_size - 2;
		}
		
		// Update header of next block
		blockHeader *next_block = (blockHeader *)((char *)block + block_size);

		// This means next block knows that prev block is free
		if ((next_block->size_status & 2) != 0)
		{
			next_block->size_status -= 2;
		}
		*((int *)((char *)next_block - header_size)) = block_size;
	}

	// Below code is for IMMEDIATE COALESCING

	blockHeader *prev = NULL;
	// prev block is free, coalesce
	if ((block->size_status & 2) == 0)
	{
		int prev_size = *((int *)((char *)block - header_size));

		prev = (blockHeader *)((char *)block - prev_size);

		prev->size_status += block_size;

		// Update footer
		prev_size = prev->size_status;
		if ((prev_size & 2) != 0)
		{
			prev_size -= 2;
		}
		*((int *)((char *)prev + prev_size - header_size)) = prev_size;

		// Updating recent
		if (block == recent)
		{
			recent = prev;
		}
	}

	blockHeader *next = (blockHeader *)((char *)block + block_size);

	// next block is free, coalesce
	if (((char *)next < ((char *)heapStart + allocsize)) && ((next->size_status & 1) == 0))
	{

		int next_size = next->size_status;
		// remove p bit
		if (next_size & 2)
		{
			next_size = next_size - 2;
		}

		//  need to coalesce next block with prev block (with current in the middle) 
		if (prev != NULL)
		{
			prev->size_status += next_size;
			//next footer update
			int prev_size = prev->size_status;
			if (prev->size_status & 2)
			{
				prev_size -= 2;
			}
			*((int *)((char *)prev + prev_size - header_size)) = prev_size;
		}
		
		// only need to coalesce next block and current block 
		else
		{
			block->size_status += next_size;

			//next footer update
			int block_size = block->size_status;
			if (block_size & 2)
			{
				block_size -= 2;
			}
			*((int *)((char *)block + block_size - header_size)) = block_size;
		}
	}

	return 0;
}

/*
 * Function used to initialize the memory allocator.
 * Intended to be called ONLY once by a program.
 * Argument sizeOfRegion: the size of the heap space to be allocated.
 * Returns 0 on success.
 * Returns -1 on failure.
 */
int myInit(int sizeOfRegion)
{

	static int allocated_once = 0; //prevent multiple myInit calls

	int pagesize;	// page size
	int padsize;	// size of padding when heap size not a multiple of page size
	void *mmap_ptr; // pointer to memory mapped area
	int fd;

	blockHeader *endMark;

	if (0 != allocated_once)
	{
		fprintf(stderr,
				"Error:mem.c: InitHeap has allocated space during a previous call\n");
		return -1;
	}
	if (sizeOfRegion <= 0)
	{
		fprintf(stderr, "Error:mem.c: Requested block size is not positive\n");
		return -1;
	}

	// Get the pagesize
	pagesize = getpagesize();

	// Calculate padsize as the padding required to round up sizeOfRegion
	// to a multiple of pagesize
	padsize = sizeOfRegion % pagesize;
	padsize = (pagesize - padsize) % pagesize;

	allocsize = sizeOfRegion + padsize;

	// Using mmap to allocate memory
	fd = open("/dev/zero", O_RDWR);
	if (-1 == fd)
	{
		fprintf(stderr, "Error:mem.c: Cannot open /dev/zero\n");
		return -1;
	}
	mmap_ptr = mmap(NULL, allocsize, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (MAP_FAILED == mmap_ptr)
	{
		fprintf(stderr, "Error:mem.c: mmap cannot allocate space\n");
		allocated_once = 0;
		return -1;
	}

	allocated_once = 1;

	// for double word alignment and end mark
	allocsize -= 8;

	// Initially there is only one big free block in the heap.
	// Skip first 4 bytes for double word alignment requirement.
	heapStart = (blockHeader *)mmap_ptr + 1;

	// Set the end mark
	endMark = (blockHeader *)((void *)heapStart + allocsize);
	endMark->size_status = 1;

	// Set size in header
	heapStart->size_status = allocsize;

	// Set p-bit as allocated in header
	// note a-bit left at 0 for free
	heapStart->size_status += 2;

	// Set the footer
	blockHeader *footer = (blockHeader *)((void *)heapStart + allocsize - 4);
	footer->size_status = allocsize;

	// Set recent pointer
	recent = heapStart;

	return 0;
}

/* 
 * Function to be used for DEBUGGING to help you visualize your heap structure.
 * Prints out a list of all the blocks including this information:
 * No.      : serial number of the block 
 * Status   : free/used (allocated)
 * Prev     : status of previous block free/used (allocated)
 * t_Begin  : address of the first byte in the block (where the header starts) 
 * t_End    : address of the last byte in the block 
 * t_Size   : size of the block as stored in the block header
 */
void dispMem()
{

	int counter;
	char status[5];
	char p_status[5];
	char *t_begin = NULL;
	char *t_end = NULL;
	int t_size;

	blockHeader *current = heapStart;
	counter = 1;

	int used_size = 0;
	int free_size = 0;
	int is_used = -1;

	fprintf(stdout, "************************************Block list***\
                    ********************************\n");
	fprintf(stdout, "No.\tStatus\tPrev\tt_Begin\t\tt_End\t\tt_Size\n");
	fprintf(stdout, "-------------------------------------------------\
                    --------------------------------\n");

	while (current->size_status != 1)
	{
		t_begin = (char *)current;
		t_size = current->size_status;

		if (t_size & 1)
		{
			// LSB = 1 => used block
			strcpy(status, "used");
			is_used = 1;
			t_size = t_size - 1;
		}
		else
		{
			strcpy(status, "Free");
			is_used = 0;
		}
		if (t_size & 2)
		{
			strcpy(p_status, "used");
			t_size = t_size - 2;
		}
		else
		{
			strcpy(p_status, "Free");
		}

		if (is_used)
			used_size += t_size;
		else
			free_size += t_size;

		t_end = t_begin + t_size - 1;

		fprintf(stdout, "%d\t%s\t%s\t0x%08lx\t0x%08lx\t%d\n", counter, status,
				p_status, (unsigned long int)t_begin, (unsigned long int)t_end, t_size);

		current = (blockHeader *)((char *)current + t_size);
		counter = counter + 1;
	}

	fprintf(stdout, "---------------------------------------------------\
                    ------------------------------\n");
	fprintf(stdout, "***************************************************\
                    ******************************\n");
	fprintf(stdout, "Total used size = %d\n", used_size);
	fprintf(stdout, "Total free size = %d\n", free_size);
	fprintf(stdout, "Total size = %d\n", used_size + free_size);
	fprintf(stdout, "***************************************************\
                    ******************************\n");
	fflush(stdout);

	return;
}

// end of myHeap.c (fall 2020)

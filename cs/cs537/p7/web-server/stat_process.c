#include "helper.h"

void getargs(char** shm_name, int* sleeptime_ms, int* num_threads, int argc, char* argv[])
{
	if (argc != 4) {
		fprintf(stderr, "Usage: %s <shm_name> <sleeptime_ms> <num_threads>\n", argv[0]);
		//TODO: [port_num] [threads] [buffers] [shm_name]
		exit(1);
	}
	if (atoi(argv[2]) < 0 || atoi(argv[3]) < 0) {
		fprintf(stderr, "Invalid args, buffer and threads cannot be negative (-1) and port_num (-1, 22)\n");
		//TODO: [port_num] [threads] [buffers] [shm_name]
		exit(1);
	}
	*shm_name = argv[1];
	*sleeptime_ms = atoi(argv[2]);
	*num_threads = atoi(argv[3]);
}

int main(int argc, char* argv[])
{

	char* shm_name;
	int sleeptime_ms, num_threads;
	getargs(&shm_name, &sleeptime_ms, &num_threads, argc, argv);
	int PAGESIZE = getpagesize();

	int shm_fd = shm_open(shm_name, O_RDWR, S_IRUSR); // open shared memory space 
	if(shm_fd == -1)
		return -1;

	slot_t* shm_ptr = (slot_t*) mmap(NULL, PAGESIZE, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0); // map the shared memory object into the address spac
	if(shm_ptr == MAP_FAILED)
		return -1;
	

	int itr = 1;	
	while(1)
	{
		printf("%i\n", itr);
		for(int i = 0; i < num_threads; i++){
			printf("%i : %i %i %i\n", shm_ptr[i].thread_id,  shm_ptr[i].http_req, shm_ptr[i].static_req, shm_ptr[i].dynmaic_req);
		}
		printf("\n");
		itr++;
		nanosleep((const struct timespec[]){{sleeptime_ms / 1000, (sleeptime_ms % 1000) * 1000000L}}, NULL);
	}
}
#include "helper.h"
#include "request.h"

// 
// server.c: A very, very simple web server
//
// To run:
//  server <portnum (above 2000)>
//
// Repeatedly handles HTTP requests sent to this port number.
// Most of the work is done within routines written in request.c
//

slot_t* shm_slot_ptr;
int PAGESIZE;
char *shm_name;

pthread_cond_t buf_not_full = PTHREAD_COND_INITIALIZER;
pthread_cond_t buf_not_empty = PTHREAD_COND_INITIALIZER;
pthread_mutex_t m = PTHREAD_MUTEX_INITIALIZER;
int *buffer;
int buffer_size;
int buffer_amt = 0; // num elements in buffer
int produce_idx = 0; // next index to store connfd
int consume_idx = 0; // next index to get connfd

//connfd int[buffers]; 


static void
handler(int sig) {
    munmap(shm_slot_ptr, PAGESIZE);
    shm_unlink(shm_name);
    printf("bye nerds\n");
    exit(0);
}


// CS537: Parse the new arguments too
void getargs(int *port, int *threads, int *buffer_size, char **shm_name, int argc, char *argv[])
{
  if (argc != 5) {
    fprintf(stderr, "Usage: %s <port> <threads> <buffers> <shm_name>\n", argv[0]);
    //TODO: [port_num] [threads] [buffers] [shm_name]
    exit(1);
  }
  if(atoi(argv[1]) < 0 || atoi(argv[2]) < 0 || atoi(argv[3]) < 0){
    fprintf(stderr, "Invalid args, buffer and threads cannot be negative (-1) and port_num (-1, 22)\n");
    //TODO: [port_num] [threads] [buffers] [shm_name]
    exit(1);
  }
  *port = atoi(argv[1]);
  *threads = atoi(argv[2]);
  *buffer_size = atoi(argv[3]);
  *shm_name = argv[4];
}

static void *consumer(void *arg) {
  // setup slot_t
  int i = *(int *)arg;
  shm_slot_ptr[i].thread_id = pthread_self();
  shm_slot_ptr[i].http_req = 0;
  shm_slot_ptr[i].static_req = 0;
  shm_slot_ptr[i].dynmaic_req = 0;
  free(arg);


  int fd = -1;
  while(1){
    
    pthread_mutex_lock(&m);
    // wait until we can consume connfd    
    while(buffer_amt == 0){
      pthread_cond_wait(&buf_not_empty, &m);
    }
    fd = buffer[consume_idx];
    consume_idx = (consume_idx + 1) % buffer_size;
    buffer_amt--;
    pthread_cond_signal(&buf_not_full);
    pthread_mutex_unlock(&m);

    // serve up the http
    // printf("Hello from worker %lu\n", pthread_self());
    int req = requestHandle(fd);
    shm_slot_ptr[i].http_req++;
    if(req == 1)
      shm_slot_ptr[i].static_req++;
    else if(req == 2)
      shm_slot_ptr[i].dynmaic_req++;    
    Close(fd);

  }

  return NULL;
}


int main(int argc, char *argv[])
{


  int listenfd, connfd, port, clientlen, threads;
  struct sockaddr_in clientaddr;
  getargs(&port, &threads, &buffer_size, &shm_name, argc, argv);
  //
  // CS537 (Part B): Create & initialize the shared memory region...
  //
  PAGESIZE = getpagesize();
  int shm_fd = shm_open(shm_name, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR); // create shared memory space 
	if(shm_fd == -1)
		return 1;
	
	if(ftruncate(shm_fd, PAGESIZE) == -1) // increase mem size to 1 page 
		return 1;

	void *shm_ptr = mmap(NULL, PAGESIZE, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0); // map the shared memory object into the address spac
	if(shm_ptr == MAP_FAILED)
		return 1;
	
  shm_slot_ptr = (slot_t*) shm_ptr;

    	
  // Sig handlers
  signal(SIGINT, handler);

  // 
  // CS537 (Part A): Create some threads...
  //
  buffer = (int *) malloc(sizeof(int) * threads);

  pthread_t workers[threads];
  for (int i = 0; i < threads; i++) {
      int *slot_i = malloc(sizeof(int));
      *slot_i = i;
      pthread_create(&workers[i], NULL, consumer, slot_i);
  }

  listenfd = Open_listenfd(port);
  while (1) {
    clientlen = sizeof(clientaddr);
    connfd = Accept(listenfd, (SA *)&clientaddr, (socklen_t *) &clientlen);

    // 
    // CS537 (Part A): In general, don't handle the request in the main thread.
    // Save the relevant info in a buffer and have one of the worker threads 
    // do the work. Also let the worker thread close the connection.
    // 

    pthread_mutex_lock(&m);
    // wait until buffer has space
    while(buffer_size == buffer_amt){
      pthread_cond_wait(&buf_not_full, &m);
    }
    
    // add connfd to buffer
    buffer[produce_idx] = connfd;
    produce_idx = (produce_idx + 1) % buffer_size;
    buffer_amt++;
    pthread_cond_signal(&buf_not_empty);
    pthread_mutex_unlock(&m);
  }
}

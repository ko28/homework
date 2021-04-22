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

pthread_cond_t buf_not_full = PTHREAD_COND_INITIALIZER;
pthread_cond_t buf_not_empty = PTHREAD_COND_INITIALIZER;
pthread_mutex_t m = PTHREAD_MUTEX_INITIALIZER;
int *buffer;
int buffer_size;
int buffer_amt = 0; // num elements in buffer
int produce_idx = 0; // next index to store connfd
int consume_idx = 0; // next index to get connfd

//connfd int[buffers]; 

// CS537: Parse the new arguments too
void getargs(int *port, int *threads, int *buffer_size, int *shm_name, int argc, char *argv[])
{
  if (argc != 5) {
    fprintf(stderr, "Usage: %s <port> <threads> <buffers> <shm_name>\n", argv[0]);
    //TODO: [port_num] [threads] [buffers] [shm_name]
    exit(1);
  }
  if(atoi(argv[1]) < 0 || atoi(argv[2]) < 0){
    fprintf(stderr, "Invalid args, buffer and threads cannot be negative (-1) and port_num (-1, 22)\n");
    //TODO: [port_num] [threads] [buffers] [shm_name]
    exit(1);
  }
  *port = atoi(argv[1]);
  *threads = atoi(argv[2]);
  *buffer_size = atoi(argv[3]);
  *shm_name = atoi(argv[4]);
}

static void *consumer(void *arg) {
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
      requestHandle(fd);
      Close(fd);

    }

    return NULL;
}


int main(int argc, char *argv[])
{
  int listenfd, connfd, port, clientlen, threads, shm_name;
  struct sockaddr_in clientaddr;

  getargs(&port, &threads, &buffer_size, &shm_name, argc, argv);

  //
  // CS537 (Part B): Create & initialize the shared memory region...
  //

  // 
  // CS537 (Part A): Create some threads...
  //
  buffer = (int *) malloc(sizeof(int) * threads);

  pthread_t workers[threads];
  for (int i = 0; i < threads; i++) {
        pthread_create(&workers[i], NULL, consumer, NULL);
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

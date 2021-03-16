#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

void debug(struct pstat p){
  for(int i = 0; i < NPROC; i++){
    printf(1, "pid: %d\tinuse: %d\ttimeslice: %d\tcompticks: %d\n", p.pid[i], p.inuse[i], p.timeslice[i], p.compticks[i]);
  }
}

int
main(int argc, char **argv)
{
  if(argc != 6){
    printf(2, "usage: schedtest sliceA sleepA sliceB sleepB sleepParent\n");
    exit();
  }
  
  int sliceA = atoi(argv[1]);
  char *sleepA = argv[2];
  int sliceB = atoi(argv[3]);
  char *sleepB = argv[4];
  int sleepParent = atoi(argv[5]);
  if(sliceA <= 0 || sliceB <= 0 || sleepParent <= 0){
    printf(2, "args needs to be positive\n");
    exit();   
  }

  
  // schedtest spawns two children processes, each running the loop application.  
  // One child A is given initial timeslice length of sliceA and runs loop sleepA; the other B is given initial timeslice length of sliceB and runs loop sleepB.
  // the parent process calls fork2() and exec() for the two children loop processes, A before B, with the specified initial timeslice;
  int pid_a = fork2(sliceA);
  if(pid_a != -1){
      // child
      if(pid_a == 0){
          char *args[4];
          args[0] = "loop";
          args[1] = sleepA;
          exec("loop", args);
          exit();
      }
      // parent
      else{
          //wait();
      }
  }

  int pid_b = fork2(sliceB);
  if(pid_b != -1){
      // child
      if(pid_b == 0){
          char *args[4];
          args[0] = "loop";
          args[1] = sleepB;
          exec("loop", args);
          exit();
      }
      // parent
      else{
          //wait();
      }
  }
    //printf(1, "pid_a: %d\tpid_b:%d\n", pid_a, pid_b);

  // The parent schedtest process then sleeps for sleepParent ticks by calling sleep(sleepParent)
  sleep(sleepParent);

  // After sleeping, the parent calls getpinfo(), and prints one line of two numbers separated by a space
  struct pstat p = {};
  //printf(1, "%p\n", (void *) &p);
  //getpinfo(&p);
  int compticksA = -1; 
  int compticksB = -1; 
  

  
  for(int i = 0; i < NPROC; i++){
      if(p.pid[i] == pid_a)
        compticksA = p.compticks[i];
      
      if(p.pid[i] == pid_b)
        compticksB = p.compticks[i];
  }


//debug(p);
//p.inuse[i] == 1 && 
//schedtest 2 3 5 5 100

  printf(1, "%d %d\n", compticksA, compticksB);
  
  wait();
  wait();
  exit();
}
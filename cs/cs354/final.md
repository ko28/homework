# Cache

## shiit

# Assembly Language Part II

## function calling - the stack

## param passing in caller’s frame, return value in %eax

Offset for param is `movl 8(%esp), %ecx`, i.e. move first param into %ecx. 8 because (+4 to skip over saved %ebp, +4 to skip over ret address). 0xc would be second param `void func(int first, int second)`

## transferring control (call, leave, ret instructions)

call

- a

leave

- movl %ebp, %esp # restore stack pointer
- popl %ebp # restore base pointer

ret

- popl %eip

## stack frame (%esp, %ebp)

## Saving registers (caller vs. callee saved)

| Caller Saved     | Callee Saved     |
| ---------------- | ---------------- |
| %eax, %ecx, %edx | %ebx, %esi, %edi |

## Recursion

## Allocating and accessing composites on the stack

## 1D and 2D arrays, structures, unions

Structures

- Store multiple data types in a single structure

Unions

- different way of accessing same data

## alignment

padded with respect to a size divisible by size of largest individual member

## pointers (including function pointers)

## hacking code and stack smashing with buffer overflows

## misc

### %eax vs (%eax)

%eax refers to the register %eax\
(%eax) refers to the value in the register %eax\
%eax = 0xffffe008\
%ebx = 0x0\
Memory:\
0xffffe008: 0xaabbccdd

- The instruction movw %eax, %ebx would result in %ebx = 0xffffe008.
- The instruction movw (%eax), %ebx would result in %ebx = 0xaabbccdd.
- The instruction movw %eax, (%ebx) would result in memory at 0x0 = 0xffffe008.

# Exceptions and Signals

## exception table (exception number) and control flow (events, processor state)

## exceptions - interrupts (asynchronous), traps (system calls), aborts, halts

| Class     | Cause                         | Async/sync | Return behavior                     |
| --------- | ----------------------------- | ---------- | ----------------------------------- |
| Interrupt | Signal from I/O device        | Async      | Always return to next instruction   |
| Trap      | Intentional Exception         | Sync       | Always return to next instruction   |
| Fault     | Potentially recoverable error | Sync       | Might return to current instruction |
| Abort     | Nonrecoverable error          | Sync       | Never returns                       |

## processes (pids & pgids), user/kernel modes, context switching & concurrent execution

- pid, id for process
- pgid, id for Process Group Identifier (Process Group Leader)

## signals

sending → delivering → receiving  
| Exceptions | # |
| ------------------------- | ----------- |
| Divide by zero | SIGFPE #8 |
| Seg fault | SIGSEGV #11 |
| Interrupt from keyboard | SIGINT #2 |
| Stop signal from terminal | SIGTSTP #20 |

### sending - kill(), alarm()

- when the kernel exception handler runs in response to a exceptional event, or a signal from some user process
- is directed to a destination process

#### code

- `kill -# <pid>` 9 is SIGKILL, 2 SIGINT Ctrl-c , 20 SIGTSTP 19SIGSTP, 18 SIGCONT
- `alarm(seconds);`, seconds until alarm is sent

### delivering - pending, blocking, bit vectors

- when the kernel records a sent signal for its dest process
- pending signal: delivered but not recieved
- each process has bit vector for recording pending signals
- Bit k is set to 0/1 when signal K is received/delivered

### receiving - signal handlers & sigaction()

- when the kernel causes the destination process to react to a pending signal
- happens when kernel transfers control back to a process
- multiple pending signals are done in order from low to high signal number

### multiple signal issues

# Linking and Loading

## forward declaration (declaring vs. defining)

- tells the compiler about certain attributes of an identifier before its fully defined

## multifile coding (header & src files), compilation (makefiles)

- header files: "public interface" mainly function declarations but also includes types, constants, and macros
- source files: "private implementation" must include definitions of things declared in its header file also includes additional things you don't intent to share

| Input                     | Tool        | Output |
| ------------------------- | ----------- | ------ |
| Divide by zero            | SIGFPE #8   |        |
| Seg fault                 | SIGSEGV #11 |        |
| Interrupt from keyboard   | SIGINT #2   |        |
| Stop signal from terminal | SIGTSTP #20 |        |

## static linking
- generate a complete executable object file with no var of func identifier  remaining in the final object file 
- Note: all language translation has already occurred. Need only to combine relocated and shared object files into executable object file 
## relocatable object files (ELF format)

## symbols, symbol tables
- all static(global) vars require linker symbols 
## symbol resolution (extern, static, strong and weak)

## relocation

## executable object files (ELF format)

## loading and execution

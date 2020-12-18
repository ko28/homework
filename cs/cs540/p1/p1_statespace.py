# Name: Daniel Ko
# Project 1, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

# Returns a copy of state which fills the jug corresponding to the index 
# in which (0 or 1) to its maximum capacity. 
def fill(state, max, which):
    temp_state = state.copy()
    temp_state[which] = max[which] 
    return temp_state

# Returns a copy of state which empties the jug 
# corresponding to the index in which (0 or 1). 
def empty(state, max, which):
    temp_state = state.copy()
    temp_state[which] = 0
    return temp_state

# Returns a copy of state which pours the contents of the jug at 
# index source into the jug at index dest, until source is empty or dest is full
def xfer(state, max, source, dest):
    temp_state = state.copy()
    # Move water from source to dest until dest is full or source is empty 
    while(temp_state[dest] < max[dest] and temp_state[source] > 0):
        temp_state[dest]+=1
        temp_state[source]-=1
    return temp_state

# Prints the list of unique successor states of the current state in any order.
def succ(state, max):
    succ_states = []
    
    # Succ states for fill and emptying 
    for i in range(len(state)):
        temp_fill = fill(state,max,i)
        if temp_fill not in succ_states:
            succ_states.append(temp_fill)
        
        temp_empty = empty(state,max,i)
        if temp_empty not in succ_states:
            succ_states.append(temp_empty) 

    # Succ states for transfering
    for a in range(len(state)):
        for b in range(len(state)):
            if a!=b:
                temp_xfer = xfer(state,max,a,b)
                if temp_xfer not in succ_states:
                    succ_states.append(temp_xfer) 

    print(succ_states)

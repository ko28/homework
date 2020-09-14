def fill(state, max, which):
    temp_state = state.copy()
    temp_state[which] = max[which] 
    return temp_state

def empty(state, max, which):
    temp_state = state.copy()
    temp_state[which] = 0
    return temp_state

def xfer(state, max, source, dest):
    temp_state = state.copy()
    while(temp_state[dest] < max[dest] and temp_state[source] > 0):
        temp_state[dest]+=1
        temp_state[source]-=1
    return temp_state

def succ(state, max):
    succ_states = []
    
    for i in range(len(state)):
        temp_fill = fill(state,max,i)
        if temp_fill not in succ_states:
            succ_states.append(temp_fill)
        
        temp_empty = empty(state,max,i)
        if temp_empty not in succ_states:
            succ_states.append(temp_empty) 
    
    for a in range(len(state)):
        for b in range(len(state)):
            if a!=b:
                temp_xfer = xfer(state,max,a,b)
                if temp_xfer not in succ_states:
                    succ_states.append(temp_xfer) 

    print(succ_states)

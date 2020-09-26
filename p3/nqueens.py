# Name: Daniel Ko
# Project 2, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

import copy

# Given a state of the board, return a list of all valid successor states
def succ(state, static_x, static_y):
    succs = []

    # If there is not a queen on the static point in the input state, return an empty list
    if(state[static_x] != static_y):
        return succs

    # Iterate over each row and generate succ by moving queen up and down  
    for x, pos_i in enumerate(state):
        if x != static_x:
            # move queen at x by 1 up if legal
            if state[x] + 1 <= len(state) - 1:
                new_succ = copy.deepcopy(state)
                new_succ[x] += 1
                succs.append(new_succ)

            # move queen at x down by 1 if legal
            if state[x] - 1 >= 0:
                new_succ = copy.deepcopy(state)
                new_succ[x] -= 1
                succs.append(new_succ)

    #The returned states should be sorted by the ascending order
    return sorted(succs)

# given a state of the board, return an integer score such that the goal state scores 0
# if a queen is attacked by multiple other queens, it will only be counted once.
def f(state):
    f = 0

    for x, val_x in enumerate(state):
        for h, val_h in enumerate(state):
            if x != h: 
                # Check horizontal 
                if val_x == val_h: # state[x] == state[h]
                    #print("horizontal x: " + str(x) + " h: " + str(h))
                    f += 1
                    break

                # Check diagonals 
                if float(abs(val_h - val_x))/float(abs(h - x)) == 1:
                    #print("diagonals x: " + str(x) + " h: " + str(h))
                    f += 1
                    break       

    return f 

# given the current state, use succ() to generate the successors and return the selected next state
def choose_next(curr, static_x, static_y):
    # including the current state in succ pursuant to https://piazza.com/class/kef2n72f455sp?cid=500
    succs = succ(curr, static_x, static_y)

    # If one of the possible states (including the current state) has a uniquely low score, select that state
    succs.append(curr)
    print(succs)
    f_vals = [f(x) for x in succs]
    print(f_vals)
    for x in succs: print(f(x))
    if f_vals.count(min(f_vals)) == 1 and len(succs) > 1:
        return succs[f_vals.index(min(f_vals))]
    print("2nd")

    #Otherwise, sort the states in ascending order (as though they were integers) and select the "lowest" state
    succs.remove(curr)
    succs_f = sorted(succs, key=lambda x: (f(x), x))
    return succs_f[0] if len(succs_f) > 0  else None



if __name__ == "__main__":
    #g = choose_next([0, 2, 0], 0, 0)
    ##print(g)
    print(succ([0, 1, 0], 0, 1))


#n_queens(initial_state, static_x, static_y) -- run the hill-climbing algorithm from a given initial state, return the convergence state
#n_queens_restart(n, k, static_x, static_y) -- run the hill-climbing algorithm on an n*n board with random restarts
# Name: Daniel Ko
# Project 2, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

import copy
import random 

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
    if curr[static_x] != static_y:
        return None

    succs = succ(curr, static_x, static_y)
    # include current state in succ
    succs.append(curr)
    return sorted(succs, key=lambda x: (f(x), x))[0]

# run the hill-climbing algorithm from a given initial state, return the convergence state
def n_queens(initial_state, static_x, static_y):
    past_state = initial_state
    print(str(past_state) + " - f=" + str(f(past_state)))
    min_state = choose_next(past_state, static_x, static_y)
    while f(past_state) != f(min_state):
        print(str(min_state) + " - f=" + str(f(min_state)))
        past_state = min_state
        min_state = choose_next(past_state, static_x, static_y)
        if f(min_state) == 0:
            break
    print(str(min_state) + " - f=" + str(f(min_state)))
    return min_state 

def n_queens_no_print(initial_state, static_x, static_y):
    past_state = initial_state
    min_state = choose_next(past_state, static_x, static_y)
    while f(past_state) != f(min_state):
        past_state = min_state
        min_state = choose_next(past_state, static_x, static_y)
        if f(min_state) == 0:
            break     
    return min_state 

# generates a valid n queens state 
def generate_random_start(n, static_x, static_y):
    #random.seed(1)
    state = []
    for x in range(n):
        if x == static_x:
            state.append(static_y)
        else:
            state.append(random.randint(0,n-1))
    #state = [random.randint(0,n-1) for x in range(n)]
    #state[static_x] = static_y
    return state


# run the hill-climbing algorithm on an n*n board with random restarts
def n_queens_restart(n, k, static_x, static_y):
    random.seed(1)
    best_states = []
    best_f = float('inf')
    for i in range(k):
        state = generate_random_start(n, static_x, static_y)
        #state = [random.randint(0,n-1) for x in range(n)]
        #state[static_x] = static_y
        hill_climb = n_queens_no_print(state, static_x, static_y)
        curr_f = f(hill_climb)

        # If you find an optimal solution before you reach k restarts, print the solution and terminate.
        if(curr_f == 0):
            print(str(hill_climb) + " - f=0")
            return

        # Better f found, remove old values and create new list 
        if curr_f < best_f:
            best_f = curr_f
            best_states = []
            best_states.append(hill_climb)
        # Same f found, add to best states 
        elif curr_f == best_f:
            best_states.append(hill_climb)
   
    #If you reach k before finding an optimal solution with a score of 0, print the best solution(s) in sorted order.
    for state in sorted(best_states):
        print(str(state) + " - f=" + str(f(state)))







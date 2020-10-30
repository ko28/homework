# Name: Daniel Ko
# Project 2, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

import heapq
import numpy as np 
import time

# calculates the sum of manhattan distances for each piece in the state
def manhattan(state):
    goal = {1:(0,0), 2:(0,1), 3:(0,2),
            4:(1,0), 5:(1,1), 6:(1,2),
            7:(2,0), 8:(2,1), 9:(2,2)}
    val = 0
    for i, piece in enumerate(state):
        if piece != 0:
            curr_pos = goal[i + 1]
            goal_pos = goal[piece]
            #print("curr: " + str(curr_pos) + " goal: " + str(goal_pos) + " " + str(abs(curr_pos[0]-goal_pos[0])) + " " + str(abs(curr_pos[1]-goal_pos[1])))
            val += abs(curr_pos[0]-goal_pos[0]) + abs(curr_pos[1]-goal_pos[1])
        #else:
            #print("0")
    return val

"""
# given a state of the puzzle, represented as a single list of integers with a 0 
# in the empty space, print to the console all of the possible successor states
def print_succ(state):
    # hold our successor states
    succ = []
    # convert 1d list in 2d list 
    two_dim_state = np.reshape(state, (3, 3))
    # tuple containing (row,col) of the 0 value
    index = np.where(two_dim_state == 0)
    index = (index[0][0], index[1][0])
    
    # checking the four possible spots (top, bottom, left, right) that can be a successor state  
    # top
    if index[0] - 1 >= 0:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0] - 1][index[1]]
        top[index[0] - 1][index[1]] = 0
        succ.append(top.ravel().tolist()) # convert numpy array -> 1d array -> list of int
    # bot
    if index[0] + 1 <= 2:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0] + 1][index[1]]
        top[index[0] + 1][index[1]] = 0
        succ.append(top.ravel().tolist())
    # left
    if index[1] - 1 >= 0:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0]][index[1] - 1]
        top[index[0]][index[1] - 1] = 0
        succ.append(top.ravel().tolist())
    # right
    if index[1] + 1 <= 2:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0]][index[1] + 1]
        top[index[0]][index[1] + 1] = 0
        succ.append(top.ravel().tolist())

    succ = sorted(succ)
    for state in succ:
        print(str(state) + " h=" + str(manhattan(state)))
"""


def generate_succ(state):
    # hold our successor states
    succ = []
    # convert 1d list in 2d list 
    two_dim_state = np.reshape(state, (3, 3))
    # tuple containing (row,col) of the 0 value
    index = np.where(two_dim_state == 0)
    index = (index[0][0], index[1][0])
    
    # checking the four possible spots (top, bottom, left, right) that can be a successor state  
    # left
    if index[0] - 1 >= 0:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0] - 1][index[1]]
        top[index[0] - 1][index[1]] = 0
        succ.append(top.ravel().tolist()) # convert numpy array -> 1d array -> list of int
    # top
    if index[1] + 1 <= 2:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0]][index[1] + 1]
        top[index[0]][index[1] + 1] = 0
        succ.append(top.ravel().tolist())
    # right
    if index[0] + 1 <= 2:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0] + 1][index[1]]
        top[index[0] + 1][index[1]] = 0
        succ.append(top.ravel().tolist())
    # bot
    if index[1] - 1 >= 0:
        top = two_dim_state.copy()
        top[index[0]][index[1]] = top[index[0]][index[1] - 1]
        top[index[0]][index[1] - 1] = 0
        succ.append(top.ravel().tolist())

    return sorted(succ)

# given a state of the puzzle, represented as a single list of integers with a 0 
# in the empty space, print to the console all of the possible successor states
def print_succ(state):
    succ = generate_succ(state)
    for state in succ:
        print(str(state) + " h=" + str(manhattan(state)))

# given a state of the puzzle, perform the A* search algorithm and print the 
# path from the current state to the goal state
def solve(state):
    pq = [] # prinitial_succce to implement a* search 
    parents = [] # used to backtracking later to construct path 
    visited = {} # only visit succ that we have not visited yet 
    # start queue with starting state
    g = 0
    h = manhattan(state)
    heapq.heappush(pq, (g + h, state, (g, h ,-1)))
    while pq:
        curr = heapq.heappop(pq)
        visited[tuple(curr[1])] = True
        if curr[2][1] == 0:
            print_path(curr, parents)
            return 
        parents.append(curr)
        succ = generate_succ(curr[1])
        for state in succ: 
            if tuple(state) not in visited:
                g = curr[2][0] + 1
                h = manhattan(state)
                parent_index = len(parents) - 1
                heapq.heappush(pq, (g + h, state, (g, h , parent_index)))


def print_path(state, parents):
    path = []
    path.append(state)
    index = state[2][2]
    while index != -1:
        path.append(parents[index])
        index = parents[index][2][2]
    for p in reversed(path): 
        print(str(p[1]) + " h=" + str(p[2][1]) + " moves: " + str(p[2][0]))


def main():
    #state = [1,2,3,4,0,5,6,7,8]
    #solve([4,3,8,5,1,6,7,2,0])
    #print_succ(state)
    #print()
    #print(generate_succ(state))
    #print_succ([4,3,8,5,1,6,7,2,0])
    #solve([4,3,8,5,1,6,7,2,0])
    start = time.process_time()
    solve([8,6,7,2,5,4,3,0,1])
    
    print(time.process_time() - start)


if __name__ == "__main__":
    main()
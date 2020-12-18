import random
import copy
import math

class Teeko2Player:
    """ An object representation for an AI game player for the game Teeko2.
    """
    board = [[' ' for j in range(5)] for i in range(5)]
    pieces = ['b', 'r']

    def __init__(self):
        """ Initializes a Teeko2Player object by randomly selecting red or black as its
        piece color.
        """
        self.my_piece = random.choice(self.pieces)
        self.opp = self.pieces[0] if self.my_piece == self.pieces[1] else self.pieces[1]

    def is_drop_phase(self, state):
        drop_phase = False
        num_non_empty = 0   
        for l in state:
            for val in l:
                if val != ' ':
                    num_non_empty += 1

        if num_non_empty < 8:
            drop_phase = True 
        return drop_phase

    def succ(self, state, turn_piece):
        succ_list = []
        one_dim_state = sum(state, [])
        
        # succ will just be putting a piece in empty spot for drop in 
        if self.is_drop_phase(state):
            for i in range(len(state)):
                for j in range(len(state[0])):
                    if state[i][j] == ' ':
                        next_state = copy.deepcopy(state)
                        next_state[i][j] = turn_piece
                        succ_list.append(next_state)
        # succ will be 
        else:
            for i_old in range(len(state)):
                for j_old in range(len(state[0])):
                    # our piece we can move to a different location
                    if state[i_old][j_old] == turn_piece:
                        for cord in self.get_neighbors(state, i_old, j_old):
                            if state[cord[0]][cord[1]] == ' ':
                                next_state = copy.deepcopy(state)
                                next_state[cord[0]][cord[1]] = next_state[i_old][j_old]
                                next_state[i_old][j_old] = ' '
                                succ_list.append(next_state)
                                   

            '''
                    for i in succ_list:
            for j in i:
                print(j)
            print()
            '''
        return succ_list

    def get_neighbors(self, state, i, j):
        neighbors = []
        # check all surrounding squares 
        if i - 1 >= 0:
            neighbors.append((i-1, j))
        if i + 1 < len(state):
            neighbors.append((i+1, j))
        if j - 1 >= 0:
            neighbors.append((i, j-1))
        if j + 1 < len(state):
            neighbors.append((i, j+1))
        if i - 1 >= 0 and j - 1 >= 0:
            neighbors.append((i-1, j-1))
        if i - 1 >= 0 and j + 1 < len(state):
            neighbors.append((i-1, j+1))
        if i + 1 < len(state) and j - 1 >= 0:
            neighbors.append((i+1, j-1))
        if i + 1 < len(state) and j + 1 < len(state):
            neighbors.append((i+1, j+1))
        return neighbors

    def heuristic_game_value(self, state):
        count = dict()
        count[self.my_piece] = 0
        count[self.opp] = 0

        for i in range(len(state)):
            for j in range(len(state[0])):
                player = state[i][j]
                # check if current square is non empty
                if player != ' ':
                    # check all surrounding squares 
                    if i - 1 >= 0 and state[i-1][j] == player:
                        count[player]+=1
                    if i + 1 < len(state) and state[i+1][j] == player:
                        count[player]+=1
                    if j - 1 >= 0 and state[i][j-1] == player:
                        count[player]+=1
                    if j + 1 < len(state) and state[i][j+1] == player:
                        count[player]+=1
                    if i - 1 >= 0 and j - 1 >= 0 and state[i-1][j-1] == player:
                        count[player]+=1
                    if i - 1 >= 0 and j + 1 < len(state) and state[i-1][j+1] == player:
                        count[player]+=1
                    if i + 1 < len(state) and j - 1 >= 0 and state[i+1][j-1] == player:
                        count[player]+=1
                    if i + 1 < len(state) and j + 1 < len(state) and state[i+1][j+1] == player:
                        count[player]+=1
        
        return (count[self.my_piece] - count[self.opp]) / max(1,count[self.my_piece] + count[self.opp])



    
    def Max_Value(self, state, depth):
        # Check if this is a terminal state
        val = self.game_value(state)
        if val != 0:
            return val
        
        if depth > 2:
            return self.heuristic_game_value(state)

        a = -math.inf
        
        # find next best state
        best_state = state
        for s in self.succ(state, self.my_piece):
            old_a = a
            a = max(a, self.Min_Value(s, depth + 1))
            if old_a != a:
                #print(s)
                best_state = s
        
        # need to return a move if base case
        if depth == 0:
            return best_state

        return a

    def Min_Value(self, state, depth):
        # Check if this is a terminal state
        val = self.game_value(state)
        if val != 0:
            return val
        
        if depth > 2:
            return self.heuristic_game_value(state)

        b = math.inf
        for s in self.succ(state, self.opp):
            b = min(b, self.Max_Value(s, depth + 1))
        
        return b

    def make_move(self, state):

        new_state = self.Max_Value(state, 0)
        move = []     
        for i in range(len(state)):
            for j in range(len(state[0])):
                if state[i][j] != new_state[i][j]:
                    move.append((i,j))     

        if len(move) == 2 and state[move[0][0]][move[0][1]] != ' ' :
            move.reverse()     
       
        return move        

    def make_move_rand(self, state):
        """ Selects a (row, col) space for the next move. You may assume that whenever
        this function is called, it is this player's turn to move.

        Args:
            state (list of lists): should be the current state of the game as saved in
                this Teeko2Player object. Note that this is NOT assumed to be a copy of
                the game state and should NOT be modified within this method (use
                place_piece() instead). Any modifications (e.g. to generate successors)
                should be done on a deep copy of the state.

                In the "drop phase", the state will contain less than 8 elements which
                are not ' ' (a single space character).

        Return:
            move (list): a list of move tuples such that its format is
                    [(row, col), (source_row, source_col)]
                where the (row, col) tuple is the location to place a piece and the
                optional (source_row, source_col) tuple contains the location of the
                piece the AI plans to relocate (for moves after the drop phase). In
                the drop phase, this list should contain ONLY THE FIRST tuple.

        Note that without drop phase behavior, the AI will just keep placing new markers
            and will eventually take over the board. This is not a valid strategy and
            will earn you no points.
        """

        if not self.is_drop_phase(state):
            # TODO: choose a piece to move and remove it from the board
            # (You may move this condition anywhere, just be sure to handle it)
            #
            # Until this part is implemented and the move list is updated
            # accordingly, the AI will not follow the rules after the drop phase!
            while True:
                

                i_old = random.randrange(len(state))
                j_old = random.randrange(len(state[0]))
                #i_new = random.randrange(len(state))
                #j_new = random.randrange(len(state[0]))
                if state[i_old][j_old] == self.opp:
                    for cord in (self.get_neighbors(state, i_old, j_old)):
                        if state[cord[0]][cord[1]] == ' ':
                            return [(cord[0],cord[1]),(i_old,j_old)]

        # select an unoccupied space randomly
        # TODO: implement a minimax algorithm to play better
        move = []
        (row, col) = (random.randint(0,4), random.randint(0,4))
        while not state[row][col] == ' ':
            (row, col) = (random.randint(0,4), random.randint(0,4))

        # ensure the destination (row,col) tuple is at the beginning of the move list
        move.insert(0, (row, col))
        return move

    def opponent_move(self, move):
        """ Validates the opponent's next move against the internal board representation.
        You don't need to touch this code.

        Args:
            move (list): a list of move tuples such that its format is
                    [(row, col), (source_row, source_col)]
                where the (row, col) tuple is the location to place a piece and the
                optional (source_row, source_col) tuple contains the location of the
                piece the AI plans to relocate (for moves after the drop phase). In
                the drop phase, this list should contain ONLY THE FIRST tuple.
        """
        # validate input
        if len(move) > 1:
            source_row = move[1][0]
            source_col = move[1][1]
            if source_row != None and self.board[source_row][source_col] != self.opp:
                self.print_board()
                print(move)
                raise Exception("You don't have a piece there!")
            if abs(source_row - move[0][0]) > 1 or abs(source_col - move[0][1]) > 1:
                self.print_board()
                print(move)
                raise Exception('Illegal move: Can only move to an adjacent space')
        if self.board[move[0][0]][move[0][1]] != ' ':
            raise Exception("Illegal move detected")
        # make move
        self.place_piece(move, self.opp)

    def place_piece(self, move, piece):
        """ Modifies the board representation using the specified move and piece

        Args:
            move (list): a list of move tuples such that its format is
                    [(row, col), (source_row, source_col)]
                where the (row, col) tuple is the location to place a piece and the
                optional (source_row, source_col) tuple contains the location of the
                piece the AI plans to relocate (for moves after the drop phase). In
                the drop phase, this list should contain ONLY THE FIRST tuple.

                This argument is assumed to have been validated before this method
                is called.
            piece (str): the piece ('b' or 'r') to place on the board
        """
        if len(move) > 1:
            self.board[move[1][0]][move[1][1]] = ' '
        self.board[move[0][0]][move[0][1]] = piece


    def print_board(self):
        """ Formatted printing for the board """
        for row in range(len(self.board)):
            line = str(row)+": "
            for cell in self.board[row]:
                line += cell + " "
            print(line)
        print("   A B C D E")

    def game_value(self, state):
        """ Checks the current board status for a win condition

        Args:
        state (list of lists): either the current state of the game as saved in
            this Teeko2Player object, or a generated successor state.

        Returns:
            int: 1 if this Teeko2Player wins, -1 if the opponent wins, 0 if no winner

        """
        # check horizontal wins
        for row in state:
            for i in range(2):
                if row[i] != ' ' and row[i] == row[i+1] == row[i+2] == row[i+3]:
                    return 1 if row[i]==self.my_piece else -1

        # check vertical wins
        for col in range(5):
            for i in range(2):
                if state[i][col] != ' ' and state[i][col] == state[i+1][col] == state[i+2][col] == state[i+3][col]:
                    return 1 if state[i][col]==self.my_piece else -1

        # check \ diagonal wins
        diag_bot = []
        diag_top = []
        diag_mid_top = []
        diag_mid_bot = []
        for i in range(4):
            diag_mid_top.append(state[i][i])
            diag_mid_bot.append(state[i+1][i+1])
            diag_bot.append(state[i+1][i])
            diag_top.append(state[i][i+1])
        diag = [diag_bot, diag_top, diag_mid_top, diag_mid_bot]
        for d in diag:
            if all(i == self.my_piece for i in d): 
                return 1
            if all(i == self.opp for i in d): 
                return -1

        # check / diagonal wins
        diag_bot = []
        diag_top = []
        diag_mid_top = []
        diag_mid_bot = []
        offset = len(state) - 1
        for i in range(4):
            diag_mid_bot.append(state[offset - i][i])
            diag_bot.append(state[offset - i][i+1])
            diag_top.append(state[offset - i - 1][i])
            diag_mid_top.append(state[offset - i- 1][i+1])
        diag = [diag_bot,diag_top,diag_mid_top,diag_mid_bot]
        for d in diag:
            if all(i == self.my_piece for i in d): 
                return 1
            if all(i == self.opp for i in d): 
                return -1


        # check diamond wins
        diamonds = []
        for i in range(1,4):
            for j in range(1,4):
                # middle needs to be empty
                if state[i][j] == ' ':
                    d = [state[i+1][j], state[i-1][j], state[i][j+1], state[i][j-1]]
                    diamonds.append(d)

        for d in diamonds:
            if all(i == self.my_piece for i in d): 
                return 1
            if all(i == self.opp for i in d): 
                return -1

        return 0 # no winner yet

############################################################################
#
# THE FOLLOWING CODE IS FOR SAMPLE GAMEPLAY ONLY
#
############################################################################
def maintwo():
    print('Hello, this is Samaritan')
    ai = Teeko2Player()
    piece_count = 0
    turn = 0

    # drop phase
    while piece_count < 8 and ai.game_value(ai.board) == 0:

        # get the player or AI's move
        if ai.my_piece == ai.pieces[turn]:
            ai.print_board()
            move = ai.make_move(ai.board)
            ai.place_piece(move, ai.my_piece)
            print(ai.my_piece+" moved at "+chr(move[0][1]+ord("A"))+str(move[0][0]))
        else:
            move_made = False
            ai.print_board()
            print(ai.opp+"'s turn")
            while not move_made:
                player_move = ai.make_move_rand(ai.board)[0]
                print(player_move)
                d = {0:'A',1:'B',2:'C',3:'D',4:'E'}
                #move_char =  d[player_move[0]] + str(player_move[1])
                ai.opponent_move([(player_move[0], player_move[1])])
                move_made = True


        # update the game variables
        piece_count += 1
        turn += 1
        turn %= 2

    # move phase - can't have a winner until all 8 pieces are on the board
    while ai.game_value(ai.board) == 0:

        # get the player or AI's move
        if ai.my_piece == ai.pieces[turn]:
            ai.print_board()
            move = ai.make_move(ai.board)
            ai.place_piece(move, ai.my_piece)
            print(ai.my_piece+" moved from "+chr(move[1][1]+ord("A"))+str(move[1][0]))
            print("  to "+chr(move[0][1]+ord("A"))+str(move[0][0]))
        else:
            move_made = False
            ai.print_board()
            print(ai.opp+"'s turn")
            while not move_made:
                player_move = ai.make_move_rand(ai.board)
                try:
                    ai.opponent_move([(player_move[0][0], player_move[0][1]),
                                      (player_move[1][0], player_move[1][1])])
                    move_made = True
                except Exception as e:
                    print(e)

        # update the game variables
        turn += 1
        turn %= 2

    ai.print_board()
    if ai.game_value(ai.board) == 1:
        print("AI wins! Game over.")
    else:
        print("You win! Game over.")

def main():
    print('Hello, this is Samaritan')
    ai = Teeko2Player()
    piece_count = 0
    turn = 0

    # drop phase
    while piece_count < 8 and ai.game_value(ai.board) == 0:

        # get the player or AI's move
        if ai.my_piece == ai.pieces[turn]:
            ai.print_board()
            move = ai.make_move(ai.board)
            ai.place_piece(move, ai.my_piece)
            print(ai.my_piece+" moved at "+chr(move[0][1]+ord("A"))+str(move[0][0]))
        else:
            move_made = False
            ai.print_board()
            print(ai.opp+"'s turn")
            while not move_made:
                player_move = input("Move (e.g. B3): ")
                while player_move[0] not in "ABCDE" or player_move[1] not in "01234":
                    player_move = input("Move (e.g. B3): ")
                try:
                    ai.opponent_move([(int(player_move[1]), ord(player_move[0])-ord("A"))])
                    move_made = True
                except Exception as e:
                    print(e)

        # update the game variables
        piece_count += 1
        turn += 1
        turn %= 2

    # move phase - can't have a winner until all 8 pieces are on the board
    while ai.game_value(ai.board) == 0:

        # get the player or AI's move
        if ai.my_piece == ai.pieces[turn]:
            ai.print_board()
            move = ai.make_move(ai.board)
            ai.place_piece(move, ai.my_piece)
            print(ai.my_piece+" moved from "+chr(move[1][1]+ord("A"))+str(move[1][0]))
            print("  to "+chr(move[0][1]+ord("A"))+str(move[0][0]))
        else:
            move_made = False
            ai.print_board()
            print(ai.opp+"'s turn")
            while not move_made:
                move_from = input("Move from (e.g. B3): ")
                while move_from[0] not in "ABCDE" or move_from[1] not in "01234":
                    move_from = input("Move from (e.g. B3): ")
                move_to = input("Move to (e.g. B3): ")
                while move_to[0] not in "ABCDE" or move_to[1] not in "01234":
                    move_to = input("Move to (e.g. B3): ")
                try:
                    ai.opponent_move([(int(move_to[1]), ord(move_to[0])-ord("A")),
                                    (int(move_from[1]), ord(move_from[0])-ord("A"))])
                    move_made = True
                except Exception as e:
                    print(e)

        # update the game variables
        turn += 1
        turn %= 2

    ai.print_board()
    if ai.game_value(ai.board) == 1:
        print("AI wins! Game over.")
    else:
        print("You win! Game over.")

if __name__ == "__main__":
    maintwo()

from funny_puzzle import *
import sys


if __name__ == '__main__':
    backup_stdout = sys.stdout
    sys.stdout = open('test.txt', 'w')

    print_succ([8,7,6,5,4,3,2,1,0])
    print("TEST 1 DONE")
    solve([1, 2, 3, 4, 5, 6, 7, 0, 8])
    solve([1,2,3,4,5,6,7,8,0])
    print("TEST 2 DONE")
    solve([4, 3, 8, 5, 1, 6, 7, 2, 0])
    solve([1,2,3,6,7,4,5,0,8])

    sys.stdout.close()
    sys.stdout = backup_stdout
    live = open('test.txt', 'r')
    ref = open('ref.txt', 'r')

    live_l = live.readlines()
    ref_l = ref.readlines()

    live.close()
    ref.close()

    for l, r in zip(live_l, ref_l):
        if not l == r:
            print("Yours: " + l.strip())
            print("Ref:   " + r)

    print("If this is all you see, your code is good.")


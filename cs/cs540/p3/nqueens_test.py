import io
import unittest
import unittest.mock


class NQueensTest(unittest.TestCase):

    def test_succ_1(self):
        from nqueens import succ

        succ_states = succ([0, 1, 2], 0, 0)
        expected_res = [[0, 0, 2], [0, 1, 1], [0, 2, 2]]
        self.assertEqual(succ_states, expected_res)

    def test_succ_2(self):
        from nqueens import succ

        succ_states = succ([0, 1, 2], 0, 1)
        expected_res = []
        self.assertEqual(succ_states, expected_res)

    def test_f(self):
        from nqueens import f

        self.assertEqual(f([1, 2, 2]), 3)
        self.assertEqual(f([2, 2, 2]), 3)
        self.assertEqual(f([0, 0, 2]), 3)
        self.assertEqual(f([0, 2, 0]), 2)
        self.assertEqual(f([0, 2, 1]), 2)

    def test_choose_next(self):
        from nqueens import choose_next

        self.assertEqual(choose_next([1, 1, 2], 1, 1), [0, 1, 2])
        self.assertEqual(choose_next([0, 2, 0], 0, 0), [0, 2, 0])
        self.assertEqual(choose_next([0, 1, 0], 0, 0), [0, 2, 0])
        self.assertEqual(choose_next([0, 1, 0], 0, 1), None)

    @unittest.mock.patch('sys.stdout', new_callable=io.StringIO)
    def check_n_queens(self, state, must_x, must_y, expected_output, expected_stdout, mock_stdout):
        from nqueens import n_queens

        final_state = n_queens(state, must_x, must_y)
        self.assertEqual(mock_stdout.getvalue(), expected_stdout)
        self.assertEqual(final_state, expected_output)

    def test_n_queens_1(self):
        expected_stdout = "".join([
            "[0, 1, 2, 3, 5, 6, 6, 7] - f=8\n",
            "[0, 1, 2, 3, 5, 7, 6, 7] - f=7\n",
            "[0, 1, 1, 3, 5, 7, 6, 7] - f=7\n"])
        expected_output = [0, 1, 1, 3, 5, 7, 6, 7]

        state, must_x, must_y = [0, 1, 2, 3, 5, 6, 6, 7], 1, 1
        self.check_n_queens(state, must_x, must_y, expected_output, expected_stdout)

    def test_n_queens_2(self):
        expected_stdout = "".join([
            "[0, 7, 3, 4, 7, 1, 2, 2] - f=7\n",
            "[0, 6, 3, 4, 7, 1, 2, 2] - f=6\n",
            "[0, 6, 3, 5, 7, 1, 2, 2] - f=4\n",
            "[0, 6, 3, 5, 7, 1, 3, 2] - f=3\n",
            "[0, 6, 3, 5, 7, 1, 4, 2] - f=0\n"
        ])
        expected_output = [0, 6, 3, 5, 7, 1, 4, 2]

        state, must_x, must_y = [0, 7, 3, 4, 7, 1, 2, 2], 0, 0
        self.check_n_queens(state, must_x, must_y, expected_output, expected_stdout)


if __name__ == "__main__":
    unittest.main()

__author__ = 'cs540-testers'
__credits__ = ['Harrison Clark', 'Stephen Jasina', 'Saurabh Kulkarni',
		'Alex Moon']
version = 'v0.1'

import unittest
import regression
import io
import sys
import numpy as np
import numpy.testing

class TestRegression(unittest.TestCase):

    BODYFAT_FILE = 'bodyfat.csv'
    def test_get_dataset(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)
        self.assertEqual(dataset.shape, (252,16))

        self.assertEqual(dataset[0][0], 12.6)
        self.assertEqual(dataset[251][0], 30.7)
        self.assertEqual(dataset[75][7], 91.6)

    def test_print_stats(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)
        capturedOutput = io.StringIO()
        sys.stdout = capturedOutput
        regression.print_stats(dataset, 1)
        output = capturedOutput.getvalue()
        sys.stdout = sys.__stdout__

        self.assertEqual(output, "252\n1.06\n0.02\n")

    def test_regression(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)

        mse = regression.regression(dataset, cols=[2,3], betas=[0,0,0])
        numpy.testing.assert_almost_equal(mse, 418.50384920634923, 7)

        mse = regression.regression(dataset, cols=[2,3,4], betas=[0,-1.1,-.2,3])
        numpy.testing.assert_almost_equal(mse, 11859.17408611111, 7)

    def test_gradient_descent(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)

        grad_desc = regression.gradient_descent(dataset, cols=[2,3], betas=[0,0,0])
        numpy.testing.assert_almost_equal(grad_desc, np.array([-37.87698413, -1756.37222222, -7055.35138889]))

    def test_iterate_gradient(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)
        capturedOutput = io.StringIO()
        sys.stdout = capturedOutput
        regression.iterate_gradient(dataset, cols=[1,8], betas=[400,-400,300], T=10, eta=1e-4)

        output = capturedOutput.getvalue()
        output_lines = output.split('\n')
        sys.stdout = sys.__stdout__

        expected_lines = ["1 423085332.40 394.45 -405.84 -220.18",
        "2 229744495.73 398.54 -401.54 163.14",
        "3 124756241.68 395.53 -404.71 -119.33",
        "4 67745350.04 397.75 -402.37 88.82",
        "5 36787203.39 396.11 -404.09 -64.57",
        "6 19976260.50 397.32 -402.82 48.47",
        "7 10847555.07 396.43 -403.76 -34.83",
        "8 5890470.68 397.09 -403.07 26.55",
        "9 3198666.69 396.60 -403.58 -18.68",
        "10 1736958.93 396.96 -403.20 14.65"]

        for out_line, exp_line in zip(output_lines, expected_lines):
            self.assertEqual(out_line, exp_line)

        

    def test_compute_betas(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)
        betas = regression.compute_betas(dataset, [1,2])

        np.testing.assert_almost_equal(betas[0], 1.4029395600144443)
        np.testing.assert_almost_equal(betas[1], 441.3525943592249)
        np.testing.assert_almost_equal(betas[2], -400.5954953685588)
        np.testing.assert_almost_equal(betas[3], 0.009892204826346139)

    def test_predict(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)
        prediction = regression.predict(dataset, cols=[1,2], features=[1.0708, 23])
        np.testing.assert_almost_equal(prediction, 12.62245862957813)

    def test_sgd(self):
        dataset = regression.get_dataset(self.BODYFAT_FILE)
        capturedOutput = io.StringIO()
        sys.stdout = capturedOutput
        regression.sgd(dataset, cols=[2,3], betas=[0,0,0], T=5, eta=1e-6)

        output = capturedOutput.getvalue()
        output_lines = output.split('\n')
        sys.stdout = sys.__stdout__

        expected_lines = ["1 387.33 0.00 0.00 0.00",
        "2 379.60 0.00 0.00 0.01",
        "3 335.99 0.00 0.00 0.01",
        "4 285.89 0.00 0.00 0.02",
        "5 245.75 0.00 0.01 0.03"]

        for out_line, exp_line in zip(output_lines, expected_lines):
            self.assertEqual(out_line, exp_line)

        

if __name__ == "__main__":
    unittest.main()
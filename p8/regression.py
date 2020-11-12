import numpy as np
import random
import csv
# Feel free to import other packages, if needed.
# As long as they are supported by CSL machines.


def get_dataset(filename):
    """
    TODO: implement this function.

    INPUT: 
        filename - a string representing the path to the csv file.

    RETURNS:
        An n by m+1 array, where n is # data points and m is # features.
        The labels y should be in the first column.
    """
    dataset = None

    with open(filename, newline='') as csvfile:
        reader = csv.reader(csvfile)
        data = list(reader)[1:]
        dataset = np.array(data).astype("float")
      
    return dataset[:,1:] # remove first index column


def print_stats(dataset, col):
    """
    TODO: implement this function.

    INPUT: 
        dataset - the body fat n by m+1 array
        col     - the index of feature to summarize on. 
                  For example, 1 refers to density.

    RETURNS:
        None
    """
    data_col = dataset[:,col]
    # the number of data points
    print(len(data_col))
    # sample mean of column
    print(np.around(np.mean(data_col), 2))
    
    # sample standard deviation of column
    print(np.around(np.std(data_col), 2))

def regression(dataset, cols, betas):
    """
    TODO: implement this function.

    INPUT: 
        dataset - the body fat n by m+1 array
        cols    - a list of feature indices to learn.
                  For example, [1,8] refers to density and abdomen.
        betas   - a list of elements chosen from [beta0, beta1, ..., betam]

    RETURNS:
        mse of the regression model
    """
    mse = 0

    for row in dataset:
        row_mse = betas[0] - row[0]
        for i, c in enumerate(cols):
            row_mse += row[c] * betas[i+1] 
        row_mse = (row_mse * row_mse)
        mse += row_mse

    mse = mse/len(dataset)
    return mse


def gradient_descent(dataset, cols, betas):
    """
    TODO: implement this function.

    INPUT: 
        dataset - the body fat n by m+1 array
        cols    - a list of feature indices to learn.
                  For example, [1,8] refers to density and abdomen.
        betas   - a list of elements chosen from [beta0, beta1, ..., betam]

    RETURNS:
        An 1D array of gradients
    """
    grads = np.array([])
    grad_sum = 0
    for r, row in enumerate(dataset):
        row_grad = betas[0] - row[0]
        for i, c in enumerate(cols):
            row_grad += row[c] * betas[i+1] 
        grad_sum += row_grad 
    grad_sum = (2/len(dataset)) * grad_sum
    grads = np.append(grads, grad_sum)


    for cee in cols:
        grad_sum = 0
        for r, row in enumerate(dataset):
            row_grad = betas[0] - row[0]
            for i, c in enumerate(cols):
                row_grad += row[c] * betas[i+1] 
            grad_sum += row_grad * row[cee]
        grad_sum = (2/len(dataset)) * grad_sum
        grads = np.append(grads, grad_sum)

    return grads


def iterate_gradient(dataset, cols, betas, T, eta):
    """
    TODO: implement this function.

    INPUT: 
        dataset - the body fat n by m+1 array
        cols    - a list of feature indices to learn.
                  For example, [1,8] refers to density and abdomen.
        betas   - a list of elements chosen from [beta0, beta1, ..., betam]
        T       - # iterations to run
        eta     - learning rate

    RETURNS:
        None
    """
    pass


def compute_betas(dataset, cols):
    """
    TODO: implement this function.

    INPUT: 
        dataset - the body fat n by m+1 array
        cols    - a list of feature indices to learn.
                  For example, [1,8] refers to density and abdomen.

    RETURNS:
        A tuple containing corresponding mse and several learned betas
    """
    betas = None
    mse = None
    return (mse, *betas)


def predict(dataset, cols, features):
    """
    TODO: implement this function.

    INPUT: 
        dataset - the body fat n by m+1 array
        cols    - a list of feature indices to learn.
                  For example, [1,8] refers to density and abdomen.
        features- a list of observed values

    RETURNS:
        The predicted body fat percentage value
    """
    result = None
    return result


def random_index_generator(min_val, max_val, seed=42):
    """
    DO NOT MODIFY THIS FUNCTION.
    DO NOT CHANGE THE SEED.
    This generator picks a random value between min_val and max_val,
    seeded by 42.
    """
    random.seed(seed)
    while True:
        yield random.randrange(min_val, max_val)


def sgd(dataset, cols, betas, T, eta):
    """
    TODO: implement this function.
    You must use random_index_generator() to select individual data points.

    INPUT: 
        dataset - the body fat n by m+1 array
        cols    - a list of feature indices to learn.
                  For example, [1,8] refers to density and abdomen.
        betas   - a list of elements chosen from [beta0, beta1, ..., betam]
        T       - # iterations to run
        eta     - learning rate

    RETURNS:
        None
    """
    pass


if __name__ == '__main__':
    dataset = get_dataset('bodyfat.csv')
    #print(ds)
    #print(ds.shape)
    #print_stats(ds,1)
    #print(regression(ds, cols=[2,3,4], betas=[0,-1.1,-.2,3]))
    print(gradient_descent(dataset, cols=[2,3], betas=[0,0,0]))
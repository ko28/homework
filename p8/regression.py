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
    print(t_round(np.mean(data_col)))
    
    # sample standard deviation of column
    print(t_round(np.std(data_col)))

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
    for t in range(1, T+1):
        grad = gradient_descent(dataset, cols, betas)
        
        for i, beta in enumerate(betas):
            betas[i] = beta - (eta * grad[i])
        
        mse = regression(dataset, cols, betas)

        # order: T, mse, beta0, beta1, beta8
        print(t, t_round(mse), t_round(betas[0]), *[t_round(b) for b in betas[1:]])

# helper function to round to 2 decimal places
def t_round(val):
    return "%.2f" % round(val, 2)

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
    X = dataset[:, cols]
    X = np.insert(X, 0, np.ones(dataset.shape[0]), axis=1)
    y = dataset[:,0]
    betas = (np.linalg.inv(X.T @ X) @ X.T) @ y

    mse = regression(dataset, cols, betas)
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
    betas = list(compute_betas(dataset, cols))
    result = betas[1]

    for i, f in enumerate(features):
        result += f * betas[i+2]

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
    row_gen = random_index_generator(0, len(dataset))
    for t in range(1, T+1):
        grad = approx_grad(dataset, cols, betas, next(row_gen))
        
        for i, beta in enumerate(betas):
            betas[i] = beta - (eta * grad[i])
        
        mse = regression(dataset, cols, betas)

        # order: T, mse, beta0, beta1, beta8
        print(t, t_round(mse), t_round(betas[0]), *[t_round(b) for b in betas[1:]])

def approx_grad(dataset, cols, betas, r):
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
    row = dataset[ r,:]
    grad_sum = betas[0] - row[0]
    for i, c in enumerate(cols):
        grad_sum += row[c] * betas[i+1] 
    grad_sum = 2 * grad_sum
    grads = np.append(grads, grad_sum)

    for cee in cols:
        grad_sum = betas[0] - row[0]
        for i, c in enumerate(cols):
            grad_sum += row[c] * betas[i+1] 
        grad_sum = 2 * grad_sum * row[cee]
        #print("row cee", row[cee])
        grads = np.append(grads, grad_sum)
    #print('grads', grads)
    return grads

if __name__ == '__main__':
    dataset = get_dataset('bodyfat.csv')
    print_stats(dataset, 1)
    #print(len(dataset))
    #r = random_index_generator(1,4)
    #sgd(dataset, cols=[2,3], betas=[0,0,0], T=5, eta=1e-6)
    #print()
    #sgd(dataset, cols=[2,8], betas=[-40,0,0.5], T=10, eta=1e-5)
    #print(ds)
    #print(ds.shape)
    #print_stats(ds,1)
    #print(regression(ds, cols=[2,3,4], betas=[0,-1.1,-.2,3]))
    #print(gradient_descent(dataset, cols=[2,3], betas=[0,0,0]))
    #iterate_gradient(dataset, cols=[1,8], betas=[400,-400,300], T=10, eta=1e-4)
    #print(predict(dataset, cols=[1,2], features=[1.0708, 23]))
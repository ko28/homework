# Name: Daniel Ko
# Project 5, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

from scipy.linalg import eigh  
import numpy as np
import matplotlib.pyplot as pl

# Load the dataset from a provided .npy file, re-center it around the origin and return it as a NumPy array of floats
def load_and_center_dataset(filename):
    data = np.load(filename)
    reshaped = np.reshape(data, (2000,784))
    mean = np.mean(reshaped, axis=0)
    return reshaped - mean

# Calculate and return the covariance matrix of the dataset as a NumPy matrix (d x d array)
def get_covariance(dataset):
    return np.dot(np.transpose(dataset), np.conj(dataset)) / (len(dataset) - 1)

# Perform eigen decomposition on the covariance matrix S and return a diagonal matrix (NumPy array) 
# with the largest m eigenvalues on the diagonal, and a matrix (NumPy array) with the corresponding 
# eigenvectors as columns
def get_eig(S, m):
    evals, evects = eigh(S)
    largest_vals_indices = np.argsort(evals)[::-1]
    largest_vals = evals.take(largest_vals_indices[:m])
    diag = np.diag(largest_vals)
    u = []
    for i in largest_vals_indices[:m]:
        u.append(evects[:,i])

    return diag, np.array(u).T

def get_eig_perc(S, perc):
    evals, evects = eigh(S)
    largest_vals_indices = np.argsort(evals)[::-1]
    denom = sum(evals)
    largest_vals_perc = []
    u=[]
    for i in largest_vals_indices:
        if evals[i]/denom > perc:
            largest_vals_perc.append(evals[i])
            u.append(evects[:,i])
    
    diag = np.diag(largest_vals_perc)        

    return diag, np.array(u).T

def project_image(image, U):
    x = np.zeros(np.size(U,0))
    for i in range(np.size(U,1)):
        a = np.matmul(U[:,i].T, image)
        x += a * U[:,i]
    return x

def display_image(orig, proj):
    fig, axs = pl.subplots(1, 2, constrained_layout=True, figsize=(9, 3))
    axs[0].set_title('Original')
    axs[1].set_title('Projection')
    orig_color = axs[0].imshow(orig.reshape(28,28), aspect='equal', cmap='gray')
    prog_color = axs[1].imshow(proj.reshape(28,28), aspect='equal', cmap='gray')
    fig.colorbar(orig_color, ax=axs[0], aspect=50)
    fig.colorbar(prog_color, ax=axs[1], aspect=50)
    pl.show()


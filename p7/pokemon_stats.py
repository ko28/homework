# Name: Daniel Ko
# Project 7, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

import csv 
from scipy.cluster.hierarchy import linkage, dendrogram
import numpy as np
import copy 
from matplotlib import pyplot as plt

def load_data(filepath):
    data = []
    
    with open(filepath, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for i, row in enumerate(reader):
            # first 20 Pokemon in this structure
            if i > 19:
                break
            entry = dict()
            for g in row:
                # dictionaries should not include the Generation and Legendary columns
                if g != 'Generation' and g != 'Legendary':
                     entry[g] = int(row[g]) if row[g].isdigit() else row[g]
            data.append(entry)

    return data

def calculate_x_y(stats):
    x = int(stats["Attack"]) +  int(stats["Sp. Atk"]) + int(stats["Speed"])
    y = int(stats["Defense"]) + int(stats["Sp. Def"]) + int(stats["HP"]) 
    return (x, y)

def compute_vector(data):
    vector = []
    for entry in data:
        vector.append(list(calculate_x_y(entry)))
    return vector

def hac_scipy(dataset):
    print(dataset)
    a = linkage(dataset, method='single')
    fig = plt.figure(figsize=(25, 10))
    dn = dendrogram(a)
    plt.savefig('help')
    return a



def hac_1(dataset):
    z = np.zeros((len(dataset) - 1, 4))
    
    cluster_dict = dict()
    for i, data in enumerate(dataset):
        cluster_dict[i] = data

    while(len(cluster) > 1):
        min_dist = np.inf 
        min_val = None
        for val in cluster:
            for other in cluster:
                #print(other, val)
                if val != other:
                    dist = np.linalg.norm(np.array(val) - np.array(other))
                    if dist < min_dist:
                        min_dist = dist
                        min_val = val
                        #print(val)
        if min_val != None:
            cluster.remove(val)
            #print(cluster)
            #print(min_dist,min_val)
            cluster.remove(min_val)
            cluster.append(midpoint(val,min_val))
            #print(midpoint(val,min_val))
        print(cluster)
    return cluster

def hac(dataset):
    z = np.zeros((len(dataset) - 1, 4))
    
    clusters = []
    for i, data in enumerate(dataset):
        clusters.append([data, i, 1])

    next_index = len(clusters)
    i=0
    while len(clusters) > 1:
        min_dist = np.inf 
        min_cluster = None
        for val_a in clusters:
            for val_b in clusters:
                if val_a != val_b:
                    dist = np.linalg.norm(np.array(val_a[0]) - np.array(val_b[0]))
                    if dist < min_dist:
                        min_dist = dist
                        min_cluster = [[val_a, val_b]]
                    elif dist == min_dist:
                        min_cluster.append([val_a, val_b])
        
        #print(min_cluster)
        if len(min_cluster) == 1:
            min_cluster = min_cluster[0]
        else:
            print("woah", len(min_cluster))
            min = min_cluster[0]
            for cluster in min_cluster:
                if cluster[0][2] + cluster[1][2] < min[0][2] + min[1][2]:
                    min = cluster
            min_cluster = min

        z[i, 0] = min_cluster[0][1]
        z[i, 1] = min_cluster[1][1]
        z[i, 2] = min_dist
        z[i, 3] = min_cluster[0][2] + min_cluster[1][2]
        
        new_x = (min_cluster[0][0][0] + min_cluster[1][0][0])/2
        new_y = (min_cluster[0][0][1] + min_cluster[1][0][1])/2
        #print(min_cluster[0][0], min_cluster[1][0])
        #print(new_x, new_y)
        new_cluster = [[new_x, new_y], next_index, min_cluster[0][2] + min_cluster[1][2]]
        
        i+=1
        next_index+=1
        
        clusters.remove(min_cluster[0])
        clusters.remove(min_cluster[1])
        clusters.append(new_cluster)
        print(z)
        print()
    return z


if __name__=="__main__":
    data = load_data('Pokemon.csv')
    xy = compute_vector(data)
    print(xy)
    #print(hac(xy))
    me = hac(xy)
    fig = plt.figure(figsize=(25, 10))
    dn = dendrogram(me)
    plt.savefig('help2')
    #print(me)

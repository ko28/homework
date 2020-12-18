# Name: Daniel Ko
# Project 7, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

import csv 
import numpy as np

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

class Cluster:
    def __init__(self, points, index):
        self.points = points
        self.index = index
    
    def size(self):
        return len(self.points)


def hac(dataset):
    z = np.zeros((len(dataset) - 1, 4))
    
    clusters = []
    for i, data in enumerate(dataset):
        clusters.append(Cluster([data],i))
    
    next_index = len(clusters)
    i = 0 # keep track of which row to put data in matrix

    while len(clusters) > 1:
        min_dist = np.inf 
        min_cluster = []
        for cluster_a in clusters:
            for cluster_b in clusters:
                if cluster_a != cluster_b:
                    dist = calculate_min_dist(cluster_a, cluster_b)
                    if min_dist > dist:
                        min_dist = dist
                        min_cluster = [[cluster_a, cluster_b]]
                    elif dist == min_dist:
                        min_cluster.append([cluster_a, cluster_b])   
        if len(clusters) == 1:
            min_cluster = min_cluster[0]
        else:
            temp_min = min_cluster[0]
            min_cluster.sort(key=lambda c: c[0].index)
            for c in min_cluster:
                if calculate_min_dist(c[0], c[1]) < calculate_min_dist(temp_min[0], temp_min[1]):
                    temp_min = c
            min_cluster = temp_min

        combined_cluster = Cluster(min_cluster[0].points + min_cluster[1].points, next_index)

        z[i, 0] = min_cluster[0].index
        z[i, 1] = min_cluster[1].index
        z[i, 2] = min_dist
        z[i, 3] = combined_cluster.size()

        next_index += 1
        i += 1 

        clusters.remove(min_cluster[0])
        clusters.remove(min_cluster[1])
        clusters.append(combined_cluster)
        
    return z

def calculate_min_dist(cluster_a, cluster_b):
    min = np.inf
    for point_a in cluster_a.points:
        for point_b in cluster_b.points:
            temp_dist = np.linalg.norm(np.array(point_a) - np.array(point_b))
            if min > temp_dist:
                min = temp_dist

    return min


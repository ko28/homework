class Cluster:
    def __init__(self, points, index):
        self.points = points
        self.index = index
    
    def get_index(self):
        return self.index

    def size(self):
        return len(self.points)

import random

clusters = []
for i in range(10):
    clusters.append(Cluster([],random.randint(0,100)))


clusters = [ ]
clusters.append(Cluster([1],random.randint(0,100)))
clusters.append(Cluster([2],random.randint(0,100)))
clusters.append(Cluster([i for i in range(5)],random.randint(0,100)))
clusters.append(Cluster([i for i in range(3)],random.randint(0,100)))
clusters.append(Cluster([i for i in range(5)],random.randint(0,100)))

for c in clusters:
    print(c.index, c.size())

print(clusters)
min_cluster = clusters[0] if len(clusters) == 1 else min(sorted(clusters, key=lambda c: c.index), key=lambda c: c.size())
print(min_cluster.index, min_cluster.size())
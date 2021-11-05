import numpy as np
import os
import matplotlib.pyplot as plt

f_object = open("output/pca_feature_8.out","r")
f_object.readline()
data = []
for line in f_object:
	data.append(line.strip("\n").split(",")[1:4])
data = np.asarray(data,dtype=float)

plt.scatter(data[:,0],data[:,1])
plt.savefig("pca.png")

import numpy as np
import matplotlib.pyplot as plt

p = np.load("pred.npy")
l = np.load("label.npy")

control = np.where(l == 0)[0] 
case = np.where(l == 1)[0]

plt.hist(p[control],label="control",alpha=0.5)
plt.hist(p[case],label="case",alpha=0.5)

plt.legend()
plt.savefig("compare_pred.png")

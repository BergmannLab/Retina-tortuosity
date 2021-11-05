import numpy as np
import matplotlib.pyplot as plt

for data_label in ["train","val"]:
	p = np.load("pred_%s.npy"%(data_label,))
	l = np.load("label_%s.npy"%(data_label,))

	control = np.where(l == 0)[0] 
	case = np.where(l == 1)[0]

	num_bins=100
	plt.hist(p[control],label="control",alpha=0.5,bins=num_bins)
	plt.hist(p[case],label="case",alpha=0.5,bins=num_bins)

	plt.legend()
	plt.savefig("compare_pred_%s.png"%(data_label,))
	plt.close()

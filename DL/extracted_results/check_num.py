import os
import numpy as np

f_object = open("filenames_1.txt","r")
data = []
for line in f_object:
	data.append(line)
f_object.close()
print(len(data))

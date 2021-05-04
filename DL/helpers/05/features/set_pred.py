import numpy as np
import os

filename="output/prediction.out"
f_object = open(filename,"r")
o_object= open("output/pred_label.out","w+")
o_object.write(f_object.readline())

data = []
for line in f_object:
	dataline = line.strip("\n").split(",")
	subject_id = dataline[0]
	prediction = np.argmax([float(dataline[1]),float(dataline[2])])
	o_object.write(subject_id+","+str(prediction)+"\n")
f_object.close()
o_object.close()

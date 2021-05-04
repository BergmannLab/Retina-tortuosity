import numpy as np
import os

filename="output/prediction.out"
f_object = open(filename,"r")
f_object.readline()
o_object= open("output/pred_label.out","w+")
o_object.write("Subject ID,Prediction Value,Dataset\n")

label_file = open("output/ave_across_channel_layer0.out","r")
label_file.readline()
labels = []
for line in label_file:
	labels.append(line.strip("\n").split(",")[-1])

data = []
print(len(labels))
for idx,line in enumerate(f_object):
	print(idx,line.strip("\n"))
	continue
	dataline = line.strip("\n").split(",")
	subject_id = dataline[0]
	prediction = np.argmax([float(dataline[1]),float(dataline[2])])
	o_object.write(subject_id+","+str(prediction)+","+labels[idx]+"\n")
f_object.close()
o_object.close()

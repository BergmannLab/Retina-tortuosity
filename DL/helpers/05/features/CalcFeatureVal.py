import sys
import torch
import numpy as np
import time
import math
import os 

#feature extractoin functions
def abs_max(layer_activation):
	return [np.max(abs(layer_activation.flatten()))]

def ave(layer_activation):
	return [np.average(layer_activation.flatten())]

def flat_layer(layer_activation):
	return layer_activation.flatten()

def extract_node_value(layer_activation,node_id):
	return [layer_activation.flatten()[node_id]]

def load_node_id_list(node_file):
	n_object = open(node_file,"r")
	header = n_object.readline()

	node_id = []
	for line in n_object:
		node_id.append(int(line.strip("\n").split(",")[1]))
	return node_id

node_id = load_node_id_list("analysis/max_mean_node_intensity.csv")
selected_id = 3

output_file = open("output/node_id_test_layer_%d.out"%(node_id[selected_id],),"w+")
output_file.write("Subject ID,feature value\n")

layer_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/features/"
extracted_layers = [l for l in os.listdir(layer_dir) if "feature_0" in l]

st = time.time()
for layer_idx,layer_file in enumerate(extracted_layers):
	if layer_idx % 100 == 0:
		print(layer_idx,"processed")
	layer = np.load(layer_dir+"/"+layer_file)
        subject_id = layer_file.split("_")[0]

	feature_value = extract_node_value(layer[0][0],node_id[selected_id])[0]
        output_file.write(subject_id+","+str(feature_value)+"\n")
print("time taken :",time.time()-st)
output_file.close()

import sys
import torch
import numpy as np
import time
import math
import os 
import matplotlib.pyplot as plt
from sklearn.decomposition import pca
import pickle

#feature extractoin functions
def abs_max(layer_activation):
	return [np.max(abs(layer_activation.flatten()))]

def ave_channel(layer_activation,channel):
	return [np.average(layer_activation[channel].flatten())]

def ave_across_channels(layer_activation):
	ave_channel = []
	for layer_channel in layer_activation:
		ave_channel.append(np.average(layer_channel.flatten()))
	return [np.average(ave_channel)]

def flat_layer(layer_activation):
	return layer_activation.flatten()

def extract_node_value(layer_activation,node_id):
	return [layer_activation.flatten()[node_id]]

def extract_node_value_coord(layer_activation,node_coord):
        return [layer_activation[node_coord[0]][node_coord[1]]]

def extract_nodes_ave_channels(layer_activation):
	node_active = []
	for layer_channel in layer_activation:
		node_active.append(layer_channel.flatten())
	return np.average(node_active,axis=0)

def load_node_id_list(node_file):
	n_object = open(node_file,"r")
	header = n_object.readline()

	node_id = []
	for line in n_object:
		node_id.append(int(line.strip("\n").split(",")[1]))
	return node_id

#node_id = load_node_id_list("analysis/max_mean_node_intensity.csv")
#selected_feature = "feature_0"

layer_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/features/21_7_21"
extracted_layers = os.listdir(layer_dir)

dict_keys = list(pickle.load(open(layer_dir+"/"+extracted_layers[0],"rb")).keys())

print(dict_keys)

output_file = open("output/last_layer_node_ave_channels.csv","w+")
output_file.write(",".join(["node_"+str(i) for i in range(49)])+"\n")
for layer_file in extracted_layers:
	layer_dict = pickle.load(open(layer_dir+"/"+layer_file,"rb"))
	feature_value = layer_dict["feature_11"]
	print(feature_value.shape)

	subject_id = layer_file.split("_")[0]
	data_label = layer_file.split("_")[1]

	output_file.write(",".join(np.asarray(extract_nodes_ave_channels(feature_value[0]),dtype='str'))+"\n")

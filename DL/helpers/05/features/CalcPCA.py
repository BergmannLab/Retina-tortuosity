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
		ave_channel.append(np.average(layer_activation.flatten()))
	return [np.average(ave_channel)]

def flat_layer(layer_activation):
	return layer_activation.flatten()

def extract_node_value(layer_activation,node_id):
	return [layer_activation.flatten()[node_id]]

def extract_node_value_coord(layer_activation,node_coord):
        return [layer_activation[node_coord[0]][node_coord[1]]]

def load_node_id_list(node_file):
	n_object = open(node_file,"r")
	header = n_object.readline()

	node_id = []
	for line in n_object:
		node_id.append(int(line.strip("\n").split(",")[1]))
	return node_id

#node_id = load_node_id_list("analysis/max_mean_node_intensity.csv")
#selected_feature = "feature_0"

layer_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/features/all_images_18_8_21"
extracted_layers = os.listdir(layer_dir)

dict_keys = list(pickle.load(open(layer_dir+"/"+extracted_layers[0],"rb")).keys())

feature_header = ",".join(dict_keys)

for feature_key in dict_keys:
	st = time.time()
	pca_data = []
	subject_id_list = []
	for layer_idx,layer_file in enumerate(extracted_layers):
		if layer_idx % 100 == 0:
			print(layer_idx,"processed")
		layer_dict = pickle.load(open(layer_dir+"/"+layer_file,"rb"))
		subject_id = layer_file.split("_")[0]
		data_label = layer_file.split("_")[1]

		subject_id_list.append(subject_id)
		pca_data.append(flat_layer(layer_dict[feature_key][0][0]))
		#if layer_idx == 1000:
		#	break
		#continue
	print("time taken :",time.time()-st)
	from sklearn.decomposition import PCA
	pca_data = np.asarray(pca_data)
	pca = PCA(n_components=3)
	pca.fit(X=pca_data)
	print(pca.explained_variance_ratio_)
	output_file = open("output/pca_%s.out"%(feature_key,),"w+")
	output_file.write("Subject ID,%s,Dataset\n"%("pca1,pca2,pca3",))
	for idx,pca_value in enumerate(pca.transform(pca_data)):
		output_file.write(subject_id_list[idx]+","+",".join([str(f) for f in pca_value])+","+data_label+"\n")
	output_file.close()


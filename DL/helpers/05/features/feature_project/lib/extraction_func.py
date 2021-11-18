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
	#return [np.max(abs(layer_activation.flatten()))]
	return str(np.max(abs(layer_activation.flatten())))

def ave_channel(layer_activation,channel):
	return [np.average(layer_activation[channel].flatten())]

def ave_across_channels(layer_activation):
	ave_channel = []
	for layer_channel in layer_activation:
		ave_channel.append(np.average(layer_activation.flatten()))
	return str(np.average(ave_channel))

def flat_layer(layer_activation):
	return ",".join(np.asarray(layer_activation.flatten(),dtype="str"))

def extract_node_value(layer_activation,node_id):
	return [layer_activation.flatten()[node_id]]

def extract_node_value_coord(layer_activation,node_coord):
        return [layer_activation[node_coord[0]][node_coord[1]]]

def extract_nodes_ave_channels(layer_activation):
	node_active = []
	for layer_channel in layer_activation:
		node_active.append(layer_channel.flatten())
	return np.average(node_active,axis=0)

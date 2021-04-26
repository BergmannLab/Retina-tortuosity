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


output_file = open("ave_test.out","w+")
output_file.write("Subject ID,feature value\n")

layer_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/features/"
extracted_layers = os.listdir(layer_dir)

st = time.time()
for layer_idx,layer_file in enumerate(extracted_layers):
        layer = np.load(layer_dir+"/"+layer_file)
        subject_id = layer_file.split("_")[0]

        feature_value = ave(layer)[0]
        output_file.write(subject_id+","+str(feature_value)+"\n")
print("time taken :",time.time()-st)
output_file.close()

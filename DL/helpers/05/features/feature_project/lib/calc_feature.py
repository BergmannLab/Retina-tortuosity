import numpy as np
import time
import os
import pickle

class CalcFeature:
    def __init__(self,layer_dir,outfile,extract_func):
        self.layer_dir = layer_dir
        self.extracted_layers = os.listdir(self.layer_dir)
        self.dict_keys = list(pickle.load(open(layer_dir+"/"+extracted_layers[0],"rb")).keys())
        self.feature_header = ",".join(dict_keys)
        #write output file
        self.output_file = open(output_file,"w+")
        self.output_file.write("Subject ID,"+",".join([header for header in feature_header])+",Dataset\n")
        #set extraction function
        self.extract_func = extract_func

    def main(self,feature_idx=None):
        st = time.time()
        for layer_idx,layer_file in enumerate(self.extracted_layers):
        	if layer_idx % 100 == 0:
        		print(layer_idx,"processed")
        	layer_dict = pickle.load(open(self.layer_dir+"/"+layer_file,"rb"))
        	subject_id = layer_file.split("_")[0]
        	data_label = layer_file.split("_")[1]

        	feature_value = []
            #select the layers to calculate the feautres for
	    if feature_idx != None:
                feature_values = [self.dict_keys[i] for i in feature_idx]
            else:
                feature_values = self.dict_keys
            #calculate the features from the layers
            for f_label for self.dict_keys:
                feature_value.append(self.extract_func(self.layer_dict[f_label]))
            feature_value = np.asarray(feature_value,dtype='str')
        	self.output_file.write(subject_id+","+",".join(feature_value)+","+data_label+"\n")
        self.output_file.close()
        print("time taken :",time.time()-st)

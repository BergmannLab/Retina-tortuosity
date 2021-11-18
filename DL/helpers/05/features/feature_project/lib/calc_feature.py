import numpy as np
import time
import os
import pickle

class CalcFeature:
    def __init__(self,layer_dir,output_file,extract_func):
        self.layer_dir = layer_dir
        self.extracted_layers = os.listdir(self.layer_dir)
        self.dict_keys = list(pickle.load(open(layer_dir+"/"+self.extracted_layers[0],"rb")).keys())
        #write output file
        self.output_filename = output_file
        #set extraction function
        self.extract_func = extract_func

    def main(self,feature_idx=None):
        st = time.time()
        output_dict = {}
        
        # calculating
        calculated_idx = []
        for layer_idx,layer_file in enumerate(self.extracted_layers):
            if layer_idx % 100 == 0:
                print(layer_idx,"processed")
            if layer_idx > 200:
                break
            layer_dict = pickle.load(open(self.layer_dir+"/"+layer_file,"rb"))

            feature_value = []
            #select the layers to calculate the feautres for
            if len(feature_idx) != 0:
                feature_values = [self.dict_keys[i] for i in feature_idx]
            else:
                feature_values = self.dict_keys

            #####
            f_dict = {}
            for f_idx,f_label in enumerate(feature_values):
                f_dict[f_label] = self.extract_func(layer_dict[f_label])
            output_dict[layer_idx] = f_dict

            calculated_idx.append(layer_idx)

        for f_idx,f_label in enumerate(feature_values):
            output_file = open(self.output_filename+"_"+self.extract_func.__name__+"_"+f_label+".out","w+")
            output_file.write("Subject ID,Data Label,features\n")
            for layer_idx in calculated_idx:
                subject_id = self.extracted_layers[layer_idx].split("_")[0]
                data_label = self.extracted_layers[layer_idx].split("_")[1]
                output_file.write(subject_id+","+data_label+","+output_dict[layer_idx][f_label]+"\n")
            output_file.close()
        print("time taken :",time.time()-st)

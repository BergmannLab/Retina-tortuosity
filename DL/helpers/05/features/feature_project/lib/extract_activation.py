import sys
import torch
from torch import nn
from torch.utils.data import DataLoader
from torchvision import transforms
from torchvision.models import DenseNet
import numpy as np
from tensorboardX import SummaryWriter
import time
import math
import tables
from sklearn.metrics import confusion_matrix
from sklearn.metrics import roc_curve, auc
from matplotlib.ticker import MaxNLocator
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import pickle
import sys
sys.path.insert(1, '../')
from TrainDL import TrainParameters,ImageProcess,Dataset

from load_model import LoadModel

class ExtractActive:
    def __init__(self,model_dict,train_path,val_path):
        self.activation = {}
        self.Model = LoadModel()
        self.Model.load_model(model_dict)
        self.Model.set_transform(train_path,val_path)

    def get_activation(self,name):
    	def hook(model, input, output):
    		self.activation[name] = output.detach()
    	return hook

    def load_data(self,data_path):
        #load patient ids
        pytables_data = tables.open_file(data_path,'r')
        patient_id = pytables_data.root.filenames.read()
        pytables_data.close()

        p_id = []
        for index in range(len(patient_id)):
        	if b"_21015" in patient_id[index] and b"_bin_seg" in patient_id[index]:
        		p_id.append(True)
        	else:
        		p_id.append(False)
        return p_id

    def main(self,data_path,active_dir):
        p_id = self.load_data(data_path)
        dataset=Dataset(data_path, img_transform=self.Model.im_pro.norm_transform_val) #transform needs to be set to the val transform
        dataLoader=DataLoader(dataset, batch_size=1, num_workers=16, pin_memory=True)
        for i,p_bool in enumerate(p_id):
        	if p_bool == False:
        		continue
        	p_id_label = str(patient_id[i]).split("/")[-1].replace(".png","_activation.pk")
        	if i % 100 == 0:
        		print(i)
        	img_new, label, img = dataset.__getitem__(i)
        	img = img_new.unsqueeze(0) #img_new.to(device)  # [Nbatch, 3, H, W]

        	#set the features hooks to extract the layer activations
        	for f_idx,f in enumerate(self.Model.model.features):
        		f.register_forward_hook(self.get_activation(f_idx))

        	#make a prediction
        	output = self.Model.model(img)
        	pred_output = output.detach().numpy()

        	feature_value = []
        	active_dict = {}
        	for f_idx,f in enumerate(self.Model.model.features):
        		active = activation[f_idx].detach().numpy()
        		#store layer activations
        		active_dict["feature_%d"%(f_idx,)] = active
        	pickle.dump(active_dict,open(active_dir+p_id_label,"wb+"))

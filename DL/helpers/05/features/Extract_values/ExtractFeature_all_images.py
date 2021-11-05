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

#feature extractoin functions
def abs_max(layer_activation):
	return [np.max(abs(layer_activation.flatten()))]

def ave(layer_activation):
	return [np.average(layer_activation.flatten())]

def flat_layer(layer_activation):
	return layer_activation.flatten()


#set the pytorch hook
activation = {}
def get_activation(name):
	def hook(model, input, output):
		activation[name] = output.detach()
	return hook

#extract tortuosity ID list
def extract_id(id_filename):
	f_object = open(id_filename,"r")
	id_list = []
	for line in f_object:
		id_list.append(int(line.strip("\n").split("_")[0]))
	f_object.close()
	return id_list

ID = extract_id('tort_id.csv')

#set feature_func
feature_func = flat_layer

#set train parameters
tp = TrainParameters()

device = 'cpu'#torch.device(f'cuda:{gpuid}' if torch.cuda.is_available() else 'cpu')
model = DenseNet(growth_rate=tp.growth_rate,
            block_config=tp.block_config,
            num_init_features=tp.num_init_features,
            bn_size=tp.bn_size,
            drop_rate=tp.drop_rate,
            num_classes=tp.num_classes).to(device)

# load model from state_dict
dict_path="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/05_DL/retina_densenet_best_model.pth"
state_dict = torch.load(dict_path)["model_dict"]
missing_keys = model.load_state_dict(state_dict)
model.eval()

#set image processing methods
write_header=True

train_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_train.pytable"
val_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_val.pytable"
im_pro = ImageProcess()
im_pro.set_norm_img_transform(train_path)

data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/all_images/retina_all.pytable"
#im_pro = ImageProcess()
#im_pro.set_norm_img_transform(data_path)

#load dataset
dataset=Dataset(data_path, img_transform=im_pro.norm_transform_val) #transform needs to be set to the val transform
#dataLoader=DataLoader(dataset, batch_size=1, num_workers=16, pin_memory=True)

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
	
#for ii , (img, label, img_orig) in enumerate(dataLoader):
for i,p_bool in enumerate(p_id):
	if p_bool == False:
		continue
	p_id_label = str(patient_id[i]).split("/")[-1].replace(".png","_activation.pk")
	if i % 100 == 0:
		print(i)
	img_new, label, img = dataset.__getitem__(i)
	img = img_new.unsqueeze(0) #img_new.to(device)  # [Nbatch, 3, H, W]

	#label = label.type('torch.LongTensor').to(device)  # [Nbatch, 1] with class indices (0, 1, 2,...n_classes)
	#label = label.detach().numpy()[0]

	#set the features hooks to extract the layer activations
	for f_idx,f in enumerate(model.features):
		f.register_forward_hook(get_activation(f_idx))

	#make a prediction
	output = model(img)
	pred_output = output.detach().numpy()

	feature_value = []
	active_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/features/all_images_18_8_21/"
	active_dict = {}
	for f_idx,f in enumerate(model.features):
		active = activation[f_idx].detach().numpy()
		#store layer activations	
		active_dict["feature_%d"%(f_idx,)] = active
	pickle.dump(active_dict,open(active_dir+p_id_label,"wb+"))

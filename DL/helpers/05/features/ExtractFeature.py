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

#set feature_func
feature_func = flat_layer

#set output file
output_file = open("output/all_block_layers_ave.out","w+")
pred_file = open("output/prediction.out","w+")
pred_file.write("Subject ID, Prediction Value1, Prediction Value2, Label, Dataset\n")

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
data_label_list = ["train","val"]
write_header=True

train_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_train.pytable"
val_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_val.pytable"
im_pro = ImageProcess()
im_pro.set_norm_img_transform(train_path)

for data_idx,data_label in enumerate(data_label_list):
	data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_%s.pytable"%(data_label,)
	#im_pro = ImageProcess()
	#im_pro.set_norm_img_transform(data_path)

	#load dataset
	dataset=Dataset(data_path, img_transform=im_pro.norm_transform_val) #transform needs to be set to the val transform
	dataLoader=DataLoader(dataset, batch_size=1, num_workers=16, pin_memory=True)

	#load patient ids
	pytables_data = tables.open_file(data_path,'r')
	patient_id = pytables_data.root.filenames.read()
	pytables_data.close()

	#set index
	index=0
	for ii , (img, label, img_orig) in enumerate(dataLoader):	
		if ii % 100 == 0:
			print(ii)
		img = img.to(device)  # [Nbatch, 3, H, W]
		label = label.type('torch.LongTensor').to(device)  # [Nbatch, 1] with class indices (0, 1, 2,...n_classes)
		label = label.detach().numpy()[0]
		p_id = str(patient_id[index]).split("/")[-1].split("_")[0]

		index += 1

		#set the features hooks to extract the layer activations
		for f_idx,f in enumerate(model.features):
			f.register_forward_hook(get_activation(f_idx))

		#make a prediction
		output = model(img)
		pred_output = output.detach().numpy()
		pred_file.write(str(p_id)+","+str(pred_output[0][0])+","+str(pred_output[0][1])+","+str(label)+","+data_label+"\n")

		feature_value = []
		active_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/features/21_7_21/"
		active_dict = {}
		for f_idx,f in enumerate(model.features):
			active = activation[f_idx].detach().numpy()
			#store layer activations	
			active_dict["feature_%d"%(f_idx,)] = active		
			#np.save(active_dir+str(p_id)+"_"+data_label+"_feature_"+str(f_idx)+"_activation.npy",active)
			#save images of the features for the first sample
			if index == 0:
				plt.imshow(active[0][0])
				plt.savefig("img/feature%d_dataset_%s.png"%(f_idx,data_label))
				plt.close()
		pickle.dump(active_dict,open(active_dir+str(p_id)+"_"+data_label+"_activation.pk","wb+"))
output_file.close()
pred_file.close()

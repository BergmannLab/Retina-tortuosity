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

import sys
sys.path.insert(1, '../')
from TrainDL import TrainParameters,ImageProcess,Dataset

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
model.load_state_dict(state_dict)
model.eval()

#set image processing methods
write_header=True

train_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_train.pytable"
im_pro = ImageProcess()
im_pro.set_norm_img_transform(train_path)

#load dataset
data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/all_images/retina_all.pytable"
dataset=Dataset(data_path, img_transform=im_pro.norm_transform_val) # use "val" because we are testing and do not want data augmentation
dataLoader=DataLoader(dataset, batch_size=1, num_workers=16, pin_memory=True)

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

data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_train.pytable"
pytables_data = tables.open_file(data_path,'r')
train_id = pytables_data.root.filenames.read()
pytables_data.close()

data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_val.pytable"
pytables_data = tables.open_file(data_path,'r')
val_id = pytables_data.root.filenames.read()
pytables_data.close()

def get_id_num(table):
	t_id_list = []
	for t_id in table:
		t_id_list.append(int(t_id.split(b"/")[-1].split(b"_")[0]))
	return t_id_list

dl_id = np.concatenate([get_id_num(train_id),get_id_num(val_id)])

overlap_id = np.in1d(get_id_num(patient_id),dl_id,invert=False)

prediction_val = []
correct_val = []
image_id = []

data_label = "all_tort"

for i,p_bool in enumerate(p_id):
	if p_bool == False:
		continue
	if overlap_id[i]:
		continue
	if i % 100 == 0:
		print(i)
	img_new, label, img = dataset.__getitem__(i)
	img = img_new.unsqueeze(0) #img_new.to(device)  # [Nbatch, 3, H, W]

	#label = label.type('torch.LongTensor').to(device)  # [Nbatch, 1] with class indices (0, 1, 2,...n_classes)
	#label = label.detach().numpy()[0]

	#make a prediction
	prediction = model(img)  # [N, Nclass]

	#compute confusion matrix
	p=prediction.detach().cpu().numpy()
	#prediction_val += p[:,0].flatten().tolist()[0]
	prediction_val.append(p[:,0][0])
	correct_val.append(label)
	image_id.append(patient_id[i])

correct_val = np.asarray(correct_val,dtype=int)
prediction_val = np.asarray(prediction_val,dtype=float)
image_id = np.asarray(image_id,dtype=str)

#log values
np.save("pred_%s.npy"%(data_label,),prediction_val)
np.save("label_%s.npy"%(data_label,),correct_val)
np.save("image_id_%s.npy"%(data_label,),image_id)
fpr, tpr, thresholds = roc_curve(correct_val, prediction_val,pos_label=0) # hyperclass = 0
roc_auc = auc(fpr, tpr)

plt.figure(figsize=(7, 7))

plt.plot(fpr, tpr, color='darkorange', lw=2, label='ROC curve (area = %0.2f)' % roc_auc)
plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC curve')
plt.legend(loc="lower right")
plt.savefig("roc_"+data_label+".png")
plt.close()

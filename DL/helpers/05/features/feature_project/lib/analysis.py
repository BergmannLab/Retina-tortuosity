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

class Analysis:
    def __init__(self,model_dict,train_path,val_path):
        self.Model = LoadModel()
        self.Model.load_model(model_dict)
        self.Model.set_transform(train_path,val_path)


#set image processing methods
data_label_list = ["train","val"]
write_header=True

train_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_train.pytable"
im_pro = ImageProcess()
im_pro.set_norm_img_transform(train_path)

for data_idx,data_label in enumerate(data_label_list):
	#load dataset
	data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_%s.pytable"%(data_label,)
	dataset=Dataset(data_path, img_transform=im_pro.norm_transform_val) # use "val" because we are testing and do not want data augmentation
	dataLoader=DataLoader(dataset, batch_size=1, num_workers=16, pin_memory=True)

	#load patient ids
	pytables_data = tables.open_file(data_path,'r')
	patient_id = pytables_data.root.filenames.read()
	pytables_data.close()

	prediction_val = []
	correct_val = []

	for ii , (img, label, img_orig) in enumerate(dataLoader):
		img = img.to(device)  # [Nbatch, 3, H, W]
		label = label.type('torch.LongTensor').to(device)  # [Nbatch, 1] with class indices (0, 1, 2,...n_classes)
		label = label.detach().numpy()[0]

		#make a prediction
		prediction = model(img)  # [N, Nclass]

		#compute confusion matrix
		p=prediction.detach().cpu().numpy()
		#prediction_val += p[:,0].flatten().tolist()[0]
		prediction_val.append(p[:,0][0])
		correct_val.append(label)

	correct_val = np.asarray(correct_val,dtype=int)
	prediction_val = np.asarray(prediction_val,dtype=float)

	#log values
	np.save("pred_%s.npy"%(data_label,),prediction_val)
	np.save("label_%s.npy"%(data_label,),correct_val)
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

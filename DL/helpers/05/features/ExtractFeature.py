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

#set train parametera
tp = TrainParameters()

device = torch.device(f'cuda:{gpuid}' if torch.cuda.is_available() else 'cpu')
D = DenseNet(growth_rate=tp.growth_rate,
            block_config=tp.block_config,
            num_init_features=tp.num_init_features,
            bn_size=tp.bn_size,
            drop_rate=tp.drop_rate,
            num_classes=tp.num_classes).to(device)

# load model from state_dict
dict_path="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/05_DL/retina_densenet_best_model.pth"
state_dict = torch.load(dict_path)["model_dict"]
missing_keys = D.load_state_dict(state_dict)

#set image processing methods
data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_train.pytable"
im_pro = ImageProcess()
im_pro.set_norm_img_transform(data_path)

#load dataset
dataset=Dataset(data_path, img_transform=im_pro.norm_transform_train)
dataLoader=DataLoader(dataset, batch_size=tp.batch_size, shuffle=True, num_workers=16, pin_memory=True)

for ii , (X, label, img_orig) in enumerate(dataLoader):
	X = X.to(device)  # [Nbatch, 3, H, W]
	label = label.type('torch.LongTensor').to(device)  # [Nbatch, 1] with class indices (0, 1, 2,...n_classes)

	#X = dataset.__getitem__(1)[0]
	#X = X.to(device)
	print(D(X))
	print(D.features(X))

#make a prediction
#print(D(X))
#print(D.features)
#print(D.features[:3])

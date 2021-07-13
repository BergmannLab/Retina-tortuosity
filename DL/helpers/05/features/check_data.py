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

data_label = "train"

data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_%s.pytable"%(data_label,)
im_pro = ImageProcess()
im_pro.set_norm_img_transform(data_path)

#load dataset
dataset=Dataset(data_path, img_transform=im_pro.norm_transform_train)
dataLoader=DataLoader(dataset, batch_size=1, num_workers=16, pin_memory=True)

#load patient ids
pytables_data = tables.open_file(data_path,'r')
patient_id = pytables_data.root.filenames.read()
pytables_data.close()

for p in patient_id:
	print(p)

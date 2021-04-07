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

n_classes= 2    #number of classes in the data mask that we'll aim to predict
in_channels= 3  #input channel of the data, RGB = 3
# --- DL params
growth_rate=6 #32
block_config=(1, 1, 1, 1) #(2, 2, 2, 2)
num_init_features=24 #64
bn_size=4
drop_rate=0
num_classes=2
# --- training params
batch_size=256#128
#patch_size=224
num_epochs = 50

device = torch.device(f'cuda:{gpuid}' if torch.cuda.is_available() else 'cpu')
D = DenseNet(growth_rate=growth_rate, block_config=block_config,num_init_features=num_init_features, bn_size=bn_size, drop_rate=drop_rate, num_classes=num_classes).to(device)

dict_path="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/05_DL/retina_densenet_best_model.pth"
state_dict = torch.load(dict_path)["model_dict"]
#D = DenseNet()
missing_keys = D.load_state_dict(state_dict)
print(D.eval())

test_path=""
D.eval(test_path)

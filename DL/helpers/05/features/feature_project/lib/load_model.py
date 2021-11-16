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

class LoadModel:
    def __init__(self):
        #set train parameters
        self.tp = TrainParameters()

    def load_model(self,dict_path):
        device = 'cpu'#torch.device(f'cuda:{gpuid}' if torch.cuda.is_available() else 'cpu')
        self.model = DenseNet(growth_rate=self.tp.growth_rate,
                    block_config=self.tp.block_config,
                    num_init_features=self.tp.num_init_features,
                    bn_size=self.tp.bn_size,
                    drop_rate=self.tp.drop_rate,
                    num_classes=self.tp.num_classes).to(device)

        # load model from state_dict
        state_dict = torch.load(dict_path)["model_dict"]
        missing_keys = self.model.load_state_dict(state_dict)
        self.model.eval()

    def set_transform(self,train_path,val_path):
        self.im_pro = ImageProcess()
        self.im_pro.set_norm_img_transform(train_path)

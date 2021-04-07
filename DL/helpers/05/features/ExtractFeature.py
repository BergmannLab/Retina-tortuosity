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

#model architecture
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

class Dataset(object):
    def __init__(self, fname ,img_transform=None):
        #nothing special here, just internalizing the constructor parameters
        self.fname=fname

        self.img_transform=img_transform

        with tables.open_file(self.fname,'r') as db:
            self.classsizes=db.root.classsizes[:]
            self.nitems=db.root.imgs.shape[0]

        self.imgs = None
        self.labels = None

    def __getitem__(self, index):
        #opening should be done in __init__ but seems to be
        #an issue with multithreading so doing here. need to do it everytime, otherwise hdf5 crashes

        with tables.open_file(self.fname,'r') as db:
            self.imgs=db.root.imgs
            self.labels=db.root.labels

            #get the requested image and mask from the pytable
            img = self.imgs[index,:,:,:]
            label = self.labels[index]


        img_new = img

        if self.img_transform is not None:
            img_new = self.img_transform(img)


        return img_new, label, img
    def __len__(self):
        return self.nitems

#image transformation
img_transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Grayscale(num_output_channels=1),
    transforms.ToTensor()
    ])

data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB"
dataset=Dataset(f"%s"%(data_path,), img_transform=img_transform)
nb_train_images = len(dataset)
pixels = np.array(torch.flatten(torch.stack([train_dataset[i][0] for i in range(nb_train_images)])))

data_mean = np.mean(pixels)
data_std = np.std(pixels)

norm_transform_train = transforms.Compose([
    transforms.ToPILImage(),
    transforms.RandomRotation(degrees=(-5, 5)),
    transforms.Grayscale(num_output_channels=3), # densenet expects 3-channel images as input (here R=G=B)
    #transforms.RandomErasing(p=0.1), # randomly selects a rectangle region in an image and erases its pixels
    transforms.ToTensor(),
    transforms.Normalize(mean=[data_mean, data_mean, data_mean], std=[data_std, data_std, data_std])
    #transforms.GaussianBlur(kernel_size=3, sigma=(0.1, 2.0))
    #transforms.RandomApply([AddGaussianNoise(0, 0.1)], p=1) # not working
    ])

norm_transform_val = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Grayscale(num_output_channels=3), # densenet expects 3-channel images as input (here R=G=B)
    transforms.ToTensor(),
    transforms.Normalize(mean=[data_mean, data_mean, data_mean], std=[data_std, data_std, data_std])
    ])

#now for each of the phases, we're creating the dataloader
#interestingly, given the batch size, i've not seen any improvements from using a num_workers>0

# We use data augmentation for training
dataset=Dataset(f"%s"%(data_path,), img_transform=norm_transform_train)
#####

device = torch.device(f'cuda:{gpuid}' if torch.cuda.is_available() else 'cpu')
D = DenseNet(growth_rate=growth_rate, block_config=block_config,num_init_features=num_init_features, bn_size=bn_size, drop_rate=drop_rate, num_classes=num_classes).to(device)

dict_path="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/05_DL/retina_densenet_best_model.pth"
state_dict = torch.load(dict_path)["model_dict"]
#D = DenseNet()
missing_keys = D.load_state_dict(state_dict)
print(D.eval())

test_path=""
D.eval(test_path)

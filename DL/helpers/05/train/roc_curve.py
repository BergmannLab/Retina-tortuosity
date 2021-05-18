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

#make a PDF with the loss and acc curves vs number of epochs
pdf = PdfPages(f"{output_dir}/Training_Curves.pdf")
fig = plt.figure(figsize=(14, 12))

# Loss curves
ax1 = fig.add_subplot(221)
ax1.plot(nb_epoch, train_loss, 'r', linewidth=3.0)
ax1.plot(nb_epoch, val_loss, 'b', linewidth=3.0)

ax1.legend(['Training loss', 'Validation Loss'],fontsize=18)
ax1.set_xlabel('Epochs',fontsize=16)
ax1.set_ylabel('Loss',fontsize=16)
ax1.set_title('Loss Curves',fontsize=16)
ax1.xaxis.set_major_locator(MaxNLocator(integer=True))

# Accuracy Curves
ax2 = fig.add_subplot(222)
ax2.plot(nb_epoch, train_acc, 'r', linewidth=3.0)
ax2.plot(nb_epoch, val_acc, 'b', linewidth=3.0)

ax2.legend(['Training Accuracy', 'Validation Accuracy'],fontsize=18)
ax2.set_xlabel('Epochs',fontsize=16)
ax2.set_ylabel('Accuracy',fontsize=16)
ax2.set_title('Accuracy Curves',fontsize=16)
ax2.xaxis.set_major_locator(MaxNLocator(integer=True))

# Sensitivity Curves
ax2 = fig.add_subplot(223)
ax2.plot(nb_epoch, train_sensitivity, 'r', linewidth=3.0)
ax2.plot(nb_epoch, val_sensitivity, 'b', linewidth=3.0)

ax2.legend(['Training Sensitivity', 'Validation Sensitivity'],fontsize=18)
ax2.set_xlabel('Epochs',fontsize=16)
ax2.set_ylabel('Sensitivity',fontsize=16)
ax2.set_title('Sensitivity Curves',fontsize=16)
ax2.xaxis.set_major_locator(MaxNLocator(integer=True))

# Specificity Curves
ax2 = fig.add_subplot(224)
ax2.plot(nb_epoch, train_specificity, 'r', linewidth=3.0)
ax2.plot(nb_epoch, val_specificity, 'b', linewidth=3.0)

ax2.legend(['Training Specificity', 'Validation Specificity'],fontsize=18)
ax2.set_xlabel('Epochs',fontsize=16)
ax2.set_ylabel('Specificity',fontsize=16)
ax2.set_title('Specificity Curves',fontsize=16)
ax2.xaxis.set_major_locator(MaxNLocator(integer=True))

pdf.savefig()
pdf.close()

def main():
    db_dir = sys.argv[1]
    gpuid = sys.argv[2];
    output_dir = sys.argv[3];
    TrainDL(db_dir, gpuid, output_dir)
    print("done")

if __name__== "__main__":
    main()

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
import os

class AddGaussianNoise(object):
    def __init__(self, mean=0., std=1.):
        self.std = std
        self.mean = mean

    def __call__(self, tensor):
        return tensor + torch.randn(tensor.size()) * self.std + self.mean

    def __repr__(self):
        return self.__class__.__name__ + '(mean={0}, std={1})'.format(self.mean, self.std)

#this defines our dataset class which will be used by the dataloader
class Dataset(object):
    def __init__(self, fname ,img_transform=None):
        #nothing special here, just internalizing the constructor parameters
        self.fname=fname
        self.img_transform=img_transform
        num_file = len([l for l in os.listdir("./") if "filenames" in l])
        self.f_object = open("filenames_%d.txt"%(num_file+1,),"w+")

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

            #filename
            filename = db.root.filenames.read()[index]
            print(filename)
            self.f_object.write(str(filename)+"\n")

        img_new = img

        if self.img_transform is not None:
            img_new = self.img_transform(img)

        return img_new, label, img

    def __len__(self):
        return self.nitems

class TrainParameters:
    '''
    The parameters we moved to their own class to enable for easy access
    '''
    def __init__(self):
        #these parameters get fed directly into the densenet class, and more description of them can be discovered there
        self.n_classes= 2    #number of classes in the data mask that we'll aim to predict
        self.in_channels= 3  #input channel of the data, RGB = 3
        # --- DL params
        self.growth_rate=6 #32
        self.block_config=(1, 1, 1, 1) #(2, 2, 2, 2)
        self.num_init_features=24 #64
        self.bn_size=4
        self.drop_rate=0
        self.num_classes=2
        # --- training params
        self.batch_size=128
        #patch_size=224
        self.num_epochs = 50
        self.phases = ["train", "val"] #how many phases did we create databases for?
        #when should we do validation? note that validation is *very* time consuming, so as opposed to doing for both training and validation, we do it only for validation at the end of the epoch
        #additionally, using simply [], will skip validation entirely, drastically speeding things up
        self.validation_phases= ["val"]

class ImageProcess:
    def __init__(self):
        self.img_transform = None
        self.norm_transform_train = None
        self.norm_transform_val = None

    def set_img_transform(self):
        self.img_transform = transforms.Compose([
            transforms.ToPILImage(),
            transforms.Grayscale(num_output_channels=1),
            transforms.ToTensor()
            ])

        #     img_transform = transforms.Compose([
        #        transforms.ToPILImage(),
        #        transforms.RandomVerticalFlip(),
        #        transforms.RandomHorizontalFlip(),
        #        transforms.RandomCrop(size=(patch_size,patch_size),pad_if_needed=True),
        #        transforms.RandomResizedCrop(size=patch_size),
        #        transforms.RandomRotation(180),
        #        transforms.ColorJitter(brightness=0, contrast=0, saturation=0, hue=.5),
        #        transforms.RandomGrayscale(),
        #        transforms.ToTensor()
        #        ])
    def set_norm_img_transform(self,train_data_path):
        self.set_img_transform()
        train_dataset = Dataset(train_data_path, img_transform=self.img_transform)
        nb_train_images = len(train_dataset)

        pixels = np.array(torch.flatten(torch.stack([train_dataset[i][0] for i in range(nb_train_images)])))

        data_mean = np.mean(pixels)
        data_std = np.std(pixels)

        self.norm_transform_train = transforms.Compose([
            transforms.ToPILImage(),
            transforms.RandomRotation(degrees=(-5, 5)),
            transforms.Grayscale(num_output_channels=3), # densenet expects 3-channel images as input (here R=G=B)
            #transforms.RandomErasing(p=0.1), # randomly selects a rectangle region in an image and erases its pixels
            transforms.ToTensor(),
            transforms.Normalize(mean=[data_mean, data_mean, data_mean], std=[data_std, data_std, data_std])
            #transforms.GaussianBlur(kernel_size=3, sigma=(0.1, 2.0))
            #transforms.RandomApply([AddGaussianNoise(0, 0.1)], p=1) # not working
            ])

        self.norm_transform_val = transforms.Compose([
            transforms.ToPILImage(),
            transforms.Grayscale(num_output_channels=3), # densenet expects 3-channel images as input (here R=G=B)
            transforms.ToTensor(),
            transforms.Normalize(mean=[data_mean, data_mean, data_mean], std=[data_std, data_std, data_std])
            ])

def TrainDL(db_dir, gpuid, output_dir):
    dataname="retina"
    # --- densenet params
    tp = TrainParameters()
    #these parameters get fed directly into the densenet class, and more description of them can be discovered there
    n_classes= tp.n_classes   #number of classes in the data mask that we'll aim to predict
    in_channels= tp.in_channels  #input channel of the data, RGB = 3
    # --- DL params
    growth_rate=tp.growth_rate #32
    block_config=tp.block_config #(2, 2, 2, 2)
    num_init_features=tp.num_init_features #64
    bn_size=tp.bn_size
    drop_rate=tp.drop_rate
    num_classes=tp.num_classes
    # --- training params
    batch_size=tp.batch_size
    #patch_size=224
    num_epochs = tp.num_epochs
    phases = tp.phases #how many phases did we create databases for?
    #when should we do validation? note that validation is *very* time consuming, so as opposed to doing for both training and validation, we do it only for validation at the end of the epoch
    #additionally, using simply [], will skip validation entirely, drastically speeding things up
    validation_phases= tp.validation_phases

    def asMinutes(s):
        m = math.floor(s / 60)
        s -= m * 60
        return '%dm %ds' % (m, s)
    def timeSince(since):
        now = time.time()
        s = now - since
        return '%s' % (asMinutes(s))

    #torch.cuda.set_device(gpuid) #jupyter
    #device = torch.device(f'cuda:{gpuid}' if torch.cuda.is_available() else 'cpu') #jupyter
    #torch.cuda.set_device("cpu")
    device = torch.device(f'cuda:{gpuid}' if torch.cuda.is_available() else 'cpu')

    #print(torch.cuda.get_device_properties(device))
    print(device)

    #build the model according to the paramters specified above and copy it to the GPU. finally print out the number of trainable parameters
    model = DenseNet(growth_rate=growth_rate, block_config=block_config,
                     num_init_features=num_init_features, bn_size=bn_size, drop_rate=drop_rate, num_classes=num_classes).to(device)
    print(f"total params: \t{sum([np.prod(p.size()) for p in model.parameters()])}")

    image_process = ImageProcess()
    #set normal image process
    train_data_path = f"{db_dir}/{dataname}_"+"train"+".pytable"
    image_process.set_norm_img_transform(train_data_path)

    dataset={}
    dataLoader={}
    #now for each of the phases, we're creating the dataloader
    #interestingly, given the batch size, i've not seen any improvements from using a num_workers>0

    # We use data augmentation for training
    phase = "train"
    dataset[phase]=Dataset(f"{db_dir}/{dataname}_{phase}.pytable", img_transform=image_process.norm_transform_train)
    dataLoader[phase]=DataLoader(dataset[phase], batch_size=batch_size, shuffle=True, num_workers=16, pin_memory=True)
    print(f"{phase} dataset size:\t{len(dataset[phase])}")

    # We only normalize the validation dataset
    phase = "val"
    dataset[phase]=Dataset(f"{db_dir}/{dataname}_{phase}.pytable", img_transform=image_process.norm_transform_val)
    dataLoader[phase]=DataLoader(dataset[phase], batch_size=batch_size, shuffle=True, num_workers=16, pin_memory=True)
    print(f"{phase} dataset size:\t{len(dataset[phase])}")

    optim = torch.optim.Adam(model.parameters()) #adam is going to be the most robust, though perhaps not the best performing, typically a good place to start
    nclasses = dataset["train"].classsizes.shape[0]
    class_weight=dataset["train"].classsizes
    class_weight = torch.from_numpy(1-class_weight/class_weight.sum()).type('torch.FloatTensor').to(device)
    print(class_weight)
    print(class_weight) #show final used weights, make sure that they're reasonable before continouing
    criterion = nn.CrossEntropyLoss(weight = class_weight)

    def trainnetwork():
        writer=SummaryWriter() #open the tensorboard visualiser
        best_loss_on_test = np.Infinity

        nb_epoch = []
        train_loss = []
        val_loss = []
        train_acc = []
        val_acc = []
        train_sensitivity = []
        val_sensitivity = []
        train_specificity = []
        val_specificity = []

        for epoch in range(num_epochs):
            start_time = time.time()
            #zero out epoch based performance variables
            sensitivity = {key: 0 for key in phases}
            specificity = {key: 0 for key in phases}
            all_acc = {key: 0 for key in phases}
            all_loss = {key: torch.zeros(0).to(device) for key in phases} #keep this on GPU for greatly improved performance
            cmatrix = {key: np.zeros((n_classes,n_classes)) for key in phases}
            prediction_val = []
            correct_val = []
            filename_list = [] #ALEX BUTTON

            for phase in phases: #iterate through both training and validation states

                if phase == 'train':
                    model.train()  # Set model to training mode
                else: #when in eval mode, we don't want parameters to be updated
                    model.eval()   # Set model to evaluate mode

                for ii , (X, label, img_orig) in enumerate(dataLoader[phase]): #for each of the batches
                    X = X.to(device)  # [Nbatch, 3, H, W]
                    label = label.type('torch.LongTensor').to(device)  # [Nbatch, 1] with class indices (0, 1, 2,...n_classes)
                    with torch.set_grad_enabled(phase == 'train'): #dynamically set gradient computation, in case of validation, this isn't needed
                                                                    #disabling is good practice and improves inference time

                        prediction = model(X)  # [N, Nclass]
                        loss = criterion(prediction, label)


                        if phase=="train": #in case we're in train mode, need to do back propogation
                            optim.zero_grad()
                            loss.backward()
                            optim.step()
                            #train_loss = loss


                        all_loss[phase]=torch.cat((all_loss[phase],loss.detach().view(1,-1)))

                        #compute confusion matrix
                        p=prediction.detach().cpu().numpy()
                        cpredflat=np.argmax(p,axis=1).flatten()
                        yflat=label.cpu().numpy().flatten()

                        cmatrix[phase]=cmatrix[phase]+confusion_matrix(yflat,cpredflat, labels=range(nclasses))

                        if phase == "val":
                            prediction_val += p[:,0].flatten().tolist()
                            correct_val += yflat.tolist()

                cmatrix[phase]=np.asarray(cmatrix[phase])
                all_acc[phase]=(cmatrix[phase]/cmatrix[phase].sum()).trace()
                all_loss[phase] = all_loss[phase].cpu().numpy().mean()

                tn, fp, fn, tp = cmatrix[phase].ravel()
                sensitivity[phase] = tp/(tp+fn)
                specificity[phase] = tn/(tn+fp)

                #save metrics to tensorboard
                writer.add_scalar(f'{phase}/loss', all_loss[phase], epoch)
                if phase in validation_phases:
                    writer.add_scalar(f'{phase}/acc', all_acc[phase], epoch)
                    for r in range(nclasses):
                        for c in range(nclasses): #essentially write out confusion matrix
                            writer.add_scalar(f'{phase}/{r}{c}', cmatrix[phase][r][c],epoch)

            print('Epoch [%d/%d] - time_epoch %s - train_loss: %.4f - train_acc: %.4f - val_loss: %.4f - val_acc: %.4f' % (epoch+1, num_epochs, timeSince(start_time), all_loss["train"], all_acc["train"], all_loss["val"], all_acc["val"]), end='')

            nb_epoch.append(epoch+1)
            train_loss.append(all_loss["train"])
            val_loss.append(all_loss["val"])
            train_acc.append(all_acc["train"])
            val_acc.append(all_acc["val"])
            train_sensitivity.append(sensitivity["train"])
            val_sensitivity.append(sensitivity["val"])
            train_specificity.append(specificity["train"])
            val_specificity.append(specificity["val"])

            #if current loss is the best we've seen, save model state with all variables
            #necessary for recreation
            if (phase == "val") and (all_loss["val"] < best_loss_on_test):
                best_loss_on_test = all_loss["val"]
                print("  **")
                state = {'epoch': epoch + 1,
                 'model_dict': model.state_dict(),
                 'optim_dict': optim.state_dict(),
                 'best_loss_on_test': all_loss,
                 'n_classes': n_classes,
                 'in_channels': in_channels,
                 'growth_rate':growth_rate,
                 'block_config':block_config,
                 'num_init_features':num_init_features,
                 'bn_size':bn_size,
                 'drop_rate':drop_rate,
                 'num_classes':num_classes}

                torch.save(state, f"{output_dir}/{dataname}_densenet_best_model.pth")

                #save output to check results - ALEX BUTTON
                check_out = open("results_ab.csv","w+")
                check_out.write("image name,label,predictive value\n")
                for image_idx,image_fname in enumerate(filename_list):
                    check_out.write(image_fname+","+str(correct_val[image_idx])+","+str(prediction_val[image_idx])+"\n")

                check_out.close()

                fpr, tpr, thresholds = roc_curve(correct_val, prediction_val, pos_label=0) # hyperclass = 0
                roc_auc = auc(fpr, tpr)

                pdf = PdfPages(f"{output_dir}/ROC_Curve.pdf")
                plt.figure(figsize=(7, 7))

                plt.plot(fpr, tpr, color='darkorange', lw=2, label='ROC curve (area = %0.2f)' % roc_auc)
                plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
                plt.xlim([0.0, 1.0])
                plt.ylim([0.0, 1.05])
                plt.xlabel('False Positive Rate')
                plt.ylabel('True Positive Rate')
                plt.title('ROC curve over a batch for model at epoch = '+str(epoch+1))
                plt.legend(loc="lower right")

                pdf.savefig()
                pdf.close()

            else:
                print("")

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

    # EXECUTE TRAINING
    trainnetwork()


def main():
    db_dir = sys.argv[1]
    gpuid = sys.argv[2];
    output_dir = sys.argv[3];
    TrainDL(db_dir, gpuid, output_dir)
    print("done")

if __name__== "__main__":
    main()

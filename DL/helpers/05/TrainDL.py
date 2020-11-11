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

#this defines our dataset class which will be used by the dataloader
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



def TrainDL(db_dir, gpuid, output_dir):
    dataname="retina"
    # --- densenet params
    #these parameters get fed directly into the densenet class, and more description of them can be discovered there
    n_classes= 2    #number of classes in the data mask that we'll aim to predict
    in_channels= 3  #input channel of the data, RGB = 3
    # --- DL params
    growth_rate=32
    block_config=(2, 2, 2, 2)
    num_init_features=64
    bn_size=4
    drop_rate=0
    num_classes=2
    # --- training params
    batch_size=1024 #128
    patch_size=224 #currently, this needs to be 224 due to densenet architecture
    num_epochs = 4
    phases = ["train", "val"] #how many phases did we create databases for?
    #when should we do validation? note that validation is *very* time consuming, so as opposed to doing for both training and validation, we do it only for validation at the end of the epoch
    #additionally, using simply [], will skip validation entirely, drastically speeding things up
    validation_phases= ["val"]

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

    img_transform = transforms.Compose([
        transforms.ToPILImage(),
        transforms.RandomVerticalFlip(),
        transforms.RandomHorizontalFlip(),
        transforms.RandomCrop(size=(patch_size,patch_size),pad_if_needed=True),
        transforms.RandomResizedCrop(size=patch_size),
        transforms.RandomRotation(180),
        transforms.ColorJitter(brightness=0, contrast=0, saturation=0, hue=.5),
        transforms.RandomGrayscale(),
        transforms.ToTensor()
        ])

    dataset={}
    dataLoader={}
    for phase in phases: #now for each of the phases, we're creating the dataloader
                         #interestingly, given the batch size, i've not seen any improvements from using a num_workers>0

        dataset[phase]=Dataset(f"{db_dir}/{dataname}_{phase}.pytable", img_transform=img_transform)
        dataLoader[phase]=DataLoader(dataset[phase], batch_size=batch_size,
                                    shuffle=True, num_workers=8,pin_memory=True)
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

        for epoch in range(num_epochs):
            start_time = time.time()
            #zero out epoch based performance variables
            all_acc = {key: 0 for key in phases}
            all_loss = {key: torch.zeros(0).to(device) for key in phases} #keep this on GPU for greatly improved performance
            cmatrix = {key: np.zeros((n_classes,n_classes)) for key in phases}

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
                            train_loss = loss


                        all_loss[phase]=torch.cat((all_loss[phase],loss.detach().view(1,-1)))

                        #if phase in validation_phases: #if this phase is part of validation, compute confusion matrix
                        p=prediction.detach().cpu().numpy()
                        cpredflat=np.argmax(p,axis=1).flatten()
                        yflat=label.cpu().numpy().flatten()

                        cmatrix[phase]=cmatrix[phase]+confusion_matrix(yflat,cpredflat, labels=range(nclasses))

                cmatrix[phase]=np.asarray(cmatrix[phase])
                all_acc[phase]=(cmatrix[phase]/cmatrix[phase].sum()).trace()
                all_loss[phase] = all_loss[phase].cpu().numpy().mean()

                #save metrics to tensorboard
                writer.add_scalar(f'{phase}/loss', all_loss[phase], epoch)
                if phase in validation_phases:
                    writer.add_scalar(f'{phase}/acc', all_acc[phase], epoch)
                    for r in range(nclasses):
                        for c in range(nclasses): #essentially write out confusion matrix
                            writer.add_scalar(f'{phase}/{r}{c}', cmatrix[phase][r][c],epoch)

            print('Epoch [%d/%d] - time_epoch %s - train_loss: %.4f - train_acc: %.4f - val_loss: %.4f - val_acc: %.4f' % (epoch+1, num_epochs, timeSince(start_time), all_loss["train"], all_acc["train"], all_loss["val"], all_acc["val"]))

            #if current loss is the best we've seen, save model state with all variables
            #necessary for recreation
            if all_loss["val"] < best_loss_on_test:
                best_loss_on_test = all_loss["val"]
                #print("  **")
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
            else:
                print("")

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



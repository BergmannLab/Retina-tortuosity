import os
import tables
import sys
import PIL.Image
import numpy as np
import cv2
from sklearn import model_selection
import sklearn.feature_extraction.image
import random
import glob

def loadImages(images_dir):
    files = glob.glob(images_dir+'*.png')
    return files;

def buildDB(normal_dir, hypertense_dir, output_dir):
    dataname="retina"
    #patch_size=256 #size of the tiles to extract and save in the database, must be >= to training size
    #stride_size=256 #distance to skip between patches, 1 indicated pixel wise extraction, patch_size would result in non-overlapping tiles
    #mirror_pad_size=128 # number of pixels to pad *after* resize to image with by mirroring (edge's of patches tend not to be analyzed well, so padding allows them to appear more centered in the patch)
    test_set_size=.1 # what percentage of the dataset should be used as a held out validation/testing set
    #resize=1 #resize input images
    class_names=["hypertense", "normal"]#what classes we expect to have in the data, here we have only 2 classes but we could add additional classes

    seed = random.randrange(sys.maxsize) #get a random seed so that we can reproducibly do the cross validation setup
    random.seed(seed) # set the seed
    print(f"random seed (note down for reproducibility): {seed}")

    img_dtype = tables.UInt8Atom()  # dtype in which the images will be saved, this indicates that images will be saved as unsigned int 8 bit, i.e., [0,255]
    filenameAtom = tables.StringAtom(itemsize=255) #create an atom to store the filename of the image, just incase we need it later
    files_normal = loadImages(normal_dir)
    files_hypertense = loadImages(hypertense_dir)

    #create training and validation stages and split the files appropriately between them
    phases_normal={}
    phases_normal["train"],phases_normal["val"]=next(iter(model_selection.ShuffleSplit(n_splits=1,test_size=test_set_size).split(files_normal)))

    phases_hypertense={}
    phases_hypertense["train"],phases_hypertense["val"]=next(iter(model_selection.ShuffleSplit(n_splits=1,test_size=test_set_size).split(files_hypertense)))

    storage={} #holder for future pytables
    block_shape=np.array((224, 224, 3))
    #block_shape=np.array((patch_size,patch_size,3)) #block shape specifies what we'll be saving into the pytable array, here we assume that masks are 1d and images are 3d
    filters=tables.Filters(complevel=6, complib='zlib') #we can also specify filters, such as compression, to improve storage speed

    for phase in ["train", "val"]: #now for each of the phases, we'll loop through the files
        print(phase)

        totals=np.zeros(len(class_names)) # we can to keep counts of all the classes in for in particular training, since we

        hdf5_file = tables.open_file(f"{output_dir}/{dataname}_{phase}.pytable", mode='w') #open the respective pytable
        storage["filenames"] = hdf5_file.create_earray(hdf5_file.root, 'filenames', filenameAtom, (0,)) #create the array for storage

        storage["imgs"]= hdf5_file.create_earray(hdf5_file.root, "imgs", img_dtype,
                                                  shape=np.append([0],block_shape),
                                                  chunkshape=np.append([1],block_shape),
                                                  filters=filters)
        storage["labels"]= hdf5_file.create_earray(hdf5_file.root, "labels", img_dtype,
                                                  shape=[0],
                                                  chunkshape=[1],
                                                  filters=filters)


        for filei in phases_normal[phase]: #now for each of the files
            fname=files_normal[filei]

            classid = 1 # normal class

            totals[classid]+=1

            io=cv2.cvtColor(cv2.imread(fname),cv2.COLOR_BGR2RGB)
            interp_method=PIL.Image.BICUBIC

            # resize the image to the maximum input size 224x224 of the densenet used in the Deep Learning code
            io = cv2.resize(io, dsize=(224, 224), interpolation=interp_method)
            #io = cv2.resize(io,(0,0),fx=resize,fy=resize, interpolation=interp_method) #resize it as specified above
            #io = np.pad(io, [(mirror_pad_size, mirror_pad_size), (mirror_pad_size, mirror_pad_size), (0, 0)], mode="reflect")

            #convert input image into overlapping tiles, size is ntiler x ntilec x 1 x patch_size x patch_size x3
            #io_arr_out=sklearn.feature_extraction.image.extract_patches(io,(patch_size,patch_size,3),stride_size)

            #resize it into a ntile x patch_size x patch_size x 3
            #io_arr_out=io_arr_out.reshape(-1,patch_size,patch_size,3)

            storage["imgs"].append([io])
            storage["labels"].append([classid]) #add the filename to the storage array
            storage["filenames"].append([fname]) #add the filename to the storage array

            #storage["imgs"].append(io_arr_out)
            #storage["labels"].append([classid for x in range(io_arr_out.shape[0])]) #add the filename to the storage array
            #storage["filenames"].append([fname for x in range(io_arr_out.shape[0])]) #add the filename to the storage array


        for filei in phases_hypertense[phase]: #now for each of the files
            fname=files_hypertense[filei]

            classid = 0 # hypertense class

            totals[classid]+=1

            io=cv2.cvtColor(cv2.imread(fname),cv2.COLOR_BGR2RGB)
            interp_method=PIL.Image.BICUBIC

            # resize the image to the maximum input size 224x224 of the densenet used in the Deep Learning code
            io = cv2.resize(io, dsize=(224, 224), interpolation=interp_method)
            #io = cv2.resize(io,(0,0),fx=resize,fy=resize, interpolation=interp_method) #resize it as specified above
            #io = np.pad(io, [(mirror_pad_size, mirror_pad_size), (mirror_pad_size, mirror_pad_size), (0, 0)], mode="reflect")

            #convert input image into overlapping tiles, size is ntiler x ntilec x 1 x patch_size x patch_size x3
            #io_arr_out=sklearn.feature_extraction.image.extract_patches(io,(patch_size,patch_size,3),stride_size)

            #resize it into a ntile x patch_size x patch_size x 3
            #io_arr_out=io_arr_out.reshape(-1,patch_size,patch_size,3)

            storage["imgs"].append([io])
            storage["labels"].append([classid]) #add the filename to the storage array
            storage["filenames"].append([fname]) #add the filename to the storage array

            #storage["imgs"].append(io_arr_out)
            #storage["labels"].append([classid for x in range(io_arr_out.shape[0])]) #add the filename to the storage array
            #storage["filenames"].append([fname for x in range(io_arr_out.shape[0])]) #add the filename to the storage array

        #lastely, we should store the number of pixels
        npixels=hdf5_file.create_carray(hdf5_file.root, 'classsizes', tables.Atom.from_dtype(totals.dtype), totals.shape)
        npixels[:]=totals
        hdf5_file.close()

def main():
    normal_dir = sys.argv[1];
    hypertense_dir = sys.argv[2];
    output_dir = sys.argv[3];
    buildDB(normal_dir, hypertense_dir, output_dir)
    print("done")

if __name__== "__main__":
    main()



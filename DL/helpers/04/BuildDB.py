import os
import tables
import sys
import PIL
from PIL import Image
import numpy as np
import cv2
from sklearn import model_selection
import sklearn.feature_extraction.image
import random
import pandas as pd

def loadImages(images_dir, input_list):
    # import names of high quality images
    df = pd.read_csv(input_list); df.columns = ['file_name']
    df['file_name'] = images_dir + df['file_name'].astype(str) + ".png" # add full path
    files = df.values.flatten().tolist()
    return files;

def loadPhenotypes(pheno_file):
    # import phenotypes file
    df = pd.read_csv(pheno_file)
    return df

# determine classid (classification label, i.e., hypertense or normal)
# by looking up SBP for eid (UKBiob id) in phenotypes
# (encoding classid:0->"hypertense", classid:1->"normal")
def setClassIdFromPheno(eid, phenotypes):
    participant_record = phenotypes[phenotypes['eid'] == eid]
    DBP_biobankUID="4079-0.0"
    SBP_biobankUID="4080-0.0"
    DBP = participant_record[DBP_biobankUID].values[0]
    SBP = participant_record[SBP_biobankUID].values[0]
    hypertense = (DBP>100 or SBP>160)
    if hypertense: return 0 #classid:0->"hypertense"
    else: return 1 #classid:1->"normal"

def buildDB(images_dir, input_list, pheno_file, output_dir):
    dataname="retina"
    patch_size=256 #size of the tiles to extract and save in the database, must be >= to training size
    stride_size=256 #distance to skip between patches, 1 indicated pixel wise extraction, patch_size would result in non-overlapping tiles
    mirror_pad_size=128 # number of pixels to pad *after* resize to image with by mirroring (edge's of patches tend not to be analyzed well, so padding allows them to appear more centered in the patch)
    test_set_size=.1 # what percentage of the dataset should be used as a held out validation/testing set
    resize=1 #resize input images
    class_names=["hypertense", "normal"]#what classes we expect to have in the data, here we have only 2 classes but we could add additional classes

    seed = random.randrange(sys.maxsize) #get a random seed so that we can reproducibly do the cross validation setup
    random.seed(seed) # set the seed
    print(f"random seed (note down for reproducibility): {seed}")

    img_dtype = tables.UInt8Atom()  # dtype in which the images will be saved, this indicates that images will be saved as unsigned int 8 bit, i.e., [0,255]
    filenameAtom = tables.StringAtom(itemsize=255) #create an atom to store the filename of the image, just incase we need it later
    files = loadImages(images_dir, input_list)

    phenotypes = loadPhenotypes(pheno_file)

    #create training and validation stages and split the files appropriately between them
    phases={}
    phases["train"],phases["val"]=next(iter(model_selection.ShuffleSplit(n_splits=1,test_size=test_set_size).split(files)))

    storage={} #holder for future pytables
    block_shape=np.array((patch_size,patch_size,3)) #block shape specifies what we'll be saving into the pytable array, here we assume that masks are 1d and images are 3d
    filters=tables.Filters(complevel=6, complib='zlib') #we can also specify filters, such as compression, to improve storage speed

    for phase in phases.keys(): #now for each of the phases, we'll loop through the files
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


        for filei in phases[phase]: #now for each of the files
            fname=files[filei]
            #print(fname)
            bname = os.path.basename(fname)
            eid = float(bname.split("_")[0]) # UKBiob participant id # COMMAND LINE

            classid=setClassIdFromPheno(eid, phenotypes) #classid:0->"hypertense", classid:1->"normal"

            totals[classid]+=1

            io=cv2.cvtColor(cv2.imread(fname),cv2.COLOR_BGR2RGB)
            interp_method=PIL.Image.BICUBIC

            io = cv2.resize(io,(0,0),fx=resize,fy=resize, interpolation=interp_method) #resize it as specified above
            io = np.pad(io, [(mirror_pad_size, mirror_pad_size), (mirror_pad_size, mirror_pad_size), (0, 0)], mode="reflect")

            #convert input image into overlapping tiles, size is ntiler x ntilec x 1 x patch_size x patch_size x3
            io_arr_out=sklearn.feature_extraction.image.extract_patches(io,(patch_size,patch_size,3),stride_size)

            #resize it into a ntile x patch_size x patch_size x 3
            io_arr_out=io_arr_out.reshape(-1,patch_size,patch_size,3)

            storage["imgs"].append(io_arr_out)
            storage["labels"].append([classid for x in range(io_arr_out.shape[0])]) #add the filename to the storage array
            storage["filenames"].append([fname for x in range(io_arr_out.shape[0])]) #add the filename to the storage array

        #lastely, we should store the number of pixels
        npixels=hdf5_file.create_carray(hdf5_file.root, 'classsizes', tables.Atom.from_dtype(totals.dtype), totals.shape)
        npixels[:]=totals
        hdf5_file.close()

def main():
    images_dir = sys.argv[1];
    input_list = sys.argv[2];
    pheno_file = sys.argv[3];
    output_dir = sys.argv[4];
    buildDB(images_dir, input_list, pheno_file, output_dir)
    print("done")

if __name__== "__main__":
    main()



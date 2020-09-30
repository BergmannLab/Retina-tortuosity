import pandas as pd
import os as os
import glob
from shutil import copyfile, rmtree

def copyFileList(eid_list, images_dir, output_dir, limit):
    copied = 0
    for items in eid_list.iteritems(): 
        eid = items[1]
        pics = glob.glob(images_dir + str(eid) + '*.png')
        for pic in pics:
            copyfile(pic, output_dir+os.path.basename(pic))
            copied = copied+1
            if copied>=limit: return;
            
def BuildTestHypertenseDataset(output_file_hypertense, output_file_control, output_dir_hypertense, output_dir_control, images_dir, pheno_file, limit):
    # dump to file eids corresponding to hypertense participants
    phenotypes = pd.read_csv(pheno_file)
    DBP_biobankUID="4079-0.0"
    SBP_biobankUID="4080-0.0"
    high_DBP = phenotypes[DBP_biobankUID] > 100
    high_SBP = phenotypes[SBP_biobankUID] > 160
    phenotypes_hyp = phenotypes[high_DBP | high_SBP]
    # select first 1k eids corresponding to hypertense participants
    #hypertrense_eid = pd.Series(phenotypes_hyp["eid"].values[0:1000])
    hypertrense_eid = phenotypes_hyp["eid"]
    hypertrense_eid.to_csv(output_file_hypertense, index=False, header=False);
    
    # dump to file eids corresponding to participants with normal/low BP
    normal_DBP = phenotypes[DBP_biobankUID] < 80 # selecting in the low range
    normal_SBP = phenotypes[SBP_biobankUID] < 120
    phenotypes_normal = phenotypes[normal_DBP & normal_SBP]
    # select first 1k eids corresponding to participants with  normal bp
    #normal_eid = pd.Series(phenotypes_normal["eid"].values[0:1000])
    normal_eid = phenotypes_normal["eid"]
    normal_eid.to_csv(output_file_control, index=False, header=False);
    
    # build balanced dataset for hypertension by filtering images in images_dir
    rmtree(output_dir_hypertense); os.makedirs(output_dir_hypertense)
    rmtree(output_dir_control); os.makedirs(output_dir_control)
    # hypertension cases (number determined by limit param)
    copyFileList(hypertrense_eid, images_dir, output_dir_hypertense, limit)
    # include as many controls (normal/low SBP)
    copyFileList(normal_eid, images_dir, output_dir_control, limit)

def main():
    print("Starting to build Hypertension Dataset")
    output_file_hypertense = os.sys.argv[1]
    output_file_control = os.sys.argv[2]
    output_dir_hypertense = os.sys.argv[3]
    output_dir_control = os.sys.argv[4]
    images_dir = os.sys.argv[5]
    pheno_file = os.sys.argv[6]
    limit = int(os.sys.argv[7])
    BuildTestHypertenseDataset(output_file_hypertense, output_file_control, output_dir_hypertense, output_dir_control, images_dir, pheno_file, limit)
    print("done")
  
if __name__== "__main__":
    main()
  


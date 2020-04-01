import pandas as pd
import os
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
            
def ExplorePhenotypes(pheno_file, images_dir):
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
    hypertrense_eid.to_csv("hypertense.csv", index=False);
    
    # dump to file eids corresponding to participants with normal/low BP
    normal_DBP = phenotypes[DBP_biobankUID] < 80 # selecting in the low range
    normal_SBP = phenotypes[SBP_biobankUID] < 120
    phenotypes_normal = phenotypes[normal_DBP & normal_SBP]
    # select first 1k eids corresponding to participants with  normal bp
    #normal_eid = pd.Series(phenotypes_normal["eid"].values[0:1000])
    normal_eid = phenotypes_normal["eid"]
    normal_eid.to_csv("normal.csv", index=False);
    
    # build balanced dataset for hypertension by filtering images in images_dir
    output_dir_h="./output_dataset/hypertense/"; rmtree(output_dir_h); os.makedirs(output_dir_h)
    output_dir_n="./output_dataset/normal/"; rmtree(output_dir_n); os.makedirs(output_dir_n)
    # include examples of hypertension
    limit = 1000
    copyFileList(hypertrense_eid, images_dir, output_dir_h, limit)
    # include (twice) as many normal/low SB examples
    copyFileList(normal_eid, images_dir, output_dir_n, 2*limit)

def main():
    pheno_file = "/Users/mtomason/Documents/projects/retinal_images/UK_biobank/03_src/archive/UKBiob/00_raw/ukb34181.csv"
    images_dir = "/Users/mtomason/Documents/projects/retinal_images/UK_biobank/03_src/archive/UKBiob/00_raw/REVIEW_many/CLRIS/images/"
    BuildTestHypertenseDataset(pheno_file, images_dir)
    print("done")
  
if __name__== "__main__":
    main()
  


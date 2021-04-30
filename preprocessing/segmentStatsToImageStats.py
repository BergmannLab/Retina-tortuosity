#%%
import os, pathlib
import sys
from datetime import datetime
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.image as mpimg
from matplotlib import cm
import csv

DATE = datetime.now().strftime("%Y_%m_%d")
QUINTILE_TYPE = "leftRightDifference"
VESSEL_TYPE  = '' # Arteries, Veins, or ArteryVeinDiff


input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/"
output_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/" + DATE + "_" + QUINTILE_TYPE + VESSEL_TYPE + "/"

imageIDs= []
with open("imageIDs.txt") as file:
    for i, line in enumerate(file):
        if((i>=int(sys.argv[1])) & (i<=int(sys.argv[2]))):
            imageIDs.append(line.rstrip('\n'))



os.chdir(input_dir)
if sys.argv[1]=="0":
    pathlib.Path(output_dir).mkdir(parents=False, exist_ok=True)

for imageID in imageIDs:
    
    split_id = imageID.split("_")
    right_id = split_id[0]+"_21016_0_0_all_imageStats.tsv"
    if (split_id[1] == "21015") & (split_id[2] == "0") & (split_id[3] == "0") & pathlib.Path(right_id).is_file():
        left = pd.read_csv(imageID+"_all_imageStats.tsv", delimiter='\t')
        right = pd.read_csv(right_id, delimiter='\t')
        diff = abs(left-right)
        diff.to_csv(output_dir + imageID+"_all_imageStats.tsv", sep='\t', index=False)
    else:
        right_id = split_id[0]+"_21016_1_0_all_imageStats.tsv"
        if (split_id[1] == "21015") & (split_id[2] == "1") & (split_id[3] == "0") & pathlib.Path(right_id).is_file():
            left = pd.read_csv(imageID+"_all_imageStats.tsv", delimiter='\t')
            right = pd.read_csv(right_id, delimiter='\t')
            diff = abs(left-right)
            diff.to_csv(output_dir + imageID+"_all_imageStats.tsv", sep='\t', index=False)

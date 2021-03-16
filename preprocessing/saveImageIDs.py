#%%
import os
import sys

output_dir = os.getcwd()
input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/"
os.chdir(input_dir)

os.remove(output_dir + '/imageIDs.txt')
for i in os.listdir()[int(sys.argv[1]):int(sys.argv[2])]:
    if i.endswith("segmentStats.tsv"):

        imageID = i.split("_all_segmentStats")[0]
        with open(output_dir + '/imageIDs.txt', 'a') as f:
            f.write(imageID + '\n')

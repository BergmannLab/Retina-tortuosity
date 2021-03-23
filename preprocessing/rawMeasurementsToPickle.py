import os
import csv
import pickle as pkl
import _pickle as cPkl
import bz2

output_dir = '/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/output/backup/'
input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/"

imageIDs= []
with open("imageIDs.txt") as file:
    for i, line in enumerate(file):
        imageIDs.append(line.strip("\n"))

os.chdir(input_dir)

data = []
for i,imageID in enumerate(imageIDs):
    data.append([])
    data[i].append(imageID)
    for j in range(0,3):
        data[i].append([])
    with open(imageID + "_all_rawXCoordinates.tsv") as fd:
        rd = csv.reader(fd, delimiter='\t')
        for row in rd:
            data[i][1].append([float(j) for j in row])
    with open(imageID + "_all_rawYCoordinates.tsv") as fd:
        rd = csv.reader(fd, delimiter='\t')
        for row in rd:
            data[i][2].append([float(j) for j in row])
    with open(imageID + "_all_rawDiameters.tsv") as fd:
        rd = csv.reader(fd, delimiter='\t')
        for row in rd:
            data[i][3].append([float(j) for j in row])

with bz2.BZ2File(output_dir+"rawSegmentMeasurements.pbz2", 'w') as fp:
    cPkl.dump(data, fp)

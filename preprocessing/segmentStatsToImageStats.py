#%%
import os
from datetime import datetime
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.image as mpimg
from matplotlib import cm
import csv

DATE = datetime.now().strftime("%Y_%m_%d")
QUINTILE_TYPE = "diameter"
VESSEL_TYPE  = 'Veins'


input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/"
output_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/" + DATE + "_" + QUINTILE_TYPE + "QuintilesImageStats" + VESSEL_TYPE + "/"

os.chdir(input_dir)
try:
    os.mkdir(output_dir)
except Exception as e:
    print(e)

for i in os.listdir():
    if i.endswith("segmentStats.tsv"):

        # loading image-specific segment stats:
        df = pd.read_csv(i, delimiter='\t')
	# 
        if VESSEL_TYPE == 'Arteries':
            df = df.loc[df['AVScore']>0]
        elif VESSEL_TYPE == 'Veins':
            df = df.loc[df['AVScore']<0]

	# in case less than 5 remaining vessels (need 5 for quintiles):
        if df.shape[0] < 5:
            continue

        imageID = i.split("_all_segmentStats")[0]
	
	# DISTANCE QUINTILES
	# a) distance from literal center of fundus image        
        #center_X = 1536/2
        #center_Y = 2048/2
	# b) center as combination of thickest vessel positions
	# ... to copy

        #X = []
        #Y = []
        #with open(imageID + "_all_rawXCoordinates.tsv") as fd:
        #    rd = csv.reader(fd, delimiter='\t')
        #    for row in rd:
        #        X.append([float(j) for j in row])
        #with open(imageID + "_all_rawYCoordinates.tsv") as fd:
        #    rd = csv.reader(fd, delimiter='\t')
        #    for row in rd:
        #        Y.append([float(j) for j in row])

        #dists = []
        #for j in range(len(X)):
        #    if j in df.index:
        #        segMedianX = np.median(X[j])
        #        segMedianY = np.median(Y[j])
        #        dists.append(np.sqrt(np.power(segMedianX-center_X, 2) + np.power(segMedianY-center_Y, 2)))
        
        #dist_quints = np.quantile(dists, [0.2,0.4,0.6,0.8])
        #dist_q1Inds = [i for i in range(len(dists)) if dists[i] < dist_quints[0]]
        #dist_q2Inds = [i for i in range(len(dists)) if ((dists[i] < dist_quints[1]) & (dists[i] >= dist_quints[0]))]
        #dist_q3Inds = [i for i in range(len(dists)) if ((dists[i] < dist_quints[2]) & (dists[i] >= dist_quints[1]))]
        #dist_q4Inds = [i for i in range(len(dists)) if ((dists[i] < dist_quints[3]) & (dists[i] >= dist_quints[2]))]
        #dist_q5Inds = [i for i in range(len(dists)) if dists[i] >= dist_quints[3]]

        
        
        # DIAMETER QUINTILES
        diam_quints = np.quantile(df["medianDiameter"], [0.2,0.4,0.6,0.8])
        diam_q1Inds = df["medianDiameter"].loc[df["medianDiameter"] < diam_quints[0]].index
        diam_q2Inds = df["medianDiameter"].loc[(df["medianDiameter"] < diam_quints[1]) \
            & (df["medianDiameter"] >= diam_quints[0])].index
        diam_q3Inds = df["medianDiameter"].loc[(df["medianDiameter"] < diam_quints[2]) \
            & (df["medianDiameter"] >= diam_quints[1])].index
        diam_q4Inds = df["medianDiameter"].loc[(df["medianDiameter"] < diam_quints[3]) \
            & (df["medianDiameter"] >= diam_quints[2])].index
        diam_q5Inds = df["medianDiameter"].loc[df["medianDiameter"] >= diam_quints[3]].index

        #segLen_quints = np.quantile(df["arcLength"], [0.2,0.4,0.6,0.8])
        #segLen_q1Inds = df["arcLength"].loc[df["arcLength"] < segLen_quints[0]].index
        #segLen_q2Inds = df["arcLength"].loc[(df["arcLength"] < segLen_quints[1]) \
        #    & (df["arcLength"] >= segLen_quints[0])].index
        #segLen_q3Inds = df["arcLength"].loc[(df["arcLength"] < segLen_quints[2]) \
        #    & (df["arcLength"] >= segLen_quints[1])].index
        #segLen_q4Inds = df["arcLength"].loc[(df["arcLength"] < segLen_quints[3]) \
        #    & (df["arcLength"] >= segLen_quints[2])].index
        #segLen_q5Inds = df["arcLength"].loc[df["arcLength"] >= segLen_quints[3]].index


        with open(output_dir + imageID + "_all_imageStats.tsv", 'w') as f:
            f.write("DF1st\tDF2nd\tDF3rd\tDF4th\tDF5th\n")
            
            # .loc for diam/segLen, .iloc for dist
            f.write("%s\t" % np.median(df['DF'].loc[diam_q1Inds]))
            f.write("%s\t" % np.median(df['DF'].loc[diam_q2Inds]))
            f.write("%s\t" % np.median(df['DF'].loc[diam_q3Inds]))
            f.write("%s\t" % np.median(df['DF'].loc[diam_q4Inds]))
            f.write("%s\n" % np.median(df['DF'].loc[diam_q5Inds]))
# %%

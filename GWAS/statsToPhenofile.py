# a) raw ARIA measurements -> phenofile
# or b) segment stats and image stats -> phenofile
# ignores all images that don't pass QC!

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
from multiprocessing import Pool

def getPhenotypes(participant):
	participant_imgs = [img for img in imgs if participant in img]
	phenotypes = []
	
	imagesToParticipant(participant_imgs)
	#phenotypes=phenotypes + getDF(participant_imgs)
   	# loading image-specific segment stats:

def oldStuff(): 
    if VESSEL_TYPE == 'Arteries':
        df = df.loc[df['AVScore']>0]
        # in case less than 5 remaining vessels (need 5 for quintiles):
        if df.shape[0] < 5:
            print("hi")
    elif VESSEL_TYPE == 'Veins':
        df = df.loc[df['AVScore']<0]
        # in case less than 5 remaining vessels (need 5 for quintiles):
        if df.shape[0] < 5:
            print('hi')#continue
    elif VESSEL_TYPE == 'ArteryVeinDiff':
        df_vein   = df.loc[df['AVScore']<0]
        df = df.loc[df['AVScore']>0]
        # in case less than 5 remaining vessels (need 5 for quintiles):
        if (df.shape[0] < 5) | (df_vein.shape[0] < 5):
            print('hi')#continue

    if 1==1:    
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
        #diam_quints = np.quantile(df["medianDiameter"], [0.2,0.4,0.6,0.8])
        #diam_q1Inds = df["medianDiameter"].loc[df["medianDiameter"] < diam_quints[0]].index
        #diam_q2Inds = df["medianDiameter"].loc[(df["medianDiameter"] < diam_quints[1]) \
        #    & (df["medianDiameter"] >= diam_quints[0])].index
        #diam_q3Inds = df["medianDiameter"].loc[(df["medianDiameter"] < diam_quints[2]) \
        #    & (df["medianDiameter"] >= diam_quints[1])].index
        #diam_q4Inds = df["medianDiameter"].loc[(df["medianDiameter"] < diam_quints[3]) \
        #    & (df["medianDiameter"] >= diam_quints[2])].index
        #diam_q5Inds = df["medianDiameter"].loc[df["medianDiameter"] >= diam_quints[3]].index
        # 
        #if VESSEL_TYPE == 'ArteryVeinDiff':
        #    diamVein_quints = np.quantile(df_vein["medianDiameter"], [0.2,0.4,0.6,0.8])
        #    diamVein_q1Inds = df_vein["medianDiameter"].loc[df_vein["medianDiameter"] < diamVein_quints[0]].index
        #    diamVein_q2Inds = df_vein["medianDiameter"].loc[(df_vein["medianDiameter"] < diamVein_quints[1]) \
        #        & (df_vein["medianDiameter"] >= diamVein_quints[0])].index
        #    diamVein_q3Inds = df_vein["medianDiameter"].loc[(df_vein["medianDiameter"] < diamVein_quints[2]) \
        #        & (df_vein["medianDiameter"] >= diamVein_quints[1])].index
        #    diamVein_q4Inds = df_vein["medianDiameter"].loc[(df_vein["medianDiameter"] < diamVein_quints[3]) \
        #        & (df_vein["medianDiameter"] >= diamVein_quints[2])].index
        #    diamVein_q5Inds = df_vein["medianDiameter"].loc[df_vein["medianDiameter"] >= diamVein_quints[3]].index
        
        # global quintiles UKBB

        segLen_quints = [23.3,44.3,77.7,135.8]
        
        # local way
        
        #segLen_quints = np.quantile(df["arcLength"], [0.2,0.4,0.6,0.8])
        
        # quintile indices
        segLen_q1Inds = df["arcLength"].loc[df["arcLength"] < segLen_quints[0]].index
        segLen_q2Inds = df["arcLength"].loc[(df["arcLength"] < segLen_quints[1]) \
            & (df["arcLength"] >= segLen_quints[0])].index
        segLen_q3Inds = df["arcLength"].loc[(df["arcLength"] < segLen_quints[2]) \
            & (df["arcLength"] >= segLen_quints[1])].index
        segLen_q4Inds = df["arcLength"].loc[(df["arcLength"] < segLen_quints[3]) \
            & (df["arcLength"] >= segLen_quints[2])].index
        segLen_q5Inds = df["arcLength"].loc[df["arcLength"] >= segLen_quints[3]].index


        with open(output_dir + imageID + "_all_imageStats.tsv", 'w') as f:
            f.write("DF1st\tDF2nd\tDF3rd\tDF4th\tDF5th\n")
            
            if VESSEL_TYPE != 'ArteryVeinDiff':
                pheno='medianDiameter'
                # .loc for diam/segLen, .iloc for dist
                f.write("%s\t" % np.median(df[pheno].loc[segLen_q1Inds]))
                f.write("%s\t" % np.median(df[pheno].loc[segLen_q2Inds]))
                f.write("%s\t" % np.median(df[pheno].loc[segLen_q3Inds]))
                f.write("%s\t" % np.median(df[pheno].loc[segLen_q4Inds]))
                f.write("%s\n" % np.median(df[pheno].loc[segLen_q5Inds]))
            else:
                # .loc for diam/segLen, .iloc for dist
                f.write("%s\t" % np.subtract(np.median(df['medianDiameter'].loc[diam_q1Inds]),np.median(df_vein['medianDiameter'].loc[diamVein_q1Inds])))
                f.write("%s\t" % np.subtract(np.median(df['medianDiameter'].loc[diam_q2Inds]),np.median(df_vein['medianDiameter'].loc[diamVein_q2Inds])))
                f.write("%s\t" % np.subtract(np.median(df['medianDiameter'].loc[diam_q3Inds]),np.median(df_vein['medianDiameter'].loc[diamVein_q3Inds])))
                f.write("%s\t" % np.subtract(np.median(df['medianDiameter'].loc[diam_q4Inds]),np.median(df_vein['medianDiameter'].loc[diamVein_q4Inds])))
                f.write("%s\n" % np.subtract(np.median(df['medianDiameter'].loc[diam_q5Inds]),np.median(df_vein['medianDiameter'].loc[diamVein_q5Inds])))
# %%

def segmentStatToMedian(df, phenotype, vesselType):
	if vesselType == 'all':
		return [np.median(df[stat])]
	elif vesselType == 'artery':
		return [np.median(df[stat].loc[df['AVScore'] > 0])]
	elif vesselType == 'vein':
                return [np.median(df[stat].loc[df['AVScore'] < 0])]

def imagesToParticipant(imgs):
	all_medians = []
	artery_medians = []
	vein_medians = []
	for i in imgs:
		try:
			df = pd.read_csv(input_dir+i, delimiter='\t')
			all_medians.append(df.median(axis=1))
			artery_medians.append(df[df['AVScore'] > 0].median(axis=1))
			vein_medians.append(df[df['AVScore'] < 0].median(axis=1))
		except:
			print("ARIA didn't have stats for img", i)
	# at the moment we are weighting all images equally. we could also weigh them by total vasculature size as a proxy for image quality
	means = np.mean(np.array(all_medians),axis=0) + np.mean(np.array(artery_medians),axis=0) + np.mean(np.array(vein_medians),axis=0)
	print(means)


if __name__ == '__main__':
	DATE = datetime.now().strftime("%Y_%m_%d")
	EXPERIMENT_NAME = "newQC"
	EXPERIMENT_ID = DATE + "_" + EXPERIMENT_NAME

	input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/"#2021_10_04_rawMeasurementsWithoutQC/"
	output_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/" + EXPERIMENT_ID + "/"

	imgs = pd.read_csv(sys.argv[1], header=None)
	imgs = imgs[0].values
	participants = list(set([i.split("_")[0] for i in imgs]))
	
	#os.chdir(input_dir)
	#pathlib.Path(output_dir).mkdir(parents=False, exist_ok=True)

	pool = Pool()
	out = pool.map(getPhenotypes, participants[0:10])
#	phenofile = pd.DataFrame(out, columns=PHENOTYPES)
        # saving to blub

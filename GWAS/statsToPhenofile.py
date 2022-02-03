# a) raw ARIA measurements -> phenofile
# or b) segment stats and image stats -> phenofile
# ignores all images that don't pass QC!

import os, pathlib
import sys
from datetime import datetime
import pandas as pd
import numpy as np
import scipy.stats as ss
from matplotlib import pyplot as plt
import matplotlib.image as mpimg
from matplotlib import cm
import csv
from multiprocessing import Pool

# DEFINE the characteristic measure of interest
characteristic_measure = 'median' # options: 'median', 'mean', 'std', and 'coef_var_pearson'

def getParticipantStatfiles(participant):
	return [img.split(".png")[0]+"_all_segmentStats.tsv" for img in imgs if participant in img]

def getParticipantImages(participant):
        return [img for img in imgs if participant in img]


def getStatfilePhenotypes(statfiles):
        
        # because of non-ARIA QC, some predicted statfiles might not actually exist (hence they had no ARIA output)
        # therefore I try until I find an existing statfile
	for i in statfiles:
		try:
			f=pd.read_csv(i[0], delimiter='\t')
			columns = list(f.columns)
			phenos = []
			phenos = phenos + [i+"_all" for i in columns]
			phenos = phenos + [i+"_artery" for i in columns]
			return phenos + [i+"_vein" for i in columns]
		except:
			pass

# I do not think the follow is needed
""" def segmentStatToMedian(df, phenotype, vesselType):
    if characteristic_measure == 'median':
        if vesselType == 'all':
            return [np.median(df[stat])]
        elif vesselType == 'artery':
            return [np.median(df[stat].loc[df['AVScore'] > 0])]
        elif vesselType == 'vein':
                return [np.median(df[stat].loc[df['AVScore'] < 0])]
    elif characteristic_measure == 'mean':
        if vesselType == 'all':
            return [np.mean(df[stat])]
        elif vesselType == 'artery':
            return [np.mean(df[stat].loc[df['AVScore'] > 0])]
        elif vesselType == 'vein':
                return [np.mean(df[stat].loc[df['AVScore'] < 0])]
    elif characteristic_measure == 'std':
        if vesselType == 'all':
            return [np.std(df[stat])]
        elif vesselType == 'artery':
            return [np.std(df[stat].loc[df['AVScore'] > 0])]
        elif vesselType == 'vein':
                return [np.std(df[stat].loc[df['AVScore'] < 0])]
    elif characteristic_measure == 'coef_var_pearson':
        if vesselType == 'all':
            return [np.std(df[stat])/np.mean(df[stat])]
        elif vesselType == 'artery':
            return [np.std(df[stat])/np.mean(df[stat].loc[df['AVScore'] > 0])]
        elif vesselType == 'vein':
                return [np.std(df[stat])/np.mean(df[stat].loc[df['AVScore'] < 0])]
 """ 

def nanmeanOrNan(medians, n_phenotypes):
	if medians != []:
		return np.nanmean(np.array(medians),axis=0)
	else:
		#print("caught!!")
		return np.array([np.nan for i in range(0,n_phenotypes)])

# INPUT: images belonging to single participant
# 1) segment stats for img -> median
# 2) if multiple images -> mean of all participant img stats
# computs all the stats for: all (combined), artery, and vein
def allSegmentStats(inputs):
	imgs = inputs[0]
	n_phenotypes = inputs[1]

	all_medians = []
	artery_medians = []
	vein_medians = []
	for i in imgs:
            try: # because for any image passing QC, ARIA might have failed
            # df is segment stat file
                    df = pd.read_csv(i, delimiter='\t')
                    if characteristic_measure == 'mean':
                        all_medians.append(df.mean(axis=0))
                        artery_medians.append(df[df['AVScore'] > 0].mean(axis=0))
                        vein_medians.append(df[df['AVScore'] < 0].mean(axis=0))
                    elif characteristic_measure == 'median':
                        all_medians.append(df.median(axis=0))
                        artery_medians.append(df[df['AVScore'] > 0].median(axis=0))
                        vein_medians.append(df[df['AVScore'] < 0].median(axis=0))
                    elif characteristic_measure == 'std':
                        all_medians.append(df.std(axis=0))
                        artery_medians.append(df[df['AVScore'] > 0].std(axis=0))
                        vein_medians.append(df[df['AVScore'] < 0].std(axis=0))
                    elif characteristic_measure == 'coef_var_pearson':
                        all_medians.append(df.std(axis=0)/df.median(axis=0))
                        artery_medians.append((df[df['AVScore'] > 0].std(axis=0))/(df[df['AVScore'] > 0].median(axis=0)))
                        vein_medians.append((df[df['AVScore'] < 0].std(axis=0))/(df[df['AVScore'] > 0].median(axis=0)))
            except:
                print("ARIA didn't have stats for img", i)
	# at the moment we are weighting all images equally. we could also weigh them by total vasculature size as a proxy for image quality
	SegmentStats_measure = np.concatenate((nanmeanOrNan(all_medians, n_phenotypes), nanmeanOrNan(artery_medians, n_phenotypes), nanmeanOrNan(vein_medians, n_phenotypes)))
	if np.isnan(SegmentStats_measure).any():
		print("WARNING, at least one allSegmentStats phenotype is nan")
	return(SegmentStats_measure)

def imgToParticipant(imgs_of_participant):
	return stats.loc[imgs_of_participant].mean()


# pseudofunction containing old stuff that might come in handy

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
            if characteristic_measure == 'median':
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
            
            elif characteristic_measure == 'mean':
                if VESSEL_TYPE != 'ArteryVeinDiff':
                    pheno='meanDiameter'

                    # .loc for diam/segLen, .iloc for dist
                    f.write("%s\t" % np.mean(df[pheno].loc[segLen_q1Inds]))
                    f.write("%s\t" % np.mean(df[pheno].loc[segLen_q2Inds]))
                    f.write("%s\t" % np.mean(df[pheno].loc[segLen_q3Inds]))
                    f.write("%s\t" % np.mean(df[pheno].loc[segLen_q4Inds]))
                    f.write("%s\n" % np.mean(df[pheno].loc[segLen_q5Inds]))
                else:
                    # .loc for diam/segLen, .iloc for dist
                    f.write("%s\t" % np.subtract(np.mean(df['meanDiameter'].loc[diam_q1Inds]),np.mean(df_vein['meanDiameter'].loc[diamVein_q1Inds])))
                    f.write("%s\t" % np.subtract(np.mean(df['meanDiameter'].loc[diam_q2Inds]),np.mean(df_vein['meanDiameter'].loc[diamVein_q2Inds])))
                    f.write("%s\t" % np.subtract(np.mean(df['meanDiameter'].loc[diam_q3Inds]),np.mean(df_vein['meanDiameter'].loc[diamVein_q3Inds])))
                    f.write("%s\t" % np.subtract(np.mean(df['meanDiameter'].loc[diam_q4Inds]),np.mean(df_vein['meanDiameter'].loc[diamVein_q4Inds])))
                    f.write("%s\n" % np.subtract(np.mean(df['meanDiameter'].loc[diam_q5Inds]),np.mean(df_vein['meanDiameter'].loc[diamVein_q5Inds])))
                       
            elif characteristic_measure == 'std':
                if VESSEL_TYPE != 'ArteryVeinDiff':
                    pheno='stdDiameter'

                    # .loc for diam/segLen, .iloc for dist
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q1Inds]))
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q2Inds]))
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q3Inds]))
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q4Inds]))
                    f.write("%s\n" % np.std(df[pheno].loc[segLen_q5Inds]))
                else:
                    # .loc for diam/segLen, .iloc for dist
                    f.write("%s\t" % np.subtract(np.std(df['stdDiameter'].loc[diam_q1Inds]),np.std(df_vein['stdDiameter'].loc[diamVein_q1Inds])))
                    f.write("%s\t" % np.subtract(np.std(df['stdDiameter'].loc[diam_q2Inds]),np.std(df_vein['stdDiameter'].loc[diamVein_q2Inds])))
                    f.write("%s\t" % np.subtract(np.std(df['stdDiameter'].loc[diam_q3Inds]),np.std(df_vein['stdDiameter'].loc[diamVein_q3Inds])))
                    f.write("%s\t" % np.subtract(np.std(df['stdDiameter'].loc[diam_q4Inds]),np.std(df_vein['stdDiameter'].loc[diamVein_q4Inds])))
                    f.write("%s\n" % np.subtract(np.std(df['stdDiameter'].loc[diam_q5Inds]),np.std(df_vein['stdDiameter'].loc[diamVein_q5Inds])))

                                   
            elif characteristic_measure == 'coef_var_pearson':
                if VESSEL_TYPE != 'ArteryVeinDiff':
                    pheno='coefvarpearsonDiameter'

                    # .loc for diam/segLen, .iloc for dist
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q1Inds])/np.mean(df[pheno].loc[segLen_q1Inds]))
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q2Inds])/np.mean(df[pheno].loc[segLen_q2Inds]))
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q3Inds])/np.mean(df[pheno].loc[segLen_q3Inds]))
                    f.write("%s\t" % np.std(df[pheno].loc[segLen_q4Inds])/np.mean(df[pheno].loc[segLen_q4Inds]))
                    f.write("%s\n" % np.std(df[pheno].loc[segLen_q5Inds])/np.mean(df[pheno].loc[segLen_q5Inds]))
                else:
                    # .loc for diam/segLen, .iloc for dist
                    f.write("%s\t" % np.subtract(np.std(df['coefvarpearsonDiameter'].loc[diam_q1Inds])/np.mean(df['meanDiameter'].loc[diam_q1Inds]),np.std(df_vein['coefvarpearsonDiameter'].loc[diamVein_q1Inds])/np.mean(df_vein['coefvarpearsonDiameter'].loc[diamVein_q1Inds])))
                    f.write("%s\t" % np.subtract(np.std(df['coefvarpearsonDiameter'].loc[diam_q2Inds])/np.mean(df['meanDiameter'].loc[diam_q2Inds]),np.std(df_vein['coefvarpearsonDiameter'].loc[diamVein_q2Inds])/np.mean(df_vein['coefvarpearsonDiameter'].loc[diamVein_q2Inds])))
                    f.write("%s\t" % np.subtract(np.std(df['coefvarpearsonDiameter'].loc[diam_q3Inds])/np.mean(df['meanDiameter'].loc[diam_q3Inds]),np.std(df_vein['coefvarpearsonDiameter'].loc[diamVein_q3Inds])/np.mean(df_vein['coefvarpearsonDiameter'].loc[diamVein_q3Inds])))
                    f.write("%s\t" % np.subtract(np.std(df['coefvarpearsonDiameter'].loc[diam_q4Inds])/np.mean(df['meanDiameter'].loc[diam_q4Inds]),np.std(df_vein['coefvarpearsonDiameter'].loc[diamVein_q4Inds])/np.mean(df_vein['coefvarpearsonDiameter'].loc[diamVein_q4Inds])))
                    f.write("%s\n" % np.subtract(np.std(df['coefvarpearsonDiameter'].loc[diam_q5Inds])/np.mean(df['meanDiameter'].loc[diam_q5Inds]),np.std(df_vein['coefvarpearsonDiameter'].loc[diamVein_q5Inds])/np.mean(df_vein['coefvarpearsonDiameter'].loc[diamVein_q5Inds])))

# rbINT

# for the following code block, the corresponding MIT License

#The MIT License (MIT)
#
#Copyright (c) 2016 Edward Mountjoy
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

def rank_INT(series, c=3.0/8, stochastic=False):
    """ Perform rank-based inverse normal transformation on pandas series.
        If stochastic is True ties are given rank randomly, otherwise ties will
        share the same value. NaN values are ignored.
        Args:
            param1 (pandas.Series):   Series of values to transform
            param2 (Optional[float]): Constand parameter (Bloms constant)
            param3 (Optional[bool]):  Whether to randomise rank of ties
        
        Returns:
            pandas.Series
    """

    # Check input
    assert(isinstance(series, pd.Series))
    assert(isinstance(c, float))
    assert(isinstance(stochastic, bool))

    # Set seed
    np.random.seed(123)

    # Take original series indexes
    orig_idx = series.index

    # Drop NaNs
    series = series.loc[~pd.isnull(series)]

    # Get ranks
    if stochastic == True:
        # Shuffle by index
        series = series.loc[np.random.permutation(series.index)]
        # Get rank, ties are determined by their position in the series (hence
        # why we randomised the series)
        rank = ss.rankdata(series, method="ordinal")
    else:
        # Get rank, ties are averaged
        rank = ss.rankdata(series, method="average")

    # Convert numpy array back to series
    rank = pd.Series(rank, index=series.index)

    # Convert rank to normal distribution
    transformed = rank.apply(rank_to_normal, c=c, n=len(rank))
    
    return transformed[orig_idx]

def rank_to_normal(rank, c, n):
    # Standard quantile function
    x = (rank - c) / (n - 2*c + 1)
    return ss.norm.ppf(x)


# MAIN

if __name__ == '__main__':
	
	# experiment id
	DATE = datetime.now().strftime("%Y_%m_%d")
	EXPERIMENT_NAME = "median"
	EXPERIMENT_ID = DATE + "_" + EXPERIMENT_NAME

	#input and output dirs
	input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/"
	output_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/phenofiles/"
	os.chdir(input_dir)

	#phenotypes
	stats = pd.read_csv("2021-12-28_ARIA_phenotypes.csv", index_col=0)
	tmp = pd.read_csv("2021-11-29_bifurcations.csv", index_col=0)
	stats = stats.join(tmp)
	tmp = pd.read_csv("2021-11-29_AV_crossings.csv", index_col=0)
	stats = stats.join(tmp)
	tmp = pd.read_csv("2021-11-30_fractalDimension.csv", index_col=0)
	stats = stats.join(tmp)
	tmp = pd.read_csv("2022-02-01_N_green_pixels.csv", index_col=0)
	stats = stats.join(tmp)	

	#QC
	qcFile = sys.argv[1]
	imgs = pd.read_csv(qcFile, header=None) # images that pass QC of choice
	imgs = imgs[0].values

	participants = sorted(list(set([i.split("_")[0] for i in imgs]))) # participants with at least one img passing QC
	
	#print(qcFile) #testing
	nTest = len(participants) # len(participants) for production

	#imgs_per_participant is a participant list: each element contains list of segment stat files belonging to a participant's QCd images
	pool1 = Pool()
	imgs_per_participant = list(pool1.map(getParticipantImages, participants[0:nTest]))	

	#computing participant-wise stats
	pool = Pool()
	out = pool.map(imgToParticipant, imgs_per_participant)
	#curating participant-wise output
	participants_stats = pd.DataFrame(out, columns=stats.columns)
	participants_stats.index = participants[0:nTest]
	print('Nb of images that pass QC:',len(imgs),'\nNb of participants with QCd images:',len(imgs_per_participant))
	# quick check of how many nans we picked up along the way
	print('\nNans per phenotype\n',participants_stats.isna().sum())


	# your other cool phenotypes go here
	# you can then concatenate with existing phenofile
	# needs function -> image\tmeasurement1\tmeasurement2... -> participant stats


	# now that all is measured, we reorder to match sample file, then storing into phenofile
	# also saving rank-based INT version of phenotype and storing it

	fundus_samples = pd.read_csv("/data/FAC/FBM/DBC/sbergman/retina/UKBiob/genotypes/ukb_imp_v3_subset_fundus.sample",\
delimiter=" ",skiprows=2, header=None,dtype=str)
	phenofile_out = pd.DataFrame(index = fundus_samples[0], columns = participants_stats.columns, data=np.nan)
	
	#creating phenofile, accounting for missing genotypes
	idx = [i for i in participants_stats.index if i in phenofile_out.index]
	print(len(idx))	
	phenofile_out.loc[idx] = participants_stats.loc[idx]
	
	#creating rank-based INT phenofile
	phenofile_out_rbINT = phenofile_out.apply(rank_INT)
	
	# saving both raw and rank-based INT
	phenofile_out = phenofile_out.astype(str)
	phenofile_out = phenofile_out.replace('nan', '-999')
	phenofile_out.to_csv(output_dir+EXPERIMENT_ID+".csv", index=False, sep=" ")

	phenofile_out_rbINT = phenofile_out_rbINT.astype(str)
	phenofile_out_rbINT = phenofile_out_rbINT.replace('nan', '-999')
	phenofile_out_rbINT.to_csv(output_dir+EXPERIMENT_ID+"_qqnorm.csv", index=False, sep=" ")

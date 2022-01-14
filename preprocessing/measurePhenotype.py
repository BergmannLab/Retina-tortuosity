import os,sys
from datetime import datetime
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.image as mpimg
from matplotlib import cm
import seaborn
import csv
from multiprocessing import Pool
from PIL import Image
import PIL
from scipy import stats

def np_nonBlack(img):

	return img.any(axis=-1).sum()

def replaceRGB(img,old,new):
	out = img.copy()
	datas = out.getdata()
	newData = []
	for item in datas:
		if item[0] == old[0] and item[1] == old[1] and item[2] == old[2]:
			newData.append((new[0], new[1], new[2]))
		else:
			newData.append(item)
	out.putdata(newData)
	return out

def getFractalDimension(imgname):
	imageID = imgname.split(".")[0]
	print(imageID)
	try:
		img=Image.open(imageID+"_bin_seg.png")
		img_artery=replaceRGB(img,(255,0,0),(0,0,0))
		img_vein=replaceRGB(img,(0,0,255),(0,0,0))
		#img.save('/home/mbeyele5/im1.png')
		#img_artery.save('/home/mbeyele5/im2.png')
		#img_vein.save('/home/mbeyele5/im3.png')
		w,h=img.size
		
		box_sidelengths = [2,4,8,16,32,64,128,256,512]
		
		N_boxes,N_boxes_artery,N_boxes_vein = [],[],[]
		for i in box_sidelengths:
			w_i = round( w / i )
			h_i = round( h / i )
			img_i = img.resize( (w_i, h_i), resample=PIL.Image.BILINEAR)
			img_i_artery = img_artery.resize( (w_i, h_i), resample=PIL.Image.BILINEAR)
			img_i_vein = img_vein.resize( (w_i, h_i), resample=PIL.Image.BILINEAR)
			#plt.figure()
			#plt.imshow(np.asarray(img_i))
			#plt.savefig("/users/mbeyele5/"+imageID+str(i)+".png")
	
			N_boxes.append( np_nonBlack( np.asarray(img_i) ) )		
			N_boxes_artery.append( np_nonBlack( np.asarray(img_i_artery) ) )		
			N_boxes_vein.append( np_nonBlack( np.asarray(img_i_vein) ) )		
	 
		#print(box_sidelengths,N_boxes)		
		#plt.figure()
		#plt.scatter( np.log( [1/i for i in box_sidelengths] ), np.log(N_boxes) )
		#plt.savefig("/users/mbeyele5/"+imageID+"_scatter.png")

		slope,intercept,r_value,p_value,std_err = stats.linregress( np.log( [1/i for i in box_sidelengths] ), np.log(N_boxes) )
		slope_artery,intercept,r_value,p_value,std_err = stats.linregress( np.log( [1/i for i in box_sidelengths] ), np.log(N_boxes_artery) )
		slope_vein,intercept,r_value,p_value,std_err = stats.linregress( np.log( [1/i for i in box_sidelengths] ), np.log(N_boxes_vein) )
		
		#print(slope, intercept,r_value,p_value,std_err)
		return slope, slope_artery, slope_vein
					
	except Exception as e:
		print(e)
		print("image", imgname, "does not exist")
		return np.nan,np.nan,np.nan

def getBifurcations(imgname):

	try:
		X,Y = [],[]	

		imageID = imgname.split(".")[0]
		with open(aria_measurements_dir + imageID + "_all_center2Coordinates.tsv") as fd:
			rd = csv.reader(fd, delimiter='\t')
			for row in rd:
				X.append([float(j) for j in row])

		with open(aria_measurements_dir + imageID + "_all_center1Coordinates.tsv") as fd:
			rd = csv.reader(fd, delimiter='\t')
			for row in rd:
				Y.append([float(j) for j in row])

		with open(aria_measurements_dir + imageID + "_all_segmentStats.tsv") as fd:
			rd = pd.read_csv(fd, sep='\t')
			segmentStats = rd["AVScore"]

		df = pd.DataFrame([])
		df["segmentStats"] = segmentStats

		df_results = pd.DataFrame([])
		df_aux = pd.DataFrame([])
		aux = int(df.count(axis=0))

		# 'Arteries' if df['AVScore'] > 0
		# 'Veins' if df['AVScore'] < 0
		for i in range(aux):
			df_aux = pd.DataFrame(pd.DataFrame([X[i][0], X[i][len(X[i])-1]]))
			df_aux["Y"] = pd.DataFrame([Y[i][0], Y[i][len(Y[i])-1]])
			df_aux["type"] = segmentStats[i]
			df_aux["i"] = i
			df_results = df_results.append(df_aux, True)

		df_results.columns = ['X', 'Y', 'type', 'i']
		df_results['type'] = np.sign(df_results['type'])
		df_results.sort_values(by=['X'], inplace=True, ascending=False)

		X_1_aux = X_2_aux = 0.0
		bif_counter = 0
		aux = []
		cte = 3.5
		for s in range(len(df_results)):
		 
			for j in range(len(df_results)-s):
				j = j + s	
				# For X and Y: X[s] - cte <= X[j] <= X[s]
            	# Both arteries or both veins and != type 0
				if (df_results['X'].iloc[j] >= df_results['X'].iloc[s] - cte) and (df_results['X'].iloc[j] <= df_results['X'].iloc[s] + cte):
					if (df_results['Y'].iloc[j] >= df_results['Y'].iloc[s] - cte) and (df_results['Y'].iloc[j] <= df_results['Y'].iloc[s] + cte):
						if df_results['i'].iloc[j] != df_results['i'].iloc[s]:
							if (df_results['type'].iloc[j] == df_results['type'].iloc[s]) and \
									(df_results['type'].iloc[j] != 0 or df_results['type'].iloc[s] != 0):
								if (df_results['X'].iloc[j] != X_1_aux and df_results['X'].iloc[s] != X_1_aux and
										df_results['X'].iloc[j] != X_2_aux and df_results['X'].iloc[s] != X_2_aux):
									bif_counter = bif_counter + 1
									X_1_aux = df_results['X'].iloc[s]
									X_2_aux = df_results['X'].iloc[j]
					else:
						continue
		return bif_counter
	
	except Exception as e:
		print(e)
		return np.nan


def getAriaPhenotypes(imgname):
	imageID = imgname.split(".")[0]
	
	lengthQuints = [23.3, 44.3, 77.7, 135.8]
	
	all_medians = []
	artery_medians = []
	vein_medians = []
	try: # because for any image passing QC, ARIA might have failed
		# df is segment stat file
		df = pd.read_csv(aria_measurements_dir + imageID + "_all_segmentStats.tsv", delimiter='\t')
		all_medians = df.median(axis=0).values
		artery_medians = df[df['AVScore'] > 0].median(axis=0).values
		vein_medians = df[df['AVScore'] < 0].median(axis=0).values

		# stats based on longest fifth
		try:
			quintStats_all = df[df['arcLength'] > lengthQuints[3]].median(axis=0).values
			quintStats_artery = df[(df['arcLength'] > lengthQuints[3]) & (df['AVScore'] > 0)].median(axis=0).values
			quintStats_vein = df[(df['arcLength'] > lengthQuints[3]) & (df['AVScore'] < 0)].median(axis=0).values

		except Exception as e:
			print(e)
			print("longest 5th failed")
			quintStats_all = [np.nan for i in range(0,14)]
			quintStats_artery = quintStats_all
			quintStats_vein = quintStats_all

		df_im = pd.read_csv(aria_measurements_dir + imageID + "_all_imageStats.tsv", delimiter='\t')
		
		return np.concatenate((all_medians, artery_medians, vein_medians, quintStats_all,\
		   quintStats_artery, quintStats_vein, df_im['nVessels'].values), axis=None).tolist()
	except Exception as e:
		print(e)
		print("ARIA didn't have stats for img", imageID)
		return [np.nan for i in range(0,84)] # we measured 14 segment-wise stats using ARIA, for AV, and for longest quint -> 14*6+1=85, and nVessels


if __name__ == '__main__':
	
	# command line arguments
	qcFile = sys.argv[1] # qcFile used is noQCi, as we measure for all images
	phenotype_dir = sys.argv[2]
	aria_measurements_dir = sys.argv[3]
	lwnet_dir = sys.argv[4]

	# all the images
	imgfiles = pd.read_csv(qcFile, header=None)
	imgfiles = imgfiles[0].values

	# development param
	testLen = len(imgfiles) # len(imgfiles) is default	

	#computing the phenotype as a parallel process
	os.chdir(lwnet_dir)	
	pool = Pool()
	out = pool.map(getAriaPhenotypes, imgfiles[0:testLen])
	
	# storing the phenotype	
	
	# fractal dimension
	# df = pd.DataFrame(out, columns=["FD_all", "FD_artery", "FD_vein"])
	
	# bifurcations
	#df = pd.DataFrame(out, columns=["bifurcations"])
	
	# AV crossings
	#df = pd.DataFrame(out, columns=["AV_crossings"])
	#df=df.set_index(imgfiles[0:testLen])

	# ARIA phenotypes
	first_statsfile = pd.read_csv(aria_measurements_dir + "1027180_21015_0_0_all_segmentStats.tsv", sep='\t')
	cols = first_statsfile.columns
	cols_full = [i + "_all" for i in cols] + [i + "_artery" for i in cols] + [i + "_vein" for i in cols]\
	  + [i + "_longestFifth_all" for i in cols] + [i + "_longestFifth_artery" for i in cols] + [i + "_longestFifth_vein" for i in cols]\
	  + ["nVessels"]
	df = pd.DataFrame(out, columns=cols_full)
	df.index = imgfiles[0:testLen]
	print(len(df), "image measurements taken")
	print("NAs per phenotype")
	print(df.isna().sum())

	df.to_csv(phenotype_dir + datetime.today().strftime('%Y-%m-%d') + '_ARIA_phenotypes.csv')

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

		cross_counter = 0
		df_cross_x = pd.DataFrame([])
		df_cross_previous = pd.DataFrame([])
		aux_num_x = 0.0
		aux_num_y = 0.0
		aux_num_type = 0.0
		aux_num_i = 0.0
		aux = []
		cte = 3.5
		for s in range(len(df_results)):
			aux_num_x = df_results['X'].iloc[s]
			aux_num_y = df_results['Y'].iloc[s]
			aux_num_i = df_results['i'].iloc[s]
			aux_num_type = df_results['type'].iloc[s]
		 
			for j in range(len(df_results)-s):
				j = j + s
				if (df_results['X'].iloc[j] >= aux_num_x - cte) and (df_results['X'].iloc[j] <= aux_num_x + cte):
					if (df_results['Y'].iloc[j] >= aux_num_y - cte) and (df_results['Y'].iloc[j] <= aux_num_y + cte):
						if df_results['i'].iloc[j] != aux_num_i:
							if (df_results['type'].iloc[j] == aux_num_type) and \
									(df_results['type'].iloc[j] != 0 or aux_num_type != 0):
								cross_counter = cross_counter + 1
					else:
						continue
		return cross_counter
	
	except Exception as e:
		print(e)
		return np.nan

def getAVCrossings(imgname):

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
		#print("La mitad")

		# 'Arteries' if df['AVScore'] > 0
		# 'Veins' if df['AVScore'] < 0
		for i in range(aux):
			df_aux = pd.DataFrame(X[i])
			df_aux["Y"] = pd.DataFrame(Y[i])
			df_aux["type"] = segmentStats[i]
			df_aux["i"] = i
			df_results = df_results.append(df_aux, True)

		df_results.columns = ['X', 'Y', 'type', 'i']
		df_results['type'] = np.sign(df_results['type'])
		df_results.sort_values(by=['X'], inplace=True, ascending=False)

		cross_counter = 0
		df_cross_x = pd.DataFrame([])
		df_cross_previous = pd.DataFrame([])
		aux_num_x = 0.0
		aux_num_y = 0.0
		aux_num_type = 0.0
		aux = []
		cte = 12

		for j in range(len(df_results)):
			if (df_results['X'].iloc[j] >= aux_num_x - cte) and (df_results['X'].iloc[j] <= aux_num_x + cte):
				if (df_results['Y'].iloc[j] >= aux_num_y - cte) and (df_results['Y'].iloc[j] <= aux_num_y + cte):
					if (df_results['type'].iloc[j] == aux_num_type) or (df_results['type'].iloc[j] == 0) or (aux_num_type == 0):
						continue
					else:
						cross_counter = cross_counter + 1

			aux_num_x = df_results['X'].iloc[j]
			aux_num_y = df_results['Y'].iloc[j]
			aux_num_type = df_results['type'].iloc[j]

		return cross_counter

	except Exception as e:
		print(e)
		return np.nan

if __name__ == '__main__':
	
	# command line arguments
	qcFile = sys.argv[1] # qcFile used is noQC as we measure for all images
	phenotype_dir = sys.argv[2]
	aria_measurements_dir = sys.argv[3]
	lwnet_dir = sys.argv[4]

	# all the images
	imgfiles = pd.read_csv(qcFile, header=None)
	imgfiles = imgfiles[0].values

	# development param
	testLen = len(imgfiles) # len(imgs) is default	

	#computing the phenotype as a parallel process
	os.chdir(lwnet_dir)	
	pool = Pool()
	out = pool.map(getBifurcations, imgfiles[0:testLen])
	
	# storing the phenotype	
	
	# fractal dimension
	# df = pd.DataFrame(out, columns=["FD_all", "FD_artery", "FD_vein"])
	# bifurcations
	df = pd.DataFrame(out, columns=["bifurcations"])
	# AV crossings
	# df = pd.DataFrame(out, columns=["AV_crossings"])
	df=df.set_index(imgfiles[0:testLen])

	print(len(df), "image measurements taken")
	print("NAs per phenotype")
	print(df.isna().sum())

	df.to_csv(phenotype_dir + datetime.today().strftime('%Y-%m-%d') + '_bifurcations.csv')

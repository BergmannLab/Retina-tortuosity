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
import math


def dot(vA, vB):
    return vA[0] * vB[0] + vA[1] * vB[1]


def ang(lineA, lineB):
    # Get nicer vector form
    vA = [(lineA[0][0] - lineA[1][0]), (lineA[0][1] - lineA[1][1])]
    vB = [(lineB[0][0] - lineB[1][0]), (lineB[0][1] - lineB[1][1])]
    # Get dot prod
    dot_prod = dot(vA, vB)
    # Get magnitudes
    magA = dot(vA, vA) ** 0.5
    magB = dot(vB, vB) ** 0.5
    # Get cosine value
    cos_ = dot_prod / magA / magB
    # Get angle in radians and then convert to degrees
    angle = math.acos(dot_prod / magB / magA)
    # Basically doing angle <- angle mod 360
    ang_deg = math.degrees(angle) % 360

    if ang_deg - 180 >= 0:
        # As in if statement
        return 360 - ang_deg
    else:

        return ang_deg


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



def getTVA(imgname, df_OD):
	
	try:
		X,Y,D = [],[],[]	

		imageID = imgname.split(".")[0]
		with open(aria_measurements_dir + imageID + "_all_center2Coordinates.tsv") as fd:
			rd = csv.reader(fd, delimiter='\t')
			for row in rd:
				X.append([float(j) for j in row])

		with open(aria_measurements_dir + imageID + "_all_center1Coordinates.tsv") as fd:
			rd = csv.reader(fd, delimiter='\t')
			for row in rd:
				Y.append([float(j) for j in row])
		
		with open(aria_measurements_dir + imageID + "_all_rawDiameters.tsv") as fd:
			rd = csv.reader(fd, delimiter='\t')
			for row in rd:
				D.append([float(j) for j in row])

		with open(aria_measurements_dir + imageID + "_all_segmentStats.tsv") as fd:
			rd = pd.read_csv(fd, sep='\t')
			segmentStats = rd["AVScore"]

		df = pd.DataFrame([])
		df["segmentStats"] = segmentStats
		df_pintar = pd.DataFrame([])
		df_pin = pd.DataFrame([])
		aux = int(df.count(axis=0))

		# 'Arteries' if df['AVScore'] > 0 and 'Veins' if df['AVScore'] < 0
		
		for i in range(aux):
			df_pin = pd.DataFrame(X[i])
			df_pin["Y"] = pd.DataFrame(Y[i])
			df_pin["Diameter"] = pd.DataFrame(D[i])
			df_pin["type"] = segmentStats[i]
			df_pin["i"] = i
			df_pintar = df_pintar.append(df_pin, True)

		df_pintar.columns = ['X', 'Y', 'Diameter', 'type', 'i']
		df_pintar['type'] = np.sign(df_pintar['type'])
		df_pintar['i'] = df_pintar['i'].astype(int)
		df_pintar.plot.scatter('X', 'Y', c='Diameter', colormap='jet', s=0.2)
		OD_position = df_OD[df_OD['image']==imgname]

		angle = np.arange(0, 360, 0.01)

		df_pintar['X'] = df_pintar['X'].round(0)
		df_pintar['Y'] = df_pintar['Y'].round(0)
		auxiliar_angle = []
		df_final_points = pd.DataFrame([])

		# RADIOS
		radius = [240, 250, 260, 270, 280, 290]
		for p in range(len(radius)):
			x = radius[p] * np.cos(angle) + OD_position['x']
			y = radius[p] * np.sin(angle) + OD_position['y']
			df_circle = pd.DataFrame([])
			df_circle['X'] = x.round(0)
			df_circle['Y'] = y.round(0)
			new_df = pd.merge(df_circle, df_pintar, how='inner', left_on=['X', 'Y'], right_on=['X', 'Y'])
			new_df_2 = new_df.drop_duplicates(subset=['i'], keep='last')
			new_df_veins = new_df_2[new_df_2["type"] == -1]
			new_df_veins = new_df_veins.sort_values(by=['Diameter'], ascending=False)
			auxiliar = []
			df_potential_vein_points = pd.DataFrame([])

			for i in range(len(new_df_veins)-1):
				for j in range(len(new_df_veins)-2):
					lineA = ((OD_position['x'], OD_position['y']), (new_df_veins['X'].iloc[i], new_df_veins['Y'].iloc[i]))
					lineB = ((OD_position['x'], OD_position['y']), (new_df_veins['X'].iloc[j], new_df_veins['Y'].iloc[j]))
					if i == j:
						continue
					else:
						angulo = ang(lineA, lineB)
						angulo = round(angulo, 0)
						data = {
							'X_1': new_df_veins['X'].iloc[i],
							'Y_1': new_df_veins['Y'].iloc[i],
							'Diameter_1': new_df_veins['Diameter'].iloc[i],
							'type_1': new_df_veins['type'].iloc[i],
							'i_1': new_df_veins['i'].iloc[i],
							'X_2': new_df_veins['X'].iloc[j],
							'Y_2': new_df_veins['Y'].iloc[j],
							'Diameter_2': new_df_veins['Diameter'].iloc[j],
							'type_2': new_df_veins['type'].iloc[j],
							'i_2': new_df_veins['i'].iloc[j],
							'angle': angulo
						}
						auxiliar.append(data)
			df_potential_vein_points = pd.DataFrame(auxiliar)
			aux_isempty = df_potential_vein_points.empty
			if aux_isempty:
				d = {'X_1': 0, 'Y_1': 0, 'Diameter_1': 0, 'type_1': 0, 'i_1': 0, 'X_2': 0, 'Y_2': 0, 'Diameter_2': 0, 'type_2': 0, 'i_2': 0, 'angle': 0}
				Main_angle1 = pd.Series(data=d, index=['X_1', 'Y_1', 'Diameter_1', 'type_1', 'i_1', 'X_2', 'Y_2', 'Diameter_2', 'type_2', 'i_2', 'angle'])
				pass
			else:
				df_angles_1 = df_potential_vein_points[(df_potential_vein_points["angle"] >= 90) & (df_potential_vein_points["angle"] <= 230)]
				df_angles_1 = df_angles_1.sort_values(['Diameter_1', 'Diameter_2'], ascending=[False, False])
				isempty = df_angles_1.empty
				if isempty:
					d = {'X_1': 0, 'Y_1': 0, 'Diameter_1': 0, 'type_1': 0, 'i_1': 0, 'X_2': 0, 'Y_2': 0, 'Diameter_2': 0, 'type_2': 0, 'i_2': 0, 'angle': 0}
					Main_angle1 = pd.Series(data=d, index=['X_1', 'Y_1', 'Diameter_1', 'type_1', 'i_1', 'X_2', 'Y_2', 'Diameter_2', 'type_2', 'i_2', 'angle'])
					pass
				else:
					Main_angle1 = df_angles_1.iloc[0]

			data_angle = {
				'X_1': Main_angle1['X_1'],
				'Y_1': Main_angle1['Y_1'],
				'Diameter_1': Main_angle1['Diameter_1'],
				'X_2': Main_angle1['X_2'],
				'Y_2': Main_angle1['Y_2'],
				'Diameter_2': Main_angle1['Diameter_2'],
				'angle': Main_angle1['angle']
			}
			auxiliar_angle.append(data_angle)

		df_final_points = pd.DataFrame(auxiliar_angle)

		df_final_points['vote_angle'] = -999

		df_final_vote = df_final_points.copy()
		df_final_vote['vote_angle'].loc[0] = 0
		for s in range(len(df_final_vote)-1):
			m = s+1
			df_final_vote['vote_angle'].loc[m] = m

		for i in range(len(df_final_vote)-1):
			for j in range(len(df_final_vote)):
				if (df_final_vote['angle'].loc[i+1]>= df_final_vote['angle'].loc[j] - 15) and (df_final_vote['angle'].loc[i+1]<= df_final_vote['angle'].loc[j] + 2):
					df_final_vote['vote_angle'].loc[i+1] = j
					break

		df_final_vote = df_final_vote[df_final_vote['vote_angle'] == df_final_vote.mode()['vote_angle'][0]]

		if len(df_final_vote)>=3:
			Mean_angle=df_final_vote['angle'].mean().round(0)
			if Mean_angle==0.0:
				Mean_angle=None
		else:
			Mean_angle=None

		return Mean_angle

	except Exception as e:
		print(e)
		return np.nan


def getNeovascularizationOD(imgname, df_OD):
	
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
		df_pintar = pd.DataFrame([])
		df_pin = pd.DataFrame([])
		aux = int(df.count(axis=0))

		for i in range(aux):
			df_pin = pd.DataFrame(X[i])
			df_pin["Y"] = pd.DataFrame(Y[i])
			df_pin["type"] = segmentStats[i]
			df_pin["i"] = i
			df_pintar = df_pintar.append(df_pin, True)

		df_pintar.columns = ['X', 'Y', 'type', 'i']
		df_pintar['type'] = np.sign(df_pintar['type'])
		df_pintar['i'] = df_pintar['i'].astype(int)
		OD_position = df_OD[df_OD['image']==imgname]
    
		angle = np.arange(0, 360, 0.01)
		radius = 280
		x = radius * np.cos(angle) + OD_position['x']
		y = radius * np.sin(angle) + OD_position['y']

		df_circle = pd.DataFrame([])
		df_circle['X'] = x.round(0)
		df_circle['Y'] = y.round(0)
		df_pintar['DeltaX'] = df_pintar['X'] - OD_position['x']
		df_pintar['DeltaY'] = df_pintar['Y'] - OD_position['y']
		df_pintar['r2_value'] = df_pintar['DeltaX']*df_pintar['DeltaX'] + df_pintar['DeltaY']*df_pintar['DeltaY']
		df_pintar['r_value'] = (df_pintar['r2_value'])**(1/2)

		df_vessel_pixels_OD = df_pintar[df_pintar['r_value'] <= radius]
		pixels_fraction = len(df_vessel_pixels_OD)/len(df_pintar)
		pixels_fraction = round(pixels_fraction, 2)
		pixels_close_OD = len(df_vessel_pixels_OD)
		pixels_close_OD = round(pixels_close_OD, 2)
		return pixels_close_OD, pixels_fraction

	except Exception as e:
		print(e)
		return np.nan



def getNumGreenPixels(imgname):

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

        df_pintar = pd.DataFrame([])
        df_pin = pd.DataFrame([])
        aux = int(df.count(axis=0))

        for i in range(aux):
            df_pin = pd.DataFrame(X[i])
            df_pin["Y"] = pd.DataFrame(Y[i])
            df_pin["type"] = segmentStats[i]
            df_pin["i"] = i
            df_pintar = df_pintar.append(df_pin, True)

        df_pintar.columns = ['X', 'Y', 'type', 'i']
        df_pintar['type'] = np.sign(df_pintar['type'])
        df_type_0 = df_pintar[df_pintar["type"] == 0]
        num_green_pixels = len(df_type_0)
        print(num_green_pixels)

        return num_green_pixels

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
	# file with OD
	df_OD = pd.read_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/OD_position_11_02_2022.csv", sep=',')
	df_OD = df_OD.dropna(subset=['center_x_y'])
	
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
	out = pool.map(getNumGreenPixels, imgfiles[0:testLen])
	
	# storing the phenotype	
	
	# fractal dimension
	# df = pd.DataFrame(out, columns=["FD_all", "FD_artery", "FD_vein"])
	
	# Number of bifurcations
	#df = pd.DataFrame(out, columns=["bifurcations"])

	# Temporal Venular Angle
	#df = pd.DataFrame(out, columns=["tVA"])
	
	#  Neovascularization OD
	df = pd.DataFrame(out, columns=["pixels_close_OD", "pixels_close_OD_over_total"])

	#  Number of green pixels	
	#df = pd.DataFrame(out, columns=["N_total_green_pixels"])

	df=df.set_index(imgfiles[0:testLen])

	# ARIA phenotypes
	#first_statsfile = pd.read_csv(aria_measurements_dir + "1027180_21015_0_0_all_segmentStats.tsv", sep='\t')
	#cols = first_statsfile.columns
	#cols_full = [i + "_all" for i in cols] + [i + "_artery" for i in cols] + [i + "_vein" for i in cols]\
	#  + [i + "_longestFifth_all" for i in cols] + [i + "_longestFifth_artery" for i in cols] + [i + "_longestFifth_vein" for i in cols]\
	#  + ["nVessels"]
	#df = pd.DataFrame(out, columns=cols_full)
	#df.index = imgfiles[0:testLen]
	print(len(df), "image measurements taken")
	print("NAs per phenotype")
	print(df.isna().sum())

	df.to_csv(phenotype_dir + datetime.today().strftime('%Y-%m-%d') + '_NeovascularizationOD_phenotypes.csv')

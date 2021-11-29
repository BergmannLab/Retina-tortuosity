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
		img.save('/home/mbeyele5/im1.png')
		img_artery.save('/home/mbeyele5/im2.png')
		img_vein.save('/home/mbeyele5/im3.png')
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


if __name__ == '__main__':
	
	# command line arguments
	qcFile = sys.argv[1]
	phenotype_dir = sys.argv[2]
	aria_measurements_dir = sys.argv[3]
	lwnet_dir = sys.argv[4]

	#QC
	imgfiles = pd.read_csv(qcFile, header=None) # images that pass QC of choice
	imgfiles = imgfiles[0].values

	# development param
	testLen = len(imgfiles) # len(imgs) is default	

	#computing the phenotype as a parallel process
	os.chdir(lwnet_dir)	
	pool = Pool()
	out = pool.map(getFractalDimension, imgfiles[0:testLen])
	
	# storing the phenotype	
	df = pd.DataFrame(out, columns=["FD_all", "FD_artery", "FD_vein"])
	df=df.set_index(imgfiles[0:testLen])
	df.to_csv(phenotype_dir + datetime.today().strftime('%Y-%m-%d') + '_fractalDimension.csv')

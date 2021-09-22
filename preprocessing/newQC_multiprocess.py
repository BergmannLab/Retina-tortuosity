import sys,os

from multiprocessing import Pool
from matplotlib import pyplot as plt

import pandas as pd
import numpy as np
import cv2

DILATION_SIZE = 1
MASK_RADIUS=660 # works for UKBB images
RESIZE_RADIUS = 500
BLOT_QUANTILE=0.01
BLOT_THRESHOLD=0.12
LIGHT_BLOT_THRESHOLD=0.99

def mask_image(img, toGray=False):
  hh,ww=img.shape[:2]
  #print(hh//2,ww//2)

  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

  mask = np.zeros_like(gray)
  mask = cv2.circle(mask, (ww//2,hh//2), RESIZE_RADIUS, (255,255,255), -1)
  #mask = np.invert(mask.astype(bool))

  #result = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)
  #result[:, :] = mask[:,:]
#  result[:, :, 3] = mask[:,:,0]
  #plt.imshow(result)
  
  if toGray == True:
    return np.ma.array(gray, mask=np.invert(mask.astype(bool)))
  else:
    return np.ma.array(img, mask=np.invert(mask.astype(bool)))

def blot_size(img, lightBlot=False):

  if lightBlot==True:
    thresh=LIGHT_BLOT_THRESHOLD
  else:
    thresh=BLOT_THRESHOLD

  gray = mask_image(img, toGray=True)
  #gray = cv2.cvtColor(masked, cv2.COLOR_BGR2GRAY)
  nGray = gray.copy()
  #quantile = np.quantile(gray[gray.mask==False], BLOT_QUANTILE)
  #print(quantile)

  #nGray[nGray == 0] = 1
  #plt.hist(nGray)
  nGray[nGray.mask == True] = 1

  if lightBlot==False:
    nGray[(nGray<thresh) & (nGray.mask == False)] = 0
  else:
    nGray[(nGray>thresh) & (gray.mask == False)] = 0 #sic gray not nGray

  kernel = np.ones((DILATION_SIZE, DILATION_SIZE), 'uint8')
  dilate_img = cv2.erode(nGray, kernel, iterations=1)
  view = dilate_img.copy()
  view[view==0] = 0.8


  #nGray[nGray==0] = 1
  #compare_image(img,view)

  #binary = cv2.threshold(dilate_img, 0, 255, cv2.THRESH_BINARY)[1]
  binary = (dilate_img > 0).astype(np.uint8)
  binary = 1-binary
  connectivity = 4
  num_labels,labels,surfaceStats,centroids = cv2.connectedComponentsWithStats(binary, connectivity, cv2.CV_32S)
  try:
    if lightBlot==False:
      return np.max(surfaceStats[1:,4])
    else:
      #print(surfaceStats)
      return np.sum(surfaceStats[1:,4]) # sum not max, as I want to know total saturation area
  except:
    return 0

def compute_stats(myf):

    img = plt.imread(myf)
    width = img.shape[1]
    height = img.shape[0]
    img = cv2.resize(img, (int(width*RESIZE_RADIUS/MASK_RADIUS), int(height*RESIZE_RADIUS/MASK_RADIUS)))
    
    mskd_img = mask_image(img,toGray=True)

    imean=mskd_img.mean()*255
    istdev=mskd_img.std()*255 / imean
    iblot_size=blot_size(img,lightBlot=False)
    iblot_size_light=blot_size(img,lightBlot=True)

    return myf, imean,istdev,iblot_size,iblot_size_light

if __name__ == '__main__':

    rawdir="/HDD/data/UKBB/fundus/raw/"
    rawfiles = sorted(os.listdir(rawdir))
    #rawfiles = rawfiles[0:500]
    myf = [rawdir+i for i in rawfiles]

    pool = Pool()                         # Create a multiprocessing Pool
    out = pool.map(compute_stats, myf)
    data = pd.DataFrame(out, columns=['file', 'mean', 'sdev', 'blot_size','light_blot_size'])
    data['file'] = rawfiles
    data.to_csv("/HDD/data/UKBB/fundus/qcStats/newQC_rawStats.csv")
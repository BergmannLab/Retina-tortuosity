#%%
import os, pathlib
import sys
from datetime import datetime
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.image as mpimg
from matplotlib import cm
import cv2
import csv

os.chdir(sys.path[0])

# METHODS
def eucl_dist(x_1,y_1,x_2,y_2):

    return np.sqrt((x_1-x_2)**2 + (y_1-y_2)**2)

def dist_to_disc_center(pos1, pos2, center):
    return min(eucl_dist(pos1[0], pos2[0], center[0], center[1]), eucl_dist(pos1[-1], pos2[-1], center[0], center[1]))

def crop_image(img,tol=0.1):
    # img is 2D image data
    # tol  is tolerance
    mask = img>tol
    half_0 = img.shape[0] // 2
    half_1 = img.shape[1] // 2

    mask_topleft = mask[0:half_0, 0:half_1]
    remaining_topleft = mask_topleft[np.ix_(mask_topleft.any(1),mask_topleft.any(0))]
    # plt.figure()
    # plt.imshow(mask_topleft)
    # plt.title('original')
    # plt.figure()
    # plt.imshow(remaining_topleft)
    # plt.title('remaining')
    cut_top = mask_topleft.shape[0] - remaining_topleft.shape[0]
    cut_left = mask_topleft.shape[1] - remaining_topleft.shape[1]

    return img[np.ix_(mask.any(1),mask.any(0))], cut_top, cut_left

def crop_left(img):
    shape = img.shape
    third_0 = img.shape[0] // 3
    third_1 = img.shape[1] // 3

    return img[third_0:third_0*2, 0:third_1]

def crop_right(img):
    shape = img.shape
    third_0 = img.shape[0] // 3
    third_1 = img.shape[1] // 3

    return img[third_0:third_0*2, 2*third_1:]

def blur_image(img, size=250):
    kernel = np.ones((size,size),np.float32)/(size**2)
    dst = cv2.filter2D(img,-1,kernel)
    # plt.imshow(dst)

    [y_max, x_max] = np.where(dst == np.max(dst))
    thres = 0.99 * np.max(dst)
    thres_mask = dst >= thres
    [y,x] = np.where(thres_mask)
    # print(y)
    # print(x)
    xmean = np.mean(x)
    ymean = np.mean(y)
    print(img.shape)
    print(dst.shape)
    # plt.subplot(121),plt.imshow(img),plt.title('Original')
    # plt.xticks([]), plt.yticks([])
    # plt.scatter(xmean, ymean, c='red')
    # plt.subplot(122),plt.imshow(dst),plt.title('Averaging')
    # plt.scatter(x, y, 0.5, c='orange')
    # plt.xticks([]), plt.yticks([])
    # plt.show()

    return([int(xmean), int(ymean)])

DATE = datetime.now().strftime("%Y_%m_%d")# CONSTANTS
MAX_DIST_TO_DISC_CENTER = 300
MIN_LENGTH_FINAL = 200
SEGMENT_DISTANCE = 5

input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/"
# input_dir = "/Users/mbeyele5/retina_tortuosity/data/2021_02_22_rawMeasurements/"
image_dir = "/data/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/REVIEW/CLRIS/"
# image_dir = "/Users/mbeyele5/retina_tortuosity/data/rawMeasurements_first50Images/"
output_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/" + DATE + "_majorVessels/"
# output_dir = "/Users/mbeyele5/Desktop/tmp/"

imageIDs= []
with open("imageIDs.txt") as file:
    for i, line in enumerate(file):
        try:
            if((i>=int(sys.argv[1])) & (i<=int(sys.argv[2]))):
                imageIDs.append(line.rstrip('\n'))
        except:
            imageIDs.append(line.rstrip('\n'))


os.chdir(input_dir)
pathlib.Path(output_dir).mkdir(parents=False, exist_ok=True)



for imageID in imageIDs:
    print(imageID)
    
    pos1 = []
    pos2 = []
    with open(imageID + "_all_rawXCoordinates.tsv") as f:
        for line in f:
            pos1.append([float(i) for i in line.rstrip().split(sep='\t')])
    with open(imageID + "_all_rawYCoordinates.tsv") as f:
        for line in f:
            pos2.append([float(i) for i in line.rstrip().split(sep='\t')])
    
    segmentStats = pd.read_csv(imageID + "_all_segmentStats.tsv", sep='\t')
    AVScores = segmentStats['AVScore'].tolist()
    medianDiameters = segmentStats['medianDiameter'].tolist()
    DFs = segmentStats['DF'].tolist()


    img = mpimg.imread(image_dir + imageID + ".png")

    # optic nerve center
    if "21015" in imageID:
        leftRight = 0
    else:
        leftRight = 1

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray, cut_top, cut_left = crop_image(gray)

    if leftRight == 0:
        nerve = crop_left(gray)
    else:
        nerve = crop_right(gray)
    center = blur_image(nerve, 200)

    # reconstructing the center position for the original image
    center[1] = center[1] + cut_top + gray.shape[0]//3
    center[0] = center[0] + cut_left
    
    if leftRight == 1:
        center[0] = center[0] + 2 * gray.shape[1]//3

    tmp = [center[1], center[0]]
    center = tmp

    # REORDERING SEGMENTS BY DISTANCE TO OPTIC NERVE CENTER
    dists = []
    for i in range(0,len(pos1)):
        dists.append(dist_to_disc_center(pos1[i], pos2[i], center))
    dists = np.array(dists)
    sorted_index = np.argsort(dists)

    pos1 = np.array(pos1)
    pos1 = pos1[sorted_index].tolist()
    pos2 = np.array(pos2)
    pos2 = pos2[sorted_index].tolist()
    AVScores = np.array(AVScores)
    AVScores = AVScores[sorted_index].tolist()
    medianDiameters = np.array(medianDiameters)
    medianDiameters = medianDiameters[sorted_index].tolist()
    DFs = np.array(DFs)
    DFs = DFs[sorted_index].tolist()

    seg_pixel_distance = SEGMENT_DISTANCE
    print(len(pos1))
    exit_status = 1
    while exit_status == 1:
        break_out = False
        
        for i in range(0,len(pos1)):
            candidates = []
            candidates_type = []
            for j in range(i+1, len(pos1)):
                # print(i,j, eucl_dist(pos1[i][-1], pos2[i][-1], pos1[j][0], pos1[j][0]), eucl_dist(pos1[i][0], pos2[i][0], pos1[j][-1], pos1[j][-1]))
                
                if (eucl_dist(pos1[i][-1], pos2[i][-1], pos1[j][0], pos2[j][0]) < seg_pixel_distance) & (np.sign(AVScores[i]) == np.sign(AVScores[j])):
                    candidates.append(j)
                    candidates_type.append(0)

                elif (eucl_dist(pos1[i][0], pos2[i][0], pos1[j][-1], pos2[j][-1]) < seg_pixel_distance) & (np.sign(AVScores[i]) == np.sign(AVScores[j])):
                    candidates.append(j)
                    candidates_type.append(1)
            
            if candidates != []:

                chosen_index = candidates[0]
                chosen_type = candidates_type[0]
                for k, candidate in enumerate(candidates[1:]):
                    if medianDiameters[k] > medianDiameters[chosen_index]:
                        chosen_index = candidate
                        chosen_type = candidates_type[k]

    

                # removing segments that have been merged from the initial list
                # chosen_type = 0: beginning of 2nd segemnt added to end of 1st segment
                # chosen_type = 1: beginning of 1st segment added to end of 2nd segment
                if chosen_type == 0:
                    # print(chosen_index, chosen_type, i)
                    pos1[i] = pos1[i] + pos1[chosen_index]
                    pos2[i] = pos2[i] + pos2[chosen_index]
                    medianDiameters[i] = (medianDiameters[i] * len(pos1[i]) + medianDiameters[chosen_index] * len(pos1[chosen_index])) / (len(pos1[i]) + len(pos1[chosen_index]))
                    DFs[i] = (DFs[i] * len(pos1[i]) + DFs[chosen_index] * len(pos1[chosen_index])) / (len(pos1[i]) + len(pos1[chosen_index]))
                    AVScores.pop(chosen_index)
                    medianDiameters.pop(chosen_index)
                    DFs.pop(chosen_index)
                    pos1.pop(chosen_index)
                    pos2.pop(chosen_index)
                    break_out = True
                    # print('hi')

                else:
                    pos1[i] = pos1[chosen_index] + pos1[i]
                    pos2[i] = pos2[chosen_index] + pos2[i]
                    medianDiameters[i] = (medianDiameters[i] * len(pos1[i]) + medianDiameters[chosen_index] * len(pos1[chosen_index])) / (len(pos1[i]) + len(pos1[chosen_index]))
                    DFs[i] = (DFs[i] * len(pos1[i]) + DFs[chosen_index] * len(pos1[chosen_index])) / (len(pos1[i]) + len(pos1[chosen_index]))
                    AVScores.pop(chosen_index)
                    medianDiameters.pop(chosen_index)
                    DFs.pop(chosen_index)
                    pos1.pop(chosen_index)
                    pos2.pop(chosen_index)
                    break_out = True
                    # print('hooray')
            
            # if break_out == True:
            #     break
        if break_out == False:
            exit_status = 0
    
    print(len(pos1))


    # plt.figure()
    # plt.imshow(img)
    # plt.scatter(center[1], center[0])
    # plt.savefig(output_dir + imageID + ".png")

    # plotting all segments, to see how they were linked
    len_top_artery = 0
    len_top_vein = 0
    len_bottom_artery = 0
    len_bottom_vein = 0
    top_artery_index = -1
    bottom_artery_index = -1
    top_vein_index = -1
    bottom_vein_index = -1

    for i in range(0,len(pos1)):

        # if AVScores[i] > 0:
        #     plt.scatter(pos2[i], pos1[i], s=0.5, c='red')
        # elif AVScores[i] < 0:
        #     plt.scatter(pos2[i], pos1[i], s=0.5, c='blue')
        # else:
        #     plt.scatter(pos2[i], pos1[i], s=0.5, c='purple')

        # one artery and vein on top and bottom each, SELECTED FOR MAX LENGTH
        # if (dist_to_disc_center(pos1[i],pos2[i],center) < MAX_DIST_TO_DISC_CENTER):
        #     if (np.mean(pos1[i]) < center[0]) & (AVScores[i] > 0):
        #         if len(pos1[i]) > len_top_artery:
        #             len_top_artery = len(pos1[i])
        #             top_artery_index = i
        #     elif (np.mean(pos1[i]) > center[0]) & (AVScores[i] > 0):
        #         if len(pos1[i]) > len_bottom_artery:
        #             len_bottom_artery = len(pos1[i])
        #             bottom_artery_index = i
        #     elif (np.mean(pos1[i]) < center[0]) & (AVScores[i] < 0):
        #         if len(pos1[i]) > len_top_vein:
        #             len_top_vein = len(pos1[i])
        #             top_vein_index = i
        #     elif (np.mean(pos1[i]) > center[0]) & (AVScores[i] < 0):
        #         if len(pos1[i]) > len_bottom_vein:
        #             len_bottom_vein = len(pos1[i])
        #             bottom_vein_index = i
        
        # SELECTED FOR MAX THICKNESS, given longer than minimal length
        if (len(pos1[i]) > MIN_LENGTH_FINAL) & (dist_to_disc_center(pos1[i],pos2[i],center) < MAX_DIST_TO_DISC_CENTER):
            if (np.mean(pos1[i]) < center[0]) & (AVScores[i] > 0):
                if medianDiameters[i] > len_top_artery:
                    len_top_artery = medianDiameters[i]
                    top_artery_index = i
            elif (np.mean(pos1[i]) > center[0]) & (AVScores[i] > 0):
                if medianDiameters[i] > len_bottom_artery:
                    len_bottom_artery = medianDiameters[i]
                    bottom_artery_index = i
            elif (np.mean(pos1[i]) < center[0]) & (AVScores[i] < 0):
                if medianDiameters[i] > len_top_vein:
                    len_top_vein = medianDiameters[i]
                    top_vein_index = i
            elif (np.mean(pos1[i]) > center[0]) & (AVScores[i] < 0):
                if medianDiameters[i] > len_bottom_vein:
                    len_bottom_vein = medianDiameters[i]
                    bottom_vein_index = i
        
        
        if top_artery_index != -1:
            top_artery = DFs[top_artery_index]
        else:
            top_artery = np.nan
        
        if bottom_artery_index != -1:
            bottom_artery = DFs[bottom_artery_index]
        else:
            bottom_artery = np.nan
        if top_vein_index != -1:
            top_vein = DFs[top_vein_index]
        else:
            top_vein = np.nan
        if bottom_vein_index != -1:
            bottom_vein = DFs[bottom_vein_index]
        else:
            bottom_vein = np.nan

        arteries_mean = np.nanmean([top_artery, bottom_artery])
        veins_mean = np.nanmean([top_vein, bottom_vein])
        all_mean = np.mean([arteries_mean, veins_mean])

    # plt.figure()
    # plt.imshow(img)
    # plt.scatter(pos2[top_artery_index], pos1[top_artery_index], s=0.5, c='red')
    # plt.scatter(pos2[bottom_artery_index], pos1[bottom_artery_index], s=0.5, c='red')
    # plt.scatter(pos2[top_vein_index], pos1[top_vein_index], s=0.5, c='blue')
    # plt.scatter(pos2[bottom_vein_index], pos1[bottom_vein_index], s=0.5, c='blue')
    # plt.savefig(output_dir + imageID + "_2.png")


    print(top_artery_index, bottom_artery_index, top_vein_index, bottom_vein_index)
    with open(output_dir + imageID + "_all_imageStats.tsv", 'w') as f:
        f.write("major_mean\tmajor_arteries\tmajor_veins\ttop_artery\tbottom_artery\n")
        
        f.write("%s\t" % all_mean)
        f.write("%s\t" % arteries_mean)
        f.write("%s\t" % veins_mean)
        f.write("%s\t" % top_artery)
        f.write("%s\n" % bottom_artery)

import cv2
import PIL.Image
import glob
import os
import matplotlib.pyplot as plt
import numpy as np
import time

def loadImages(image_dir):
	filename_list = [image_dir+l for l in os.listdir(image_dir)]
	return filename_list

def FilterID(file_list,id_file):
	f_object = open(id_file,"r")
	f_object.readline()
	id_list = []
	for line in f_object:
		id_list.append(line.strip("\n"))
	file_list_id = [filename.split("/")[-1].split("_")[0] for filename in file_list]
	select_id = []
	st = time.time()
	for idx,f_id in enumerate(file_list_id):
		if idx % 1000 == 0:
			print(idx,time.time()-st)
		if f_id in id_list:
			select_id.append(idx)
	file_list = np.asarray(file_list)[select_id]
	return file_list

def CompressImages(image_list,output_dir,plot=False):
	start_time = time.time()
	for image_idx,image in enumerate(image_list):
		if image_idx % 10 == 0:
			print("Processed :",image_idx)
			print("Current runtime :",time.time()-start_time)
		subject_id = image.split("/")[-1].split("_")[0]
		io=cv2.cvtColor(cv2.imread(image),cv2.COLOR_BGR2RGB)
		interp_method=PIL.Image.BICUBIC
		io = cv2.resize(io, dsize=(224, 224), interpolation=interp_method)
		np.save(output_dir+"compressed_"+str(subject_id),io)
		if plot:
			plt.imshow(io)
			plt.savefig(output_dir+"test_"+str(subject_id)+".png")

if __name__ == "__main__":
	All_AV_maps="/data/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/AV_maps/"

	input_dir = All_AV_maps
	output_dir="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/utils/BuildAll/"
	image_list = FilterID(loadImages(input_dir),"tortuosity_paper_patient_ids.csv")
	CompressImages(image_list,output_dir)
	print("Preprocessing complete")

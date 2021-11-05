import tables
import numpy as np

data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/all_images/retina_all.pytable"
#data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_train.pytable"
#load patient ids
pytables_data = tables.open_file(data_path,'r')
patient_id = pytables_data.root.filenames.read()
pytables_data.close()

#print(patient_id[:20])
#p_id = np.asarray([int(str(patient_id[index]).split("/")[-1].split("_")[0]) for index in range(len(patient_id))])
p_id = np.asarray([int(str(patient_id[index]).split("/")[-1].split("_")[0]) for index in range(len(patient_id)) if b"_21015_" in patient_id[index] and b"_seg" in patient_id[index]])

p_id = np.asarray([patient_id[index] for index in range(len(patient_id)) if b"_21015" in patient_id[index] and b"_bin_seg" in patient_id[index]])
#print(p_id[:10])

p_id = []
for index in range(len(patient_id)):
	if b"_21015" in patient_id[index] and b"_bin_seg" in patient_id[index]:
		p_id.append(True)
	else:
		p_id.append(False)
print(p_id[:10])
print(patient_id[:10])

for i,p_bool in enumerate(p_id):
	if p_bool == False:
		continue
exit()

#extract tortuosity ID list
def extract_id(id_filename):
	f_object = open(id_filename,"r")
	id_list = []
	for line in f_object:
		id_list.append(int(line.strip("\n").split("_")[0]))
	f_object.close()
	return id_list

ID = extract_id('tort_id.csv')

print(p_id[:10])
print(len(set(ID).intersection(p_id)))
tort_id = p_id[np.in1d(p_id,ID)]
print(np.sum(np.in1d(p_id,ID)))

p_id = np.asarray([index for index in range(len(patient_id)) if b"_21015" in patient_id[index] and b"bin_seg" in patient_id[index]])
print("num file names = ",len(np.unique(p_id)))
p_id = np.asarray([int(str(patient_id[index]).split("/")[-1].split("_")[0]) for index in range(len(patient_id)) if b"_21015" in patient_id[index] and b"bin_seg" in patient_id[index]])
print("num unique ids = ",len(np.unique(p_id)))
print(len(set(ID).intersection(p_id)))
tort_id = p_id[np.in1d(p_id,ID)]
print(np.sum(np.in1d(p_id,ID)))

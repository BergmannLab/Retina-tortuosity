import tables

def get():
	data_label="train"

	data_path = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/retina_%s.pytable"%(data_label,)

	pytables_data = tables.open_file(data_path,'r')
	patient_id = pytables_data.root.filenames.read()
	pytables_data.close()
	return pytables_data, patient_id

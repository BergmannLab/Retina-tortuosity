import pandas as pd
import os as os
from shutil import copyfile

def copyFileList(eid_list, images_dir, output_dir, limit):
    copied = 0
    for items in eid_list.iteritems():
        eid = items[1]
        # we select only one of the two eyes
        pics = [images_dir +"/"+ str(eid) + '_21015_0_0_bin_seg.png',  # (A/V-segmented image) L eye, baseline 
                images_dir +"/"+ str(eid) + '_21015_1_0_bin_seg.png',  # (A/V-segmented image) L eye, followup
                images_dir +"/"+ str(eid) + '_21016_0_0_bin_seg.png',  # (A/V-segmented image) R eye, baseline
                images_dir +"/"+ str(eid) + '_21016_1_0_bin_seg.png',  # (A/V-segmented image) R eye, followup
                images_dir +"/"+ str(eid) + '_21015_0_0.png',  # (original image) L eye, baseline 
                images_dir +"/"+ str(eid) + '_21015_1_0.png',  # (original image) L eye, followup
                images_dir +"/"+ str(eid) + '_21016_0_0.png',  # (original image) R eye, baseline
                images_dir +"/"+ str(eid) + '_21016_1_0.png'] # (original image) R eye, followup
        for pic in pics:
            try:
                copyfile(pic, output_dir+"/"+os.path.basename(pic))
                copied = copied+1
            except:
                pass
            if copied>=limit: return;

def BuildDataset(output_dir, images_dir, case_control_list, limit):
    # split eids into case/control
    case_control_df = pd.read_csv(case_control_list)
    cases_eid  = case_control_df.loc[case_control_df['Class'] == "c0"]["eid"]
    controls_eid = case_control_df.loc[case_control_df['Class'] == "c1"]["eid"]

    # copy cases
    copyFileList(cases_eid, images_dir, output_dir+"/cases", limit)
    copyFileList(controls_eid, images_dir, output_dir+"/controls", limit)

def main():
    print("Starting to build Dataset")
    output_dir = os.sys.argv[1]
    images_dir = os.sys.argv[2]
    case_control_list = os.sys.argv[3]
    limit = int(os.sys.argv[4])
    BuildDataset(output_dir, images_dir, case_control_list, limit)
    print("done")

if __name__== "__main__":
    main()



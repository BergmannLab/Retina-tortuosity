import csv
import pandas as pd
import numpy as np
import glob
import os
import csv
import os
import sys
from datetime import datetime
from matplotlib import pyplot as plt
import matplotlib.image as mpimg
from matplotlib import cm


# os.chdir('/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/')

input_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/"
output_dir = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_03_cross/"
print(output_dir)
imageIDs= []
with open("imageIDs.txt") as file:
    for i, line in enumerate(file):
        if((i>=int(sys.argv[1])) & (i<=int(sys.argv[2]))):
            imageIDs.append(line.rstrip('\n'))
print(imageIDs)


os.chdir(input_dir)
try:
    os.mkdir(output_dir)
except Exception as e:
    print(e)


for imageID in imageIDs:
# for img in glob.glob("*_all_rawXCoordinates.tsv"):
#    img = img.split("_all_")
#    imageID = img[0]
#   print(img)
    # To load segments
    X = []
    Y = []
    segmentStats = []

    with open(imageID + "_all_rawXCoordinates.tsv") as fd:
        rd = csv.reader(fd, delimiter='\t')
        for row in rd:
            X.append([float(j) for j in row])

    with open(imageID + "_all_rawYCoordinates.tsv") as fd:
        rd = csv.reader(fd, delimiter='\t')
        for row in rd:
            Y.append([float(j) for j in row])

    with open(imageID + "_all_segmentStats.tsv") as fd:
        rd = pd.read_csv(fd, sep='\t')
        segmentStats = rd["AVScore"]

    df = pd.DataFrame([])
    df["segmentStats"] = segmentStats

    df_results = pd.DataFrame([])
    df_aux = pd.DataFrame([])
    aux = int(df.count(axis=0))
    print("La mitad")

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

    pd.DataFrame([{'crossing': cross_counter}]).to_csv(output_dir + str(imageID) + '_all_stats.tsv',
                                                  sep='\t',
                                                  index=False,
                                                  header=True)
        



import pandas as pd
import random
import sys, os

N_SAMPLES = int(sys.argv[1]) #2
SAMPLE_SIZE = int(sys.argv[2]) #1000
ID = sys.argv[3]

PHENOFILE_DIR="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/GWAS/output/VesselStatsToPhenofile/"

df = pd.read_csv(PHENOFILE_DIR + "2021_02_22_rawMeasurements/phenofile_qqnorm.csv", delimiter=" ", dtype=str)

os.mkdir(PHENOFILE_DIR + ID)

# subjects with phenotypes
index = df.loc[df['DF'] != "-999"].index

# random sampling# Building phenofiles for each iteration, replacing most rows with -999.0 rows

for i in range(0,N_SAMPLES):
    delete_index = random.sample(list(index), len(index)-SAMPLE_SIZE)
    df_sub = df.copy()
    df_sub.iloc[delete_index] = "-999"
    
    os.mkdir(PHENOFILE_DIR +ID + "/" + str(i+1))
    df_sub.to_csv(PHENOFILE_DIR +ID + "/" + str(i+1) + "/phenofile_qqnorm.csv", index=False, sep=" ")



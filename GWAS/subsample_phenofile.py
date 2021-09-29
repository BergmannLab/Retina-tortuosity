import pandas as pd
import random
import sys, os

N_SAMPLES = int(sys.argv[1]) #2
SAMPLE_SIZE = int(sys.argv[2]) #1000
ID = sys.argv[3]

PHENOFILE_DIR="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/GWAS/output/VesselStatsToPhenofile/"

df = pd.read_csv(PHENOFILE_DIR + "2021_02_22_rawMeasurements/phenofile_qqnorm.csv", delimiter=" ", dtype=str)

#os.mkdir(PHENOFILE_DIR + ID)

# subjects with phenotypes
index = df.loc[df['DF'] != "-999"].index

# random sampling# Building phenofiles for each iteration, replacing most rows with -999.0 rows

# method by generating a phenofile for each iteration
#for i in range(0,N_SAMPLES):
#    delete_index = random.sample(list(index), len(index)-SAMPLE_SIZE)
#    df_sub = df.copy()
#    df_sub.iloc[delete_index] = "-999"
#    
#    os.mkdir(PHENOFILE_DIR +ID + "/" + str(i+1))
#    df_sub.to_csv(PHENOFILE_DIR +ID + "/" + str(i+1) + "/phenofile_qqnorm.csv", index=False, sep=" ")

# method by generating one phenofile
for i in range(0,N_SAMPLES):
    iteration_colnames=[str(i+1)+"_"+col for col in df.columns]
    delete_index = random.sample(list(index), len(index)-SAMPLE_SIZE)
    df_sub = df.copy()
    df_sub.iloc[delete_index] = "-999"
    df_sub.columns = iteration_colnames
    if i==0:
        df_out=df_sub.copy()
    else:
        concat=pd.concat([df_out, df_sub], axis=1)
        df_out=concat.copy()
df_out.to_csv(PHENOFILE_DIR +ID + "/phenofile_qqnorm.csv", index=False, sep=" ")

# CONFIG FILE for Retina pipeline

# RAW IMAGE DATA
ARIA_data_dir=/data/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/REVIEW/
raw_data_dir=$ARIA_data_dir/CLRIS/

# empirically determined quality threshold relative to vessel stat "length__TOT"
quality_thr=11000

# BuildTestDatasetHypertension
# number of hypertension cases in dataset 
# (twice as many controls will be added)
limit=1000

# config GPU usage for DL
# gpuid=-1 for CPU
gpuid=-1

# backups
archive=/stornext/CHUV1/archive/unilcbg/mtomason/
# location of raw data, software, and permanent pipeline outputs
data=/data/FAC/FBM/DBC/sbergman/
# location of scratch folder (all pipeline outputs and code)
scratch=/scratch/beegfs/FAC/FBM/DBC/sbergman/
# MATLAB
matlab_runtime=/software/Development/Languages/Matlab_Compiler_Runtime/96
# BGENIE
bgenie_dir=$data/retina/software/bgenie
# BGENIX
bgenix_dir=$data/retina/software/bgenix/gavinband-bgen-407eaf355425/build/apps/
# ARIA (compiled)
ARIA_dir=$data/retina/software/ARIA


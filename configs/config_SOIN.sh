# CONFIG FILE for Retina pipeline

# RAW IMAGE DATA
###ARIA_data_dir=/data/soin/retina/UKBiob/fundus/REVIEW/ # UKBB
###ARIA_data_dir=/data/soin/retina/SkiPOGH/fundus/REVIEW/ # SkiPOGH
ARIA_data_dir=/data/soin/retina/OphtalmoLaus/fundus/REVIEW/ # OphtalmoLaus
raw_data_dir=$ARIA_data_dir"CLRIS/"
raw_data_dir_av_test=$ARIA_data_dir/CLRIS_AV_test/

# quality thresholds for ARIA
min_QCthreshold_1=11000
max_QCthreshold_1=20000
min_QCthreshold_2=100
max_QCthreshold_2=250

# AV CLASSIFICATION IMAGE DATA
###AV_data_dir=/data/FAC/FBM/DBC/sbergman/retina/michael/uncertainty/ # AVUncertain UKBB
###AV_data_dir=/data/soin/retina/michael/ClassifyAVLwnet/ # Lwnet UKBB Jura
AV_data_dir=/data/soin/retina/OphtalmoLaus/AV_maps/ # Lwnet OphtalmoLaus SOIN

# quality thresholds of artery/vein classification
###AV_threshold=0.75 # A/V classification AUC around 0.95 (discard 30% of vessels with lowest classification score)
AV_threshold=0.0 # A/V classification AUC around 0.88 (consider all classified vessels)

# BuildTestDatasetHypertension
# number of hypertension cases in dataset
# (twice as many controls will be added)
#limit=1000

# config GPU usage for DL
# gpuid=-1 for CPU
gpuid=-1

# backups
archive=/data/soin/_archive/
# location of raw data, software, and permanent pipeline outputs
data=/data/soin/
# location of scratch folder (all pipeline outputs and code)
scratch=/data/soin/_scratch/
# MATLAB
matlab_runtime=/software/Development/Languages/Matlab_Compiler_Runtime/96
# BGENIE
bgenie_dir=$data/retina/software/bgenie
# BGENIX
bgenix_dir=$data/retina/software/bgenix/gavinband-bgen-407eaf355425/build/apps/
# ARIA (compiled)
ARIA_dir=$data/retina/software/ARIA
# ARIA with random AV calling (compiled)
ARIA_rndAVcalling_dir=$data/retina/software/ARIA_rndAVcalling
# conda
conda_dir=$data/retina/software/miniconda3/
# AV classification
av_uncertain_dir=$data/retina/software/a_v_uncertain-master/
lwnet_dir=$data/retina/software/lwnet/

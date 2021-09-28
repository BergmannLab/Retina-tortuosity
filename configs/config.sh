# CONFIG FILE for Retina pipeline

# GENOTYPE INFO
GENOTYPE_DIR=/data/FAC/FBM/DBC/sbergman/retina/UKBiob/genotypes/
# contain only participants whose eyes were imaged, to increase speed
COVAR_FILE=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/GWAS/output/ExtractCovariatePhenotypes/2020_10_03_final_covar/final_covar_fundus.csv
SAMPLE_FILE="$GENOTYPE_DIR"ukb_imp_v3_subset_fundus.sample

# RAW IMAGE DATA
ARIA_data_dir=/data/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/REVIEW/ # UKBB
###ARIA_data_dir=/data/FAC/FBM/DBC/sbergman/retina/SkiPOGH/fundus/REVIEW/ # SkiPOGH
raw_data_dir=$ARIA_data_dir"CLRIS/"
raw_data_dir_av_test=$ARIA_data_dir/CLRIS_AV_test/

# quality thresholds for ARIA
min_QCthreshold_1=11000
max_QCthreshold_1=20000
min_QCthreshold_2=100
max_QCthreshold_2=250

# AV CLASSIFICATION IMAGE DATA
###AV_data_dir=/data/FAC/FBM/DBC/sbergman/retina/michael/uncertainty/ # AVUncertain UKBB
AV_data_dir=/data/FAC/FBM/DBC/sbergman/retina/michael/ClassifyAVLwnet/ # Lwnet UKBB

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
archive=/stornext/CHUV1/archive/FAC/FBM/DBC/sbergman/retina/mtomason/
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
# ARIA with random AV calling (compiled)
ARIA_rndAVcalling_dir=$data/retina/software/ARIA_rndAVcalling
# conda
conda_dir=/data/FAC/FBM/DBC/sbergman/retina/software/miniconda3/
# AV classification
av_uncertain_dir=/data/FAC/FBM/DBC/sbergman/retina/software/a_v_uncertain-master/
lwnet_dir=/data/FAC/FBM/DBC/sbergman/retina/software/lwnet/

# OUTPUT DIRECTORIES
GWAS_DIR="$scratch"retina/GWAS/output/RunGWAS/

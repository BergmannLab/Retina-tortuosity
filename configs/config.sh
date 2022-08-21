# Config file for multitrait retina project



# FREQUENTLY MODIFIED
PHENOFILE_ID=2022_08_17_ventile4
NB_PCS=10 # if using uncorrected phenotypes: nb PCs used as covariates



# BASE DIRS
archive=/stornext/CHUV1/archive/FAC/FBM/DBC/sbergman/retina/
data=/data/FAC/FBM/DBC/sbergman/retina/
scratch=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/

# GENOTYPE INFO
GENOTYPE_DIR=$scratch/UKBiob/genotypes
SAMPLE_FILE="$GENOTYPE_DIR"/ukb_imp_v3_subset_fundus.sample

# RAW IMAGE DATA
ARIA_data_dir=$data/UKBiob/fundus/REVIEW/ # UKBB
#ARIA_data_dir=/data/FAC/FBM/DBC/sbergman/retina/SkiPOGH/fundus/REVIEW/ # SkiPOGH
raw_data_dir=$ARIA_data_dir"CLRIS/"
raw_archive_dir=$archive/UKBiob/fundus/REVIEW/CLRIS/
raw_data_dir_av_test=$ARIA_data_dir/CLRIS_AV_test/

ARIA_MEASUREMENTS_DIR=$scratch/preprocessing/output/backup/2021_10_06_rawMeasurements_withoutQC/
LWNET_DIR=$data/UKBiob/fundus/AV_maps/

# IMAGE_MEASUREMENTS
FUNDUS_PHENOTYPE_DIR=$scratch/UKBiob/fundus/fundus_phenotypes/


# QC
ALL_IMAGES=$data/UKBiob/fundus/index_files/noQC.txt
KEPT_IMAGES=$data/UKBiob/fundus/index_files_ageCorrectedQC/ageCorrected_ventiles5.txt
# quality thresholds for ARIA
#min_QCthreshold_1=11000
#max_QCthreshold_1=20000
#min_QCthreshold_2=100
#max_QCthreshold_2=250

# PHENOFILES
PHENOFILES_DIR=$scratch/UKBiob/fundus/phenofiles/

# AV CLASSIFICATION IMAGE DATA
###AV_data_dir=/data/FAC/FBM/DBC/sbergman/retina/michael/uncertainty/ # AVUncertain UKBB
AV_data_dir=$data/michael/ClassifyAVLwnet/ # Lwnet UKBB

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

# MATLAB
matlab_runtime=/software/Development/Languages/Matlab_Compiler_Runtime/96
# BGENIE
bgenie_dir=$data/software/bgenie
# BGENIX
bgenix_dir=$data/software/bgenix/gavinband-bgen-407eaf355425/build/apps/
# ARIA (compiled)
ARIA_dir=$data/software/ARIA/
# ARIA with random AV calling (compiled)
ARIA_rndAVcalling_dir=$data/software/ARIA_rndAVcalling
# conda
conda_dir=/data/FAC/FBM/DBC/sbergman/retina/software/miniconda3/
# AV classification
av_uncertain_dir=/data/FAC/FBM/DBC/sbergman/retina/software/a_v_uncertain-master/
lwnet_dir=/data/FAC/FBM/DBC/sbergman/retina/software/lwnet/

# GWAS
GWAS_DIR=$scratch/GWAS/output/RunGWAS/

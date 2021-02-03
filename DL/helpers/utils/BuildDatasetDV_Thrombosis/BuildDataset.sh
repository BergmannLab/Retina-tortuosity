#!/bin/bash -l
##SBATCH --account=sbergman_retina
#SBATCH --job-name=BuildTestDatasetHypertension
#SBATCH --output=slurm-%x_%j.out
#SBATCH --error=slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 20G
#SBATCH --time 00-12:00:00
#SBATCH --partition normal

source $HOME/retina/configs/config.sh

#number of cases/controls
limit=1077 # set this limit to create a balanced dataset

# clear previous run
output_dir=$scratch/retina/DL/output/utils/BuildDatasetAngina/
rm -f $output_dir/cases/*
rm -f $output_dir/controls/*

##############################################################
# CHOOSE BETWEEN ORIGINAL IMAGES AND A/V IMAGES
###images_dir=$data/retina/UKBiob/fundus/REVIEW/CLRIS/ # original images
images_dir=$data/retina/UKBiob/fundus/AV_maps # artery/vein-segmented images

case_control_list="./DV_Thrombosis_cases-controls.csv"

# build dataset of hypertense
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 ../BuildDataset.py $output_dir $images_dir $case_control_list $limit
module purge

echo FINISHED: output has been written to $output_dir

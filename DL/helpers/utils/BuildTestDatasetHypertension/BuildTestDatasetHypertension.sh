#!/bin/bash -l
##SBATCH --account=sbergman_retina
#SBATCH --job-name=BuildTestDatasetHypertension
#SBATCH --output=slurm-%x_%j.out
#SBATCH --error=slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 40G
#SBATCH --time 00-24:00:00
#SBATCH --partition normal

source $HOME/retina/configs/config.sh

#number of cases/controls
limit=20000

# clear previous run
output_dir=$scratch/retina/DL/output/utils/BuildTestDatasetHypertension/
output_dir_hypertense=$output_dir/hypertense/
output_dir_control=$output_dir/normal/
output_file_hypertense=$output_dir/hypertense.csv
output_file_control=$output_dir/normal.csv
rm -f $output_file_hypertense $output_file_control
rm -f $output_dir_hypertense/*
rm -f $output_dir_control/*

images_dir=$data/retina/UKBiob/fundus/REVIEW/CLRIS/
pheno_file=$data/retina/UKBiob/phenotypes/1_data_extraction/ukb34181.csv

# build dataset of hypertense
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 run.py $output_file_hypertense $output_file_control $output_dir_hypertense $output_dir_control $images_dir $pheno_file $limit
module purge

echo FINISHED: output has been written to $output_dir

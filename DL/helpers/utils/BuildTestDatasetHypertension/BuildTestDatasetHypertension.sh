#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=04__BuildTestDatasetHypertension

source $HOME/retina/configs/config.sh

# clear previous run
output_dir=$scratch/DL/helpers/BuildTestDatasetHypertension/output/
output_dir_hypertense=$output_dir/hypertense/
output_dir_normal=$output_dir/control/
output_file_hypertense=$output_dir/hypertense.csv
output_file_normal=$output_dir/control.csv
rm -f $output_file_hypertense $output_file_control
rm -f $output_dir_hypertense/*
rm -f $output_dir_control/*

images_dir=$data/retina/UKBiob/fundus_test/REVIEW/CLRIS/
pheno_file=$data/retina/UKBiob/phenotypes/ukb34181.csv

# build dataset of hypertense
conda activate $python_runtime
python3.8 run.py $output_file_hypertense $output_file_control $output_dir_hypertense $output_dir_control $images_dir $pheno_file
conda deactivate

echo FINISHED: output has been written to $output_dir

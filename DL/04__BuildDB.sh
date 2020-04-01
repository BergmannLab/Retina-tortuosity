#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=04__BuildDB

source $HOME/retina/config.sh

# clear previous run
output_dir=$scratch/DL/output/04_DB/
rm -f $output_dir/*pytable

input_list=$scratch/retina/preprocessing/output/03_QualityFilter/quality_filtered.csv
pheno_file=$data/retina/UKBiob/phenotypes/ukb34181.csv

# build Digital Pathology DB
conda activate $python_runtime
python3.8 helpers/04/BuildDB.py $raw_data_dir $input_list $pheno_file $output_dir
conda deactivate

echo FINISHED: output has been written to $output_dir

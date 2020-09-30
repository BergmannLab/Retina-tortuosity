#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=04__BuildDB

source $HOME/retina/configs/config.sh

# clear previous run
output_dir=$scratch/DL/output/04_DB/
rm -f $output_dir/*pytable

input_list=$data/retina/UKBiob/fundus/quality_filtered__2020_09_14__10_52_32_lwnet00_artery.csv
pheno_file=$data/retina/UKBiob/phenotypes/1_data__extraction/ukb34181.csv

# build Digital Pathology DB
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.6
module load py-biopython
python3.7 helpers/04/BuildDB.py $raw_data_dir $input_list $pheno_file $output_dir
module purge

echo FINISHED: output has been written to $output_dir

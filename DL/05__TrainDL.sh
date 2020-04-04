#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=05__TrainDL
#SBATCH --nodelist=cpt03,cpt04,cpt05,cpt06 # Xeon Phi available on some cpts to train DL

source $HOME/retina/configs/config.sh

# clear previous run
output_dir=$scratch/DL/output/05_DL/
rm -f $output_dir/*

# Digital Pathology DB
db_dir=$scratch/output/04_DB/

# Train DL model
python3 helpers/05/TrainDL.py $db_dir $gpuid $output_dir

echo FINISHED: output has been written to $output_dir

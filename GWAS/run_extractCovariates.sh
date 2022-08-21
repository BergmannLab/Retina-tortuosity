#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=extract_covar
##SBATCH --output=helpers/RunGWAS/slurm_runs/slurm-%x_%j.out
#SBATCH --error=slurm-%A.err # %A: job ID, %a: array index
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 50G
#SBATCH --time 00:05:00
#SBATCH --partition normal


#!/bin/bash

source ../configs/config.sh

python3 extractCovariates.py $PHENOFILES_DIR $PHENOFILE_ID $NB_PCS

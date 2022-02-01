#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=LDprune
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 42
#SBATCH --mem 30G
#SBATCH --time 24:00:00
#SBATCH --partition normal
#####SBATCH --array=1



# HOW-TO
# sbatch run_LD_prune.sh *EXPERIMENT_ID* 


source ../configs/config.sh

output_dir="$GWAS_DIR"/$1/

Rscript LD_prune.R $output_dir

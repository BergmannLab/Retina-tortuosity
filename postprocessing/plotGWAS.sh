#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=plotGWAS
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 50G
#SBATCH --time 01-10:00:00
#######SBATCH --time 00-04:00:00
#SBATCH --partition normal
#SBATCH --array=1

export SINGULARITY_BINDPATH="/users,/data,/scratch,/db"

singularity run /dcsrsoft/singularity/containers/R-Rocker.sif Rscript ./plotGWAS_new.R


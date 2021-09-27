#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=extract_hits
#SBATCH --output=helpers/RunGWAS/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/RunGWAS/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 8G
#SBATCH --time 00-01:30:00
#SBATCH --partition normal
#SBATCH --array=50

id=${SLURM_ARRAY_TASK_ID}

cd /users/mbeyele5/scratch_sbergman/retina/GWAS/output/RunGWAS/2021_08_26_subsampleGWAS_N1000/"$id"
gunzip *

source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc r

Rscript --vanilla /home/mbeyele5/retina/GWAS/hit_to_csv.R $id

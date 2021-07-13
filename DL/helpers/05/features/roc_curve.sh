#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=RocCurve
#SBATCH --output=./slurm_runs/slurm-%x_%j.out
#SBATCH --error=./slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 5G
#SBATCH --time 00-01:00:00
#SBATCH --partition normal

source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 helpers/05/features/roc_curve.py
module purge

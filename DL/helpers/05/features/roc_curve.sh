#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=RocCurve
#SBATCH --output=./slurm-%x_%j.out
#SBATCH --error=./slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 20G
#SBATCH --time 00-01:00:00
#SBATCH --partition normal

source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 ./roc_curve.py
module purge

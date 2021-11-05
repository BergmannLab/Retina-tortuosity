#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=Extract_features
#SBATCH --output=./slurm_runs/slurm-%x_%j.out
#SBATCH --error=./slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 00-10:00:00
#SBATCH --partition normal

python ExtractFeature_all_images.py

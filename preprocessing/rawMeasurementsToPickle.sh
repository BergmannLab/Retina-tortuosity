#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=cPkl.bz2
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 300GB
#SBATCH --partition normal
#SBATCH --time 8:00:00

python3 rawMeasurementsToPickle.py

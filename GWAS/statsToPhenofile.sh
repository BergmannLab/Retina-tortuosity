#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=statsToPhenofile
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --mem 16GB
#SBATCH --partition normal
#SBATCH --time 00-05:00:00

source ../configs/config.sh

python3 statsToPhenofile.py /data/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/index_files/mattiaQC.txt

#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=measurePhenotype
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 64GB
#SBATCH --partition normal
#SBATCH --time 00-20:00:00

source ../configs/config.sh

python3 measurePhenotype.py $ALL_IMAGES $FUNDUS_PHENOTYPE_DIR $ARIA_MEASUREMENTS_DIR $LWNET_DIR

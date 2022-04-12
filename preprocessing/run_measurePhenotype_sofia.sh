#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=measurePhenotype
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 50
#SBATCH --mem 200GB
#SBATCH --partition normal
#SBATCH --time 00-20:00:00

source ../configs/config_sofia.sh

# putting measurements in scratch really makes a difference! (1.5 instead of 20 minutes -> 10x speedup!!)
python3 measurePhenotype.py $ALL_IMAGES $phenotypes_dir $dir_ARIA_output $classification_output_dir $OD_output_dir $PHENOTYPE_OF_INTEREST

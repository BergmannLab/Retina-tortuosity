#!/bin/bash
#BATCH --account=sbergman_retina
#SBATCH --job-name=hitToCSV
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 30
#SBATCH --mem 500G
#SBATCH --time 24:00:00
#SBATCH --partition normal
#####SBATCH --array=1



# HOW-TO

# sbatch hit_to_csv.sh *EXPERIMENT_ID* 



source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc r


source ../configs/config.sh

output_dir="$GWAS_DIR"/$1/
echo $output_dir


for i in "$output_dir"/*.gz; do gunzip -f $i; done

Rscript ./hit_to_csv.R $output_dir



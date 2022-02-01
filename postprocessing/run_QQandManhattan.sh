#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=QQ-Man
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 150G
#SBATCH --time 24:00:00
#SBATCH --partition normal
#####SBATCH --array=1



# HOW-TO
# sbatch run_manhattanAndQQ.sh *EXPERIMENT_ID* 


source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc r

source ../configs/config.sh

output_dir="$GWAS_DIR"/$1/
echo $output_dir


for i in "$output_dir"/*.gz; do gunzip -f $i; done

# Bioconductor was repaired 2021-10-20
#echo Proceeding with loading special R environment now
#export SINGULARITY_BINDPATH="/users,/data,/scratch,/db"
#echo Loaded! Running R script now
#singularity run /dcsrsoft/singularity/containers/R-Rocker.sif Rscript ./manhattanAndQQ.R $output_dir

Rscript ./QQandManhattan.R $output_dir

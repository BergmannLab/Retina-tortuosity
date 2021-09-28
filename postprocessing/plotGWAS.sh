#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=plotGWAS
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 30G
#SBATCH --time 02:00:00
#SBATCH --partition normal
#####SBATCH --array=1

source ../configs/config.sh

output_dir="$GWAS_DIR"/$1/
echo $output_dir


for i in "$output_dir"/*.gz; do gunzip -f $i; done

echo Proceeding with loading special R environment now
export SINGULARITY_BINDPATH="/users,/data,/scratch,/db"
echo Loaded! Running R script now
singularity run /dcsrsoft/singularity/containers/R-Rocker.sif Rscript ./manhattanAndQQ.R $output_dir


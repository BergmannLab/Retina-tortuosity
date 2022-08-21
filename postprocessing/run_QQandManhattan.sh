#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=QQ-Man
#SBATCH --error=slurm-%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 1000G
#SBATCH --time 50:00:00
#SBATCH --partition normal
#####SBATCH --array=1

source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc r

source ../configs/config.sh

run = ${1:-$PHENOFILE_ID}

output_dir="$GWAS_DIR"/$run/
echo $output_dir
mkdir -p $output_dir/inflation

for i in "$output_dir"/*.gz; do gunzip -f $i & done
wait

# Bioconductor was repaired 2021-10-20
#echo Proceeding with loading special R environment now
#export SINGULARITY_BINDPATH="/users,/data,/scratch,/db"
#echo Loaded! Running R script now
#singularity run /dcsrsoft/singularity/containers/R-Rocker.sif Rscript ./manhattanAndQQ.R $output_dir

Rscript ./QQandManhattan.R $output_dir

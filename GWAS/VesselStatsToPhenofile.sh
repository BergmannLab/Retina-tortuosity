#!/bin/bash -l
#SBATCH --account=sbergman_retina
#SBATCH --job-name=VesselStatsToPhenofile
#SBATCH --output=helpers/VesselStatsToPhenofile/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/VesselStatsToPhenofile/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 15G
#SBATCH --time 00-00:01:00
#SBATCH --partition normal

source $HOME/retina/config.sh

# clear previous run
output_dir=$scratch/retina/GWAS/output/VesselStatsToPhenofile/
rm -f $output_dir/*

sample_file=$data/retina/UKBiob/genotypes/ukb43805_imp_chr1_v3_s487297.sample
stats_dir=$scratch/retina/preprocessing/output/MeasureVessels/

# extract vessel stats phenotypes
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.6
module load py-biopython
python3.8 $PWD/helpers/VesselStatsToPhenofile/run.py $output_dir $sample_file $stats_dir
module purge

echo FINISHED: output has been written to $output_dir

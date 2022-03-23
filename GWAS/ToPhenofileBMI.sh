#!/bin/bash -l
#SBATCH --account=sbergman_retina
#SBATCH --job-name=VesselStatsToPhenofile
#SBATCH --output=helpers/VesselStatsToPhenofile/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/VesselStatsToPhenofile/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1G
#SBATCH --time 00-02:00:00
#SBATCH --partition normal

source $HOME/retina/configs/config.sh

# define inputs and outputs
output_dir=$scratch/retina/GWAS/output/CreatePhenofile/23-03-2022_BMIxy/
output=$output_dir/phenofile_BMI_changes.csv

# qq normalize
qq_input=$output
qq_output=$output_dir/phenofile_qqnorm.csv
source /dcsrsoft/spack/bin/old_setup_dcsrsoft_jura
module purge
module load gcc/8.3.0
module load r/3.6.3
Rscript $PWD/helpers/utils/QQnorm/QQnormMatrix.R $qq_input $qq_output
module purge

echo FINISHED: output has been written to $output_dir

#!/bin/bash -l
#SBATCH --account=sbergman_retina
#SBATCH --job-name=ExtractCovariatePhenotypes
#SBATCH --output=helpers/ExtractCovariatePhenotypes/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/ExtractCovariatePhenotypes/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 15G 
#SBATCH --time 00-00:01:00
#SBATCH --partition normal

source $HOME/retina/configs/config.sh

# clear previous run
output_dir=$scratch/retina/GWAS/output/ExtractCovariatePhenotypes/
pheno_file=$data/retina/UKBiob/phenotypes/ukb34181.csv
# covariates: age, sex, BMI, SBP, diabetes, hypertension
# as in Jensen et. al. 2015 (Novel Genetic Loci Associated With Retinal Microvascular Diameter)
age=21022-0.0
sex=31-0.0
SBP=4080-0.0
#TODO missing. Read from config once fixed/finalized
#file:///data/FAC/FBM/DBC/sbergman/retina/UKBiob/phenotypes/data_fields_ukb34181.html
###BMI= # completely MISSING
###diabetes= must be derived
###hypertension= must be derived
###phenos_to_extract="$age","$sex","$BMI","$SBP","$diabetes","$hypertension"

phenos_to_extract="$age","$sex","$SBP"
sample_file=$data/retina/UKBiob/genotypes/ukb43805_imp_chr1_v3_s487297.sample

# extract phenotypes
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.6
module load py-biopython
python3.7 $PWD/helpers/ExtractCovariatePhenotypes/run.py $output_dir $pheno_file $phenos_to_extract $sample_file
module purge

echo FINISHED: output has been written to $output_dir

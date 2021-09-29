#!/bin/bash -l
#SBATCH --account=sbergman_retina
#SBATCH --job-name=ExtractCovariatePhenotypes
#SBATCH --output=helpers/ExtractCovariatePhenotypes/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/ExtractCovariatePhenotypes/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 5G 
#SBATCH --time 00-00:10:00
#SBATCH --partition normal

source $HOME/retina/configs/config.sh

# clear previous run
output_dir=$scratch/retina/GWAS/output/ExtractCovariatePhenotypes
output=$output_dir/covars.csv

# select phenoytpe file corresponding to the UKBB data extraction containing the desired phenotypes
pheno_file=$data/retina/UKBiob/phenotypes/1_data_extraction/ukb34181.csv # 1st data extraction
###pheno_file=$data/retina/UKBiob/phenotypes/2_data_extraction_BMI_height_IMT/ukb42432.csv # 2nd data extraction

# I extract disease phenotypes and useful covariates
# 3627-0.0 Age angina diagnosed
# 3894-0.0 Age heart attack diagnosed
# 4012-0.0 Age DVT diagnosed
# 4056-0.0 Age stroke diagnosed
# 2976-0.0 Age diabetes diagnosed
# 20161-0.0 Pack years of smoking
# 22038-0.0 MET minutes per week of moderate activity
# 31-0.0 sex
# 4079-0.0 DBP
# 4080-0.0 SBP
# 1960-0.0 Fed-up feelings
# 1970-0.0 Nervous feelings
# 1980-0.0 Worrier / anxious feelings
# 21003-0.0 # age when attended assessment centre

phenos_to_extract="3627-0.0,3894-0.0,4012-0.0,4056-0.0,2976-0.0,20161-0.0,22038-0.0,31-0.0,4079-0.0,4080-0.0,1960-0.0,1970-0.0,1980-0.0,21003-0.0"

# more interesting phenotypes
#age=21022-0.0
#spherical_r=5084-0.0
#spherical_l=5085-0.0
#cylindrical_r=5087-0.0
#cylindrical_l=5086-0.0
#geneticPCs=22009-0.1,22009-0.2,22009-0.3,22009-0.4,22009-0.5,22009-0.6,22009-0.7,22009-0.8,22009-0.9,22009-0.10,22009-0.11,22009-0.12,22009-0.13,22009-0.14,22009-0.15,22009-0.16,22009-0.17,22009-0.18,22009-0.19,22009-0.20,22009-0.21,22009-0.22,22009-0.23,22009-0.24,22009-0.25,22009-0.26,22009-0.27,22009-0.28,22009-0.29,22009-0.30,22009-0.31,22009-0.32,22009-0.33,22009-0.34,22009-0.35,22009-0.36,22009-0.37,22009-0.38,22009-0.39,22009-0.40

#phenos_to_extract="$sex", "$spherical_r", "$spherical_l", "$cylindrical_r", "$cylindrical_l","$geneticPCs"


sample_file=$data/retina/UKBiob/genotypes/ukb43805_imp_chr1_v3_s487297.sample

# extract phenotypes
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 $PWD/helpers/ExtractCovariatePhenotypes/run.py $output $pheno_file $phenos_to_extract $sample_file
module purge

echo FINISHED: output has been written to: $output_dir

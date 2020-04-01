#!/bin/bash -l
#SBATCH --account=sbergman_retina
#SBATCH --job-name=Extract_SBP_Phenotypes
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 15G 
#SBATCH --time 00-00:01:00
#SBATCH --partition normal

source $HOME/retina/config.sh

# clear previous run
output_dir=$scratch/retina/GWAS/helpers/Extract_SBP_Phenotypes/output/
rm -f $output_dir/*

pheno_file=$data/retina/UKBiob/phenotypes/ukb34181.csv
phenos_to_extract="4080-0.0,4080-0.1"
sample_file=$data/retina/UKBiob/genotypes/ukb43805_imp_chr3_v3_s487297.sample

# extract phenotypes
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.6
module load py-biopython
python3.7 run.py $output_dir $pheno_file $phenos_to_extract $sample_file
module purge

echo FINISHED: output has been written to $output_dir

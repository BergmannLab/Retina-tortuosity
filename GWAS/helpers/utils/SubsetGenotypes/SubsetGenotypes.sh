#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=SubsetGenotypes
#SBATCH --output=slurm_runs/slurm-%x_%j.out
#SBATCH --error=slurm_runs/slurm-%x_%j.err
####### --nodes 22 when running on all chromos TODO how to spawn BGENIE threads? with "&"?
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
####### seems to need very little RAM
#SBATCH --mem 1GB
#SBATCH --time 01-0:00:00
#SBATCH --partition normal

source $HOME/retina/configs/config.sh
begin=$(date +%s)

genotypes_dir=$data/retina/UKBiob/genotypes/
filtered_SNP_list=$genotypes_dir/rs.list

chromosome=ukb_imp_chr21_v3
chromosome_file_name=$chromosome".bgen"
index_file_name=$chromosome".bgen.bgi"
subset_file_name=$chromosome"_subset.bgen"

# create BGENIX index file
if [ ! -f $genotypes_dir/$index_file_name ]; then
echo "creating index file for chromosome $chromosome"
$bgenix_dir/bgenix \
-g $genotypes_dir/$chromosome_file_name \
-index
fi

# run BGENIX
echo "subsetting SNP in chromosome $chromosome"
$bgenix_dir/bgenix \
-g $genotypes_dir/$chromosome_file_name \
-incl-rsids filtered_SNP_list > \
$genotypes_dir/$subset_file_name

echo "Finished subsetting genotype file: $subset_file_name"
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

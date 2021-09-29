#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=RunGWAS
#SBATCH --output=helpers/RunGWAS/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/RunGWAS/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 16G
####SBATCH --time 01-10:00:00
#SBATCH --time 00-00:30:00
#SBATCH --partition normal
#SBATCH --array=1-22

source $HOME/retina/configs/config.sh
begin=$(date +%s)

j_array_params=$PWD/helpers/RunGWAS/j_array_params.txt
PARAM=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $j_array_params)
chromosome_number=$(echo $PARAM | cut -d" " -f1)

experiment_id=$1 # RENAME EXPERIMENT APPROPRIATELY
sample_no=$2
pheno_file=$scratch/retina/GWAS/output/VesselStatsToPhenofile/"$experiment_id"/$sample_no/phenofile_qqnorm.csv

#UKBiob

chromosome_name=ukb_imp_chr"$chromosome_number"_v3
chromosome_file=$data/retina/UKBiob/genotypes/"$chromosome_name"_subset.bgen # for full rslist, use _subset instead of _subset_mini
covar_file=$scratch/retina/GWAS/output/ExtractCovariatePhenotypes/2020_10_03_final_covar/final_covar.csv
sample_file=$data/retina/UKBiob/genotypes/ukb43805_imp_chr1_v3_s487297.sample

#CoLaus

#chromosome_name=CoLaus.HRC.chr"$chromosome_number".MAFsubsetted
#covar_file=$data/retina/colaus/phenotypes/covar.csv
#covar_file=$data/retina/colaus/phenotypes/covar_including_PCs_for_DF.csv
#chromosome_file=$data/retina/colaus/genotypes/colaus_axiom_hrc.r1.1.2016_imputed/"$chromosome_name".bgen # for full rslist, use _subset instead of _subset_mini
#sample_file=$data/retina/colaus/genotypes/colaus_axiom_hrc.r1.1.2016_imputed/CoLaus.sample


output_file_name=output_"$chromosome_name".txt

# prepare output dir
output_dir=$scratch/retina/GWAS/output/RunGWAS/"$experiment_id"/"$sample_no"_leadSNPs
mkdir -p $output_dir

function validate_inputs(){ # check input files have matching number of samples
	sample_file=$1
	chromosome_file=$2
	pheno_file=$3
	covar_file=$4

	# how many entries in sample file?
	echo "Sample file:"
	n_lines=$(cat $sample_file | wc -l)
	# num lines in sample file (minus 2 for the headers)
	n_samples=$(($n_lines-2)) 
	echo "Number of samples in input file(s):  " $n_samples.

	# how many entries in genotype file?
	echo "Genotype file:"
	module add UHTS/Variation/qctool/2.1.7d77b8d3896b
	qctool -g $chromosome_file 2>&1 | grep "Number of samples in input"
	module rm UHTS/Variation/qctool/2.1.7d77b8d3896b

	# how many entries in pheno file?
	echo "Phenotype file:"
	n_lines=$(cat $pheno_file | wc -l)
	# num lines in pheno file (minus 1 for the header)
	n_pheno=$(($n_lines-1)) 
	echo "Number of samples in input file(s):  " $n_pheno.

	# how many entries in covar file?
	echo "Covariates file:"
	n_lines=$(cat $covar_file | wc -l)
	# num lines in covar file (minus 1 for the header)
	n_covar=$(($n_lines-1)) 
	echo "Number of samples in input file(s):  " $n_covar.
}

function run_BGENIE() {
chromosome_file=$1
pheno_file=$2
covar_file=$3
output_file=$4
echo 
echo RUNNING GWAS on CHROMOSOME $chromosome_file 
echo phenopyte: $pheno_file 
echo covars: $covar_file

$bgenie_dir/bgenie_v1.3_static2 \
--bgen $chromosome_file \
--pheno $pheno_file \
--covar $covar_file \
--out $output_file \
--thread 8 \
--pvals \
--rsid 1:3253678
#--include_rsids /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/subsample/lead_rsIDs.txt \
}

# RUN GWAS
validate_inputs $sample_file $chromosome_file $pheno_file $covar_file
run_BGENIE $chromosome_file $pheno_file $covar_file $output_dir/$output_file_name

echo
echo FINISHED: output has been written to:
echo - data: $output_dir
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"
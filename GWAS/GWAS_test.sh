#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=GWAS_test
#SBATCH --output=helpers/GWAS_test/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/GWAS_test/slurm_runs/slurm-%x_%j.err
############ --nodes 22 when running full GWAS
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 16GB
#SBATCH --time 00-01:00:00
#SBATCH --partition normal

source $HOME/retina/config.sh
begin=$(date +%s)

sample_file=$data/retina/UKBiob/genotypes/ukb43805_imp_chr3_v3_s487297.sample
bgen_file=$data/retina/UKBiob/genotypes/ukb_imp_chr1_v3.bgen
pheno_file=$scratch/retina/GWAS/helpers/Extract_SBP_Phenotypes/output/4080-0.0,4080-0.1.csv

# clear previous run
scratch_output_dir=$scratch/retina/GWAS/output/GWAS_test
rm -f $scratch_output_dir/*

inspect_inputs=true
if $inspect_inputs; then
	# how many entries in sample file?
	echo "Sample file:"
	n_lines=$(cat $sample_file | wc -l)
	# num lines in sample file (minus 2 for the headers)
	n_samples=$(($n_lines-2)) 
	echo "Number of samples in input file(s):  " $n_samples.

	# how many entries in genotype file?
	echo "Genotype file:"
	module add UHTS/Variation/qctool/2.1.7d77b8d3896b
	qctool -g $bgen_file 2>&1 | grep "Number of samples in input"
	module rm UHTS/Variation/qctool/2.1.7d77b8d3896b

	# how many entries in pheno file?
	echo "Phenotype file:"
	n_lines=$(cat $pheno_file | wc -l)
	# num lines in pheno file (minus 1 for the header)
	n_pheno=$(($n_lines-1)) 
	echo "Number of samples in input file(s):  " $n_pheno.
fi

# run BGENIE - ON ONE CHROMOSOME 4080-0.0,4080-0.1
$bgenie_dir/bgenie_v1.3_static2 \
--bgen $bgen_file \
--pheno $pheno_file \
--out ./mattia_test_out/example.out \
--thread 8

echo FINISHED: output has been written to:
echo - data: $scratch_output_dir
end=$(date +%s) # calculate execution time
c=$(expr $end - $begin)
echo "execution time: $tottime sec"

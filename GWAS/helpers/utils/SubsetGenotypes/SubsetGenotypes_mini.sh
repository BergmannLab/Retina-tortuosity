#!/bin/bash

###############################################################################
# here I am subsetting only ch15 (which I need for my GWAS experimnents)
# using rs_mini.list (contains only 1/10 of SNPs in rs.list)
###############################################################################

source $HOME/retina/configs/config.sh
begin=$(date +%s)

genotypes_dir=$data/retina/UKBiob/genotypes/
filtered_SNP_list=$genotypes_dir/rs_mini.list

###for number in {15..15}
for number in {9..9}
do 

	chromosome=ukb_imp_chr"$number"_v3
	echo Processing chromosome $chromosome
	chromosome_file_name=$chromosome".bgen"
	index_file_name=$chromosome".bgen.bgi"
	subset_file_name=$chromosome"_subset_mini.bgen"

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
	-incl-rsids $filtered_SNP_list > \
	$genotypes_dir/$subset_file_name

done

echo "Finished subsetting genotype file: $subset_file_name"
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

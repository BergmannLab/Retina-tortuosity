#!/bin/bash

# HOW-TO
# bash hit_to_csv.sh *EXPERIMENT_ID* 

source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc python/3

source ../configs/config.sh

OUT_DIR="$GWAS_DIR"/$1/
echo $OUT_DIR

for i in "$OUT_DIR"/*.gz; do gunzip -f $i; done # cannot parallelize. would compute on front note

NUMBER_OF_PHENOTYPES=$(awk -F' ' '{print NF; exit}' $OUT_DIR/sample_sizes.txt)

echo Number of phenotypes: $NUMBER_OF_PHENOTYPES

cpu=1
mem=600M #600M ok for full bgenie gwas
time="02:00:00" #1h generally ok, but there are occational bad nodes

for i in $(seq 1 $NUMBER_OF_PHENOTYPES); do
	PHENO=$(cat $OUT_DIR/sample_sizes.txt | head -n1 | cut -f $i -d' ')
	SAMPLE_SIZE=$(cat $OUT_DIR/sample_sizes.txt | tail -n1 | cut -f $i -d' ')
	sbatch -p cpu -J hit_to_csv --mem $mem -t $time -c $cpu -N 1 --account sbergman_retina --partition normal --error slurm-%j.err --wrap "python3 -u hit_to_csv.py $OUT_DIR $PHENO $SAMPLE_SIZE"
done



# showcase of brain being stuck

#for i in $(seq 1 $PHENOTYPES_PER_ROUND $NUMBER_OF_PHENOTYPES); do
#	NAIVE_LOOP_MAX=$(($i + $PHENOTYPES_PER_ROUND - 1))
#	ACTUAL_LOOP_MAX=$(( NUMBER_OF_PHENOTYPES < NAIVE_LOOP_MAX ? NUMBER_OF_PHENOTYPES : NAIVE_LOOP_MAX ))
#	for j in $(seq $i $ACTUAL_LOOP_MAX); do
#		echo Phenotype number $j
#		PHENO=$(cat $OUT_DIR/sample_sizes.txt | head -n1 | cut -f $j -d' ')
#		SAMPLE_SIZE=$(cat $OUT_DIR/sample_sizes.txt | tail -n1 | cut -f $j -d' ')
#		echo $PHENO $SAMPLE_SIZE
#		python3 hit_to_csv.py $OUT_DIR $PHENO $SAMPLE_SIZE &
#	done
#	wait
#done

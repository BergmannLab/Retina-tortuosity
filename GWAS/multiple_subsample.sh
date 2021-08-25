#!/bin/bash

N_SAMPLES=$1
N_RUNS=$2
ID=$3

PARENT=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/$ID
mkdir $PARENT

ALL_SAMPLES=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/backup/2021_02_22_rawMeasurements/

subsample_and_GWAS() {
  
  ID=$1
  c=$2
  PARENT=$3
  N_SAMPLES=$4
  ALL_SAMPLES=$5
  
  id=$(sbatch --parsable subsample.sh $PARENT $c $N_SAMPLES $ALL_SAMPLES)
  id2=$(sbatch --dependency=afterok:$id --parsable VesselStatsToPhenofile.sh $1 $2)
  sbatch --dependency=afterok:$id2 RunGWAS_62751_all_with_covar.sh $1 $2
}

for (( c=1; c<=$N_RUNS; c++ ))
  do
  
  # Crucial in the next line to execute the function in the background, so that the next iteration of the for loop may already execute immediately, not only when previous GWAS is finished
  subsample_and_GWAS $ID $c $PARENT $N_SAMPLES $ALL_SAMPLES
done



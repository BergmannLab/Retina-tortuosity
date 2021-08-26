#!/bin/bash

N_RUNS=$2
ID=$1

PARENT=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/GWAS/output/VesselStatsToPhenofile/$ID

for (( c=24; c<=$N_RUNS; c++ ))
  do
  sbatch RunGWAS_62751_all_with_covar.sh $ID $c
done



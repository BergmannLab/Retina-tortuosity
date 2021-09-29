#!/bin/bash

N_RUNS=$2
ID=$1

PARENT=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/GWAS/output/VesselStatsToPhenofile/$ID

for (( c=1; c<=$N_RUNS; c++ ))
  do
  echo $c
  sbatch RunGWAS.sh $ID $c
done



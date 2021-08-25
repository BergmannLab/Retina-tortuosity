#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=subsample
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 4G
#SBATCH --time 00-02:00:00
#SBATCH --partition normal

PARENT=$1
c=$2
N_SAMPLES=$3
ALL_SAMPLES=$4
SAMPLES=$(( N_SAMPLES / 20 ))

shuffle() {
  echo $PARENT $c $ALL_SAMPLES $SAMPLES
  for i in $(ls $ALL_SAMPLES | cut -d"_" -f1 | uniq | shuf -n $SAMPLES); do cp $ALL_SAMPLES$i*imageStats* $PARENT/$c; done
}


mkdir $PARENT/$c
for i in {1..20}; do shuffle & done
wait



#!/bin/bash

source $HOME/retina/configs/config.sh

set +x

module purge
module load Development/Languages/Matlab_Compiler_Runtime/96
module list

export MCR_CACHE_ROOT=/tmp

echo;
env | grep MCR
echo;

# compile matlab code
MATLAB_SCRIPT=ARIA_run_tests
mcc -v -m $MATLAB_SCRIPT.m -a $PWD/..

# move compiled executable to appropriate dir
# (it is big, do not want to pollute github repo)
mv ARIA_run_tests $data/retina/software/ARIA/
cp run_ARIA_run_tests.sh $data/retina/software/ARIA/

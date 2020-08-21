#!/bin/bash

set +x

module purge
module load Development/Languages/Matlab_Compiler_Runtime/96
module list


export MCR_CACHE_ROOT=/tmp

echo;
env | grep MCR
echo;


MATLAB_SCRIPT=ARIA_run_tests

mcc -v -m $MATLAB_SCRIPT.m -a $PWD/..


    
    


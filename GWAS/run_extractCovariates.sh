#!/bin/bash

source ../configs/config.sh

python3 extractCovariates.py $PHENOFILES_DIR $PHENOFILE_ID $NB_PCS

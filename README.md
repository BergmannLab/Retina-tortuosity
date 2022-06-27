# GWAS for multiple fundus traits
**Input**
* precomputed phenofile

**Steps performed in this repository**
* prepare a covariate file required for BGENIE GWAS
* compute GWAS on given phenofile
* visualizations: Manhattan, QQ
* prepare PascalX and LDSC input for downstream analyses

# Step by step how-to

## Create covariates file
`./run_extractCovariates.sh`

In `configs/config.sh`, specify `NB_PCS`, how many PCs are included as covariates.
In `GWAS/extractCovariates.py`, further choose which UKBB datafields to choose as covariates. Currently used:

1) sex

2-3) age and age-squared when visiting assessment center

4-23) 20 PCs

## Run GWAS

0) Generate your phenofile, and put it in the appropriate *EXPERIMENT_ID* folder in scratch
1) Run your GWAS:

`sbatch RunGWAS.sh *EXPERIMENT_ID* [mini/affymetrix/*empty for full gwas*]`

(For exploration, I recommend using the `affymetrix` option instead of `mini`)

**Example:**

`sbatch RunGWAS.sh 2021_10_11_my_awesome_trait affymetrix`

## Plot results
If the GWAS has run successfully, this command stores QQ and Manhattan plots in the appropriate folder:

`sbatch run_QQandManhattan.sh *EXPERIMENT_ID*`

(script location: retina/postprocessing.)

## Postprocessing

`sbatch run_hit_to_csv.sh *EXPERIMENT_ID*`

# Initializing the repository on Jura

Run retina/configs/dir_structure/init.sh
  Assumes the following are configured as in Jura
  - a data location
  - an archive location
  - a scratch location

Mattia: The following documentation explains how to run a GWAS and how to perform DL on the UK Biobank retinal data:
https://docs.google.com/document/d/1XQ1e4czEvItjRv_7yC3ze0YxGwv7dGSvUdnubkT27BA/edit#heading=h.91fo54mukcmt

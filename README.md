# How-to for the new multi-trait analysis
For the new analysis, we decoupled image measurements from quality control. Also, running GWAS is faster and includes the option of running a minimalistic Affymetrix GWAS for exploration.

## Phenotype measurements
The new script `measurePhenotype.py` contains the functions for measuring all the non-basic phenotypes. Measurements can be taken on ARIA and LWNET output, or on the raw images directly.

The existing functions so far:
* fractal dimension
* bifurcations
* AV crossings

To measure a specific phenotype, add a function to `measurePhenotype.py`, modify `__MAIN__` accordingly to use this function, and then run the measurements using `sbatch run_measurePhenotype.sh`.

All phenotype measurements are stored in `/data/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/`.

## From image measurements to phenofile
Using a defined QC file to be decided, the script `tbd` combines image measurements into participant-wise single-number statistics, which will be used in the GWAS.

Here, all phenotypes we decide to use will be combined into a single phenofile `multiTrait_phenofile_qqnorm.csv`, which we will use as the basis for all downstream analyses.

# How-to for running the new, faster GWAS
## Running GWAS
0) Generate your phenofile, and put it in the appropriate *EXPERIMENT_ID* folder
1) Run your GWAS:

`sbatch RunGWAS.sh *EXPERIMENT_ID* [mini/affymetrix/*empty for full gwas*]`

(For exploration, I recommend using the `affymetrix` option instead of `mini`)

**Example:**

`sbatch RunGWAS.sh 2021_10_11_myAwesomeTrait affymetrix`

## Plotting GWAS results
If the GWAS has run successfully, this command stores QQ and Manhattan plots in the appropriate folder:

`sbatch plotGWAS.sh *EXPERIMENT_ID*`

(The script is located in retina/postprocessing.)

## Further processing GWAS results

# Initializing the repository on Jura

Run retina/configs/dir_structure/init.sh
  Assumes the following are configured as in Jura
  - a data location
  - an archive location
  - a scratch location

Mattia: The following documentation explains how to run a GWAS and how to perform DL on the UK Biobank retinal data:
https://docs.google.com/document/d/1XQ1e4czEvItjRv_7yC3ze0YxGwv7dGSvUdnubkT27BA/edit#heading=h.91fo54mukcmt

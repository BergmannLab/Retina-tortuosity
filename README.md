# How-to (revamped for multitrait project)
In the multitrait project, we decoupled image measurement from quality control. Also, running GWAS is faster and includes the option of running a minimalistic Affymetrix GWAS for exploration, as well as easy plotting (Manhattan, QQ) postprocessing of GWAS summary statistics.

## Phenotype measurement
The new script `preprocessing/measurePhenotype.py` contains the functions for measuring all the non-basic phenotypes. Measurements can be taken on ARIA and LWNET output, or on the raw images directly.

The existing functions so far:
* ARIA measurements
* fractal dimension
* bifurcations
* AV crossings

To measure a specific phenotype, add a function to `measurePhenotype.py`, modify `__MAIN__` to use this function and to name the output file, and then run the measurements using `sbatch run_measurePhenotype.sh`.

Phenotype measurements are stored in the scratch retina folder under `UKBiob/fundus/fundus_phenotypes/`.

## Image-based phenotypes to phenofile
Using a defined QC file, the script `GWAS/statsToPhenofile.py` combines image measurements into participant-wise single-number statistics compatible with BGENIE.

In the multitrait projects, phenotypes of interest are combined into a single phenofile `multiTrait_phenofile_qqnorm.csv`, which we will use as the basis for all downstream analyses.

But the script can easily be modified, to use different QC or to only use specific traits:
* Change the QC: modify the variable `KEPT_IMAGES` in `configs/config.sh`.
* Create phenofile for specific phenotype: In `GWAS/statsToPhenofile.py` `__main__`, **1)** adapt `EXPERIMENT_NAME`, and **2)** modify list of phenotypes to go into the dataframe a few lines below

To run the script, use `sbatch run_statsToPhenofile.sh`

Phenofiles are stored in the scratch retina folder under `UKBiob/fundus/phenofiles/`



# General how-to for the faster GWAS
## Running GWAS
0) Generate your phenofile, and put it in the appropriate *EXPERIMENT_ID* folder
1) Run your GWAS:

`sbatch RunGWAS.sh *EXPERIMENT_ID* [mini/affymetrix/*empty for full gwas*]`

(For exploration, I recommend using the `affymetrix` option instead of `mini`)

**Example:**

`sbatch RunGWAS.sh 2021_10_11_myAwesomeTrait affymetrix`

## Plotting GWAS results
If the GWAS has run successfully, this command stores QQ and Manhattan plots in the appropriate folder:

`sbatch run_QQandManhattan.sh *EXPERIMENT_ID*`

(The script is located in retina/postprocessing.)

## Postprocessing

`sbatch run_hit_to_csv.sh *EXPERIMENT_ID*`

## Further processing GWAS results

# Initializing the repository on Jura

Run retina/configs/dir_structure/init.sh
  Assumes the following are configured as in Jura
  - a data location
  - an archive location
  - a scratch location

Mattia: The following documentation explains how to run a GWAS and how to perform DL on the UK Biobank retinal data:
https://docs.google.com/document/d/1XQ1e4czEvItjRv_7yC3ze0YxGwv7dGSvUdnubkT27BA/edit#heading=h.91fo54mukcmt

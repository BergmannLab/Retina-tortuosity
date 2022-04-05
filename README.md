# Summary (revamped for multitrait project)
In this project, we aim to parametrize retinal vascular morphology using a collection of medically relevant traits. We do this by implementing their automatic measurement of a collection in the UK Biobank fundus dataset.

Operationally, (1)  we decoupled image measurement from quality control, and (2) running GWAS is faster and includes the option of running a minimalistic Affymetrix GWAS for exploration, as well as easy plotting (Manhattan, QQ) and postprocessing of GWAS summary statistics.

## Previous steps
We previously processed raw fundus images in two different ways. First, using ARIA (Bankhead, 2012), we extracted centerlines of the retinal vasculature. Second, using L-WNET (Galdran 2020), we created a pixel-wise artery-vein map of the retinal vasculature. Third, using an inhouse CNN (U-Net), we predicted the optic disc position for each fundus image.

Using a combination of these, here we extracted a representative set of medically relevant vascular traits of the human retina.

# How-to

## Taking image measurements
The new script `preprocessing/measurePhenotype.py` contains the functions for measuring all the non-basic phenotypes. Each image in the dataset is measured, irrespective of its quality.

The existing functions so far:
* ARIA measurements
* fractal dimension
* bifurcations
* AV crossings

To measure a specific phenotype
1) add a function to `measurePhenotype.py`
2) modify `__MAIN__` to use this function and to give a unique ID to the measurement
3) run using `sbatch run_measurePhenotype.sh`.

Output location: `*scratch*/retina/UKBiob/fundus/fundus_phenotypes/`.

## Create BGENIE phenofile based on image measurements
Using a defined QC file, `GWAS/statsToPhenofile.py` combines image measurements into participant-wise single-number summaries compatible with BGENIE.

Modifiable parts:
* Give the phenofile a unique identifier by modifying `PHENOFILE_ID` in `configs/config.sh`
* Change the QC: modify `KEPT_IMAGES` in `configs/config.sh` to point to file containing list of images to keep.
* Choose image measurements to consider: In `GWAS/statsToPhenofile.py` `__main__, modify the list called `phenotypes`.

To run the script, use `sbatch run_statsToPhenofile.sh`

Output location: `*scratch*/retina/UKBiob/fundus/phenofiles/`
Files created: `PHENOFILE_ID.csv` (raw traits) **`PHENOFILE_ID_qqnorm.csv`** (rank-normalized traits), `*PHENOFILE_ID*_timepoints.csv` (designating instance of each participant's)



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

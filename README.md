# Running GWAS
0) Generate your phenofile, and put it in the appropriate *EXPERIMENT_ID* folder
1) Run your GWAS:

`sbatch RunGWAS.sh *EXPERIMENT_ID* [mini/affymetrix/*empty for full gwas*]`

(For exploration, I recommend using the `affymetrix` option instead of `mini`)

**Example:**

`sbatch RunGWAS.sh 2021_10_11_myAwesomeTrait affymetrix`

# retina

Run retina/configs/dir_structure/init.sh
  Assumes the following are configured as in Jura
  - a data location
  - an archive location
  - a scratch location

The following documentation explains how to run a GWAS and how to perform DL on the UK Biobank retinal data: 
https://docs.google.com/document/d/1XQ1e4czEvItjRv_7yC3ze0YxGwv7dGSvUdnubkT27BA/edit#heading=h.91fo54mukcmt
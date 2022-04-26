############################## CONFIG FILE for JURA Retina pipeline ##############################

## TO DO: Add all the changes. Now it will only run from measurePheno.
#### TYPE_OF_VESSEL_OF_INTEREST:
TYPE_OF_VESSEL_OF_INTEREST="all" # [artery|vein|all] 

#### PHENOTYPE_OF_INTEREST:
PHENOTYPE_OF_INTEREST='green_segments' #posibilities: 'tva', 'taa', 'bifurcations', 'green_segments', 'neo_vascularization', 'aria_phenotypes', 'fractal_dimension', 'ratios'
# TO DO: Add option to select all


#### BASE DIRS
archive=/stornext/CHUV1/archive/FAC/FBM/DBC/sbergman/retina/
data=/data/FAC/FBM/DBC/sbergman/retina/
scratch=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/


classification_output_dir=$data/UKBiob/fundus/AV_maps/ #LWNET_DIR
dir_ARIA_output=$scratch/preprocessing/output/backup/2021_10_06_rawMeasurements_withoutQC/ #ARIA_MEASUREMENTS_DIR
phenotypes_dir=$scratch/UKBiob/fundus/phenofiles/ #PHENOFILES_DIR
OD_output_dir=$scratch/beegfs/FAC/FBM/DBC/sbergman/retina/ #new!
ALL_IMAGES=$data/UKBiob/fundus/index_files/noQC.txt #ALL_IMAGES

#### QUALITY THRESHOLDS OF ARTERY/VEIN CLASSIFICATION: 
AV_threshold=0.0 # Consider all classified vessels
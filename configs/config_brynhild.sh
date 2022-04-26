############################## CONFIG FILE for Brynhild Retina pipeline ##############################
## TO DO: Add all the changes. Now it will only run from measurePheno.

#### TYPE_OF_VESSEL_OF_INTEREST:
TYPE_OF_VESSEL_OF_INTEREST="all" # [artery|vein|all] 

#### PHENOTYPE_OF_INTEREST:
PHENOTYPE_OF_INTEREST='green_segments' #posibilities: 'tva', 'taa', 'bifurcations', 'green_segments', 'neo_vascularization', 'aria_phenotypes', 'fractal_dimension', 'ratios'
# TO DO: Add option to select all


classification_output_dir=/NVME/decrypted/ukbb/fundus/lwnet/
dir_ARIA_output=/NVME/decrypted/ukbb/fundus/2021_10_rawMeasurements/2021_10_06_rawMeasurements_withoutQC/
phenotypes_dir=/NVME/decrypted/ukbb/fundus/phenofiles/
OD_output_dir=/NVME/decrypted/ukbb/fundus/phenotypes/
ALL_IMAGES=/NVME/decrypted/ukbb/fundus/index_files/noQC.txt

#### QUALITY THRESHOLDS OF ARTERY/VEIN CLASSIFICATION: 
AV_threshold=0.0 # Consider all classified vessels
############################## CONFIG FILE for Retina pipeline ##############################

# REMEMBER!: Do not use spaces: "dir = x", will lead to errors, instead use "dir=x"


#### SELECT THE DATA SET YOU WANT TO USE:

data_set=CHASEDB1 #options: DRIVE


#### SELECT NUMBER OF RAW IMAGES DEPENDING ON THE DATA SET SELECTED:


if [ "$data_set" = "CHASEDB1" ]; then
    num_images=28 #28
elif [ "$data_set" = "DRIVE" ]; then
    num_images=20 #20
else
    num_images=0 # TO DO: Add error!
fi

echo Number of images equal to $num_images	

#### TYPE_OF_VESSEL_OF_INTEREST:
TYPE_OF_VESSEL_OF_INTEREST="all" # [artery|vein|all] 

#### BASE DIRS:
#   ----------------------------------------------------------------
#    If you do not change the pipeline you do not need to worry about this. 
#	Otherwise, you will need to specify the directory of: 
#       	- Raw images: dir_images
#       	- LWnet software: classification_output_dir
#       	- LWnet images output: lwnet_dir
#   ---------------------------------------------------------------- 
# TO DO!: change the directories in a more automated fashion!

dir_images='/Users/sortinve/develop/retina/input/'$data_set'_images/'$data_set'/'
lwnet_dir=/Users/sortinve/develop/Codigos_github/lwnet/
classification_output_dir='/Users/sortinve/develop/retina/input/'$data_set'_AV_maps/'
dir_ARIA_output='/Users/sortinve/develop/retina/output/ARIA_output_'$data_set'/'
ARIA_dir='/Users/sortinve/develop/retina/preprocessing/helpers/MeasureVessels/src/petebankhead-ARIA-328853d/ARIA_tests/'
MeasureVessels_dir='/Users/sortinve/develop/retina/output/VesselMeasurements/'$data_set'/'

#### QUALITY THRESHOLDS OF ARTERY/VEIN CLASSIFICATION: 
AV_threshold=0.0 # Consider all classified vessels


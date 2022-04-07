#!/bin/bash  ##TO DO, can we delete???
#SBATCH --account=sbergman_retina
#SBATCH --job-name=⚡lwnet⚡
#SBATCH --output=helpers/ClassifyAVUncertain/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/ClassifyAVUncertain/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 12GB
#SBATCH --partition normal
#SBATCH --time 01:30:00
#SBATCH --array=1-582

#### Read the vairables requiered from config.sh:
source ../configs/config_sofia.sh
begin=$(date +%s)

#### Create the folder where the after preprocessing images are going to be located (for the dataset selected):
mkdir $dir_images

#### Preprocessing: .png format, avoid spaces in names, and create file with images names:
python basic_preprocessing.py $dir_images2 $dir_images $image_type

#### Create the folder where the AV maps are going to be located (for the dataset selected):
mkdir $classification_output_dir

#### Artery Vein segementation using WNET:
## TO DO: analyze more than one image at the time
cd $lwnet_dir
raw_imgs=( "$dir_images"* )
for i in $(eval echo "{1..$num_images}"); do
    image="${raw_imgs[i]}"
    python predict_one_image_av.py --model_path experiments/big_wnet_drive_av/ --im_path $image --result_path $classification_output_dir
done

python /Users/sortinve/develop/retina/preprocessing/Change_the_name_LWNEToutput.py $classification_output_dir

echo FINISHED: Images have been classified, and written to $classification_output_dir
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

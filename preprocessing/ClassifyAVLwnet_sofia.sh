#!/bin/bash
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

source ../configs/config_sofia.sh
begin=$(date +%s)
#echo pwd $PWD

cd $lwnet_dir
raw_imgs=( "$dir_images"* )
for i in $(eval echo "{1..$num_images}"); do
    image="${raw_imgs[i]}"
    python predict_one_image_av.py --model_path experiments/big_wnet_drive_av/ --im_path $image --result_path $classification_output_dir
done

echo FINISHED: Images have been classified, and written to $classification_output_dir
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

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

source $HOME/retina/configs/config.sh
begin=$(date +%s)

# job array
j_array_params=$PWD/helpers/ClassifyAVUncertain/j_array_params.txt
PARAM=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $j_array_params)
chunk_start=$(echo $PARAM | cut -d" " -f1)
chunk_size=$(echo $PARAM | cut -d" " -f2)

# cleaning previous runs
classification_output_dir=$scratch/retina/preprocessing/output/ClassifyAVLwnet/
rm -rf $classification_output_dir/*

# classifying vessels into arteries and veins
source $conda_dir/etc/profile.d/conda.sh
conda activate lwnet
conda init bash
# checking that lwnet is active environment:
conda info --envs

cd $lwnet_dir
raw_imgs=( "$raw_data_dir"* )
for i in $(seq $chunk_start $(($chunk_start+$chunk_size-1))); do
    image="${raw_imgs[i]}"
    python predict_one_image_av.py --model_path experiments/big_wnet_drive_av/ --im_path $image --result_path $classification_output_dir
done


echo FINISHED: Images have been classified, and written to $classification_output_dir
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

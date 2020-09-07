#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=⚡lwnet⚡
#SBATCH --output=helpers/ClassifyAVUncertain/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/ClassifyAVUncertain/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 25GB
#SBATCH --partition normal
#SBATCH --time 00-00:05:00
#SBATCH --array=1-1

source $HOME/retina/configs/config.sh
begin=$(date +%s)

# job array
j_array_params=$PWD/helpers/ClassifyAVUncertain/j_array_params.txt
#PARAM=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $j_array_params)
#chunk_start=$(echo $PARAM | cut -d" " -f1)
#chunk_size=$(echo $PARAM | cut -d" " -f2)

# cleaning previous runs
classification_output_dir=$scratch/retina/preprocessing/output/ClassifyAVUncertain/
rm -rf $classification_output_dir/*

# classifying vessels into arteries and veins
source $conda_dir/etc/profile.d/conda.sh
conda init bash
conda activate av_uncertain
cd $av_uncertain_dir
ls $raw_data_dir_av_test
python build_predictions.py --path_ims $raw_data_dir_av_test --path_out $classification_output_dir

echo FINISHED: Images have been classified, and written to $classification_output_dir
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

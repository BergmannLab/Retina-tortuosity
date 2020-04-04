#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=StoreMeasurements
#SBATCH --output=helpers/StoreMeasurements/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/StoreMeasurements/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1GB
#SBATCH --time 00-01:00:00
#SBATCH --partition normal  

source $HOME/retina/configs/config.sh
begin=$(date +%s)

input_dir=$scratch/retina/preprocessing/output/MeasureVessels/
backup_dir=$archive/retina/preprocessing/output/StoreMeasurements/$(date +%Y_%m_%d__%H_%M_%S)
mkdir $backup_dir

tot_png_files=$(find $raw_data_dir -name *png | wc -l) # count the number of raw input inputs
tot_mat_files=$(find $input_dir -name *mat | wc -l) # count the number of measured images
echo "$tot_mat_files measurements"
echo "$tot_png_files original raw images"

# back up
cp $input_dir/*.mat $input_dir/*.tsv $backup_dir

echo FINISHED: output has been written to: backup_dir

end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

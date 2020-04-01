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

source $HOME/retina/config.sh
begin=$(date +%s)

data_output_dir=$data/retina/preprocessing/output/MeasureVessels/
scratch_output_dir=$scratch/retina/preprocessing/output/MeasureVessels/

# clear previous run
#rm -f $data_output_dir/*.mat
#rm -f $scratch_output_dir/*.mat

tot_png_files=$(find $raw_data_dir -name *png | wc -l) # count the number of raw input inputs
tot_mat_files=$(find $raw_data_dir -name *mat | wc -l) # count the number of measured images
echo "$tot_mat_files measurements"
echo "$tot_png_files original raw images"

# copy generated files to output folder
cp $raw_data_dir/*.mat $data_output_dir # store a copy in data
cp $raw_data_dir/*.tsv $data_output_dir
cp $data_output_dir*.mat $scratch_output_dir # story a copy in scratch
cp $data_output_dir*.tsv $scratch_output_dir 

echo FINISHED: output has been written to:
echo - data: $data_output_dir
echo - scratch: $scratch_output_dir
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

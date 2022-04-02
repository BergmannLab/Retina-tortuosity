#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=MeasureVessels
#SBATCH --output=helpers/MeasureVessels/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/MeasureVessels/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 6G
#SBATCH --partition normal

####### --time 00-01:00:00
#SBATCH --time 00-03:30:00

####### --array=1-582 #UKBB
#SBATCH --array=1-26 #CoLaus is_color=False

source ../configs/config_sofia.sh
begin=$(date +%s)

### Run vessels measurements with ARIA (Matlab):

script_dir=$PWD/helpers/MeasureVessels/src/petebankhead-ARIA-328853d/ARIA_tests/

chunk_start=1 # TO DO!: CHANGE TO MAKE MORE EFFICIENT

script_parmeters="0 REVIEW $dir_images2 $classification_output_dir $TYPE_OF_VESSEL_OF_INTEREST $AV_threshold $script_dir $chunk_start $num_images  $dir_ARIA_output"

#OPTION 1
cd $script_dir && /Applications/MATLAB_R2020b.app/bin/matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('/Users/sortinve/develop/retina/'));ARIA_run_tests $script_parmeters ;quit;"

#OPTION 2: if only INTERPRETER IS AVAILABLE
# (after compiling using the compileMAT.sh in the ARIA_tests folder)
#$ARIA_dir/run_ARIA_run_tests.sh $matlab_runtime $script_parmeters

echo FINISHED: files have been written to: $dir_ARIA_output
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

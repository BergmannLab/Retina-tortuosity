#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=MeasureVessels
#SBATCH --output=helpers/MeasureVessels/slurm_runs_rnd/slurm-%x_%j.out
#SBATCH --error=helpers/MeasureVessels/slurm_runs_rnd/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 6GB
#SBATCH --partition normal

####### --time 00-01:00:00
#SBATCH --time 00-02:30:00

####### --array=1-582 for full ingestion
####### --array=1-36 for 7k sample
#SBATCH --array=1-582

############################################################################### 
ARIA_target="vein" # [artery|vein|all] # note, thoguht, that I am invoking ARIA with random AV calling
###############################################################################

source $HOME/retina/configs/config.sh
begin=$(date +%s)

# job array
j_array_params=$PWD/helpers/MeasureVessels/j_array_params.txt
PARAM=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $j_array_params)
chunk_start=$(echo $PARAM | cut -d" " -f1)
chunk_size=$(echo $PARAM | cut -d" " -f2)

# run vessels measurements with ARIA
script_dir=$PWD/helpers/MeasureVessels/src/petebankhead-ARIA-328853d/ARIA_tests/
path_to_output=$scratch/retina/preprocessing/output/MeasureVessels_rnd/
script_parmeters="0 REVIEW $ARIA_data_dir $AV_data_dir $ARIA_target $AVUncertain_threshold $script_dir $chunk_start $chunk_size $min_QCthreshold_1 $max_QCthreshold_1 $min_QCthreshold_2 $max_QCthreshold_2 $path_to_output"

# OPTION 1: if FULL MATLAB IS AVAILABLE
#cd $script_dir && matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('"$script_dir"/..'));ARIA_run_tests $script_parmeters ;quit;"

# OPTION 2: if only INTERPRETER IS AVAILABLE
# (after compiling using the compileMAT.sh in the ARIA_tests folder)
$ARIA_rndAVcalling_dir/run_ARIA_run_tests.sh $matlab_runtime $script_parmeters

echo FINISHED: files have been written to: $path_to_output
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

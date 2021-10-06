#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=MeasureVessels
#SBATCH --output=helpers/MeasureVessels/slurm_runs_all/slurm-%x_%j.out
#SBATCH --error=helpers/MeasureVessels/slurm_runs_all/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 8GB
#SBATCH --partition normal

####### --time 00-01:00:00
#SBATCH --time 00-24:30:00

####### --array=1-582 for full ingestion
####### --array=1-36 for 7k sample
##SBATCH --array=1-582
#SBATCH  --array=581,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,366,367,368,369,370,371,372,373,375,376,377,379,380,381,382,383,384,385,386
mcr_cache_root=/tmp/$USER/MCR_CACHE_ROOT${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
mkdir -pv $mcr_cache_root
export MCR_CACHE_ROOT=$mcr_cache_root

############################################################################### 
ARIA_target="all" # [artery|vein|all]
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
path_to_output=$scratch/retina/preprocessing/output/MeasureVessels_"$ARIA_target"/
script_parmeters="0 REVIEW $ARIA_data_dir $AV_data_dir $ARIA_target $AV_threshold $script_dir $chunk_start $chunk_size $min_QCthreshold_1 $max_QCthreshold_1 $min_QCthreshold_2 $max_QCthreshold_2 $path_to_output"

# OPTION 1: if FULL MATLAB IS AVAILABLE
#cd $script_dir && matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('"$script_dir"/..'));ARIA_run_tests $script_parmeters ;quit;"

# OPTION 2: if only INTERPRETER IS AVAILABLE
# (after compiling using the compileMAT.sh in the ARIA_tests folder)
$ARIA_dir/run_ARIA_run_tests.sh $matlab_runtime $script_parmeters

rm -rv $mcr_cache_root 2>&1 >/dev/null # clear cache

echo FINISHED: files have been written to: $path_to_output
end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: ${SLURM_ARRAY_TASK_ID} $tottime sec"

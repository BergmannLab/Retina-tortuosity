#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=imageStatsFromMeasurements
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 4GB
#SBATCH --partition normal
#SBATCH --array=1-40

if [ ! -f "imageIDs.txt" ]; then
    python3 saveImageIDs.py 0 600000
else
    echo "image ID file exists"
fi


# nb of image IDs: 116229
# therefore: 2906 images per batch
python3 segmentStatsToImageStats.py $(( 0 + $(( $(( ${SLURM_ARRAY_TASK_ID} - 1 )) * 2906 )) )) $(( 2905 + $(( $(( ${SLURM_ARRAY_TASK_ID} - 1 )) * 2906 )) ))

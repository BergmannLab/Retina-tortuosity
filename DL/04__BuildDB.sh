#!/bin/bash
##SBATCH --account=sbergman_retina
#SBATCH --job-name=BuildDB
#SBATCH --output=helpers/04/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/04/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 40G
#SBATCH --time 00-24:00:00
#SBATCH --partition normal

# To install the Python3 libraries tables, opencv_python, Pillow and sklearn:
#
# $ source /dcsrsoft/spack/bin/setup_dcsrsoft
#
# $ module load gcc python/3.7.7
#
# $ cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/
#
# $ tar -zxvf pk.tar.gz
#
# $ pip install --user --no-index --find-links=pk tables opencv_python Pillow sklearn

source $HOME/retina/configs/config.sh

# clear previous run
output_dir=$scratch/retina/DL/output/04_DB/
rm -f $output_dir/*pytable

input_dir=$scratch/retina/DL/output/utils/BuildTestDatasetHypertension/

normal_dir=$input_dir/normal/
hypertense_dir=$input_dir/hypertense/

# build Digital Pathology DB
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 helpers/04/BuildDB.py $normal_dir $hypertense_dir $output_dir
module purge

echo FINISHED: output has been written to $output_dir

#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --mail-type ALL
#SBATCH --mail-user philippe.jacquet@unil.ch
#SBATCH --job-name=BuildDB
#SBATCH --output=helpers/04/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/04/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 40G
#SBATCH --time 00-01:00:00
#SBATCH --partition normal

# To install the Python3 libraries tables, opencv_python, Pillow and sklearn:
# $ source /dcsrsoft/spack/bin/setup_dcsrsoft
# $ module load gcc python/3.7.7
# $ cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/
# $ tar -zxvf pk.tar.gz
# $ pip install --user --no-index --find-links=pk tables opencv_python Pillow sklearn

source $HOME/retina/configs/config.sh

##########################################################################
# CHOOSE DISEASE
input_dir=$scratch/retina/DL/output/utils/old_BuildTestDatasetHypertension/
#
#input_dir=$scratch/retina/DL/output/utils/BuildDatasetAngina/
#input_dir=$scratch/retina/DL/output/utils/BuildDatasetDiabetes
#input_dir=$scratch/retina/DL/output/utils/BuildDatasetDV_Thrombosis/
#input_dir=$scratch/retina/DL/output/utils/BuildDatasetHeart_Attack/
#input_dir=$scratch/retina/DL/output/utils/old_BuildDatasetHypertension/
#input_dir=$scratch/retina/DL/output/utils/BuildDatasetStroke/
#
# The Kanji dataset may be used to make sure that the pipeline works well, i.e. gives 100% validation accuracy
#input_dir=$scratch/retina/DL/output/utils/Kanji/
#input_dir=$scratch/retina/DL/output/utils/Kanji_Test/


controls_dir=$input_dir/controls/
cases_dir=$input_dir/cases/

# clear previous run
output_dir=$scratch/retina/DL/output/04_DB/
rm -f $output_dir/*pytable

# build DB
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 helpers/04/BuildDB.py $controls_dir $cases_dir $output_dir
module purge

echo FINISHED: output has been written to $output_dir

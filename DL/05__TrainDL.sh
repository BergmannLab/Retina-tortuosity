#!/bin/bash
##SBATCH --account=sbergman_retina
#SBATCH --mail-type ALL
#SBATCH --mail-user philippe.jacquet@unil.ch
#SBATCH --job-name=TrainDL
##SBATCH --nodelist=cpt03,cpt04,cpt05,cpt06 # Xeon Phi available on some cpts to train DL
##SBATCH --nodelist=cpt05
#SBATCH --output=helpers/05/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/05/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 01-00:00:00
#SBATCH --partition normal

# To install the Python3 libraries torch, torchvision and tensorboardX:
# $ source /dcsrsoft/spack/bin/setup_dcsrsoft
# $ module load gcc python/3.7.7
# $ cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/
# $ tar -zxvf torch.tar.gz
# $ pip install --user --no-index --find-links=torch torch torchvision tensorboardX

source $HOME/retina/configs/config.sh

# clear previous run
output_dir=$scratch/retina/DL/output/05_DL/
rm -f $output_dir/*

# image DB
db_dir=$scratch/retina/DL/output/04_DB/

# Train DL model
source /dcsrsoft/spack/bin/setup_dcsrsoft
module purge
module load gcc/8.3.0
module load python/3.7.7
module load py-biopython
python3.7 helpers/05/TrainDL.py $db_dir $gpuid $output_dir
module purge

echo FINISHED: output has been written to $output_dir

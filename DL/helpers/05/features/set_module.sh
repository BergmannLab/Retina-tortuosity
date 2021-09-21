module purge
source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc
module load python/3.7.10
pip install --user --no-index --find-links=/dcsrsoft/spack/downloads/pypi biopython
pip install --user --no-index --find-links=/dcsrsoft/spack/downloads/pypi matplotlib
pip install --user --no-index --find-links=/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/pk numexpr numpy pillow scipy
pip install --user --no-index --find-links=torch torch torchvision tensorboardX
#module purge

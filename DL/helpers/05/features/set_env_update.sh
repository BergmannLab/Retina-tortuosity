ch_dir=$(pwd)
source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc python/3.8.8
cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/
tar -zxvf torch.tar.gz
pip install --user --no-index --find-links=torch torch torchvision tensorboardX
cd $ch_dir

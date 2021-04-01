# retina

Run retina/configs/dir_structure/init.sh
  Assumes the following are configured as in Jura
  - a data location
  - an archive location
  - a scratch location

# Running the Code
## Accessing the code
The following commands should be run from your Jura home:

```
git clone git@gitlab.dcsr.unil.ch:retina_group/retina.git
cd retina
```

To use the deep learning branch:
```
git checkout deep_learning
```

The configuration file (written by Mattia) contains paths and parameter values:
   
```
cd ~/retina/configs
vi config.sh
```

## Creating the input/output folders
To create the necessary input/output folders in scratch for the pipeline to work (code written by Mattia).<br>

**PLEASE CHECK BEFORE RUNNING, THERE MAY BE TOO MANY FOLDERS CREATED BY THIS COMMAND**

```
cd ~/retina/configs/dir_structure
./init.sh
```

To build the train and validation dataset folders including retina images associated to a disease (code written by Mattia)<br>

**IMPORTANT: This is where you actually define the disease and normal classes, for example for hypertension.**

```
cd ~/retina/DL/helpers/utils/ 
vi BuildDataset.py
```

To run the code

```
cd ~/retina/DL/helpers/utils/BuildDatasetHypertension 
sbatch BuildDataset.sh
```

To make the train and validation pytables from the retina images:
```
cd ~/retina/DL/helpers/04/
vi BuildDB.py
```

## Installing the Python3 libraries tables, opencv_python, Pillow and sklearn:
```
source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc python/3.7.7
cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/
```

If the pk folder is NOT present:
```
tar -zxvf pk.tar.gz
pip install --user --no-index --find-links=pk tables opencv_python Pillow sklearn
```

## Building the database
Go to the DL directory and run the building script:
```
cd ~/retina/DL
vi 04__BuildDB.sh
sbatch 04__BuildDB.sh
```

To check the status of your run:
```
Squeue
```

To look at the "04__BuildDB.sh" slurm output:
```
cd ~/retina/DL/helpers/04/slurm_runs/
ll
less slurm-BuildDB_<last slurm output number>.out
```

To look at the pytables:
```
cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/04_DB/
ls
```

## Running the DL model on the pytable datasets:
IMPORTANT: here you can choose the hyper-parameters of the DL model:
```
cd ~/retina/DL/helpers/05
vi TrainDL.py
```

To install the Python3 libraries torch, torchvision and tensorboardX:
```
source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc python/3.7.7
cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/
```

If the torch folder is NOT present:
```
tar -zxvf torch.tar.gz
pip install --user --no-index --find-links=torch torch torchvision tensorboardX
```
## Training the DL model
Go to the DL directory and run the building script:
```
cd ~/retina/DL
vi 05__TrainDL.sh
sbatch 05__TrainDL.sh
```
To check the status of your run:
```
Squeue
```

To look at the "05__TrainDL.sh" slurm output:
```
cd ~/retina/DL/helpers/05/slurm_runs/
ll
less slurm-TrainDL_<last slurm output number>.out
```

To look at the "05__TrainDL.sh" results (Training and ROC curves):
```
cd /scratch/beegfs/FAC/FBM/DBC/sbergman/retina/DL/output/05_DL/
ls
```

To move the results to the "~/retina/DL" repository:
```
mv Training_Curves.pdf ~/retina/DL/helpers/05/results/Training_Curves_Hypertension_gr6_bc1_nif24_all_validation.pdf
mv ROC_Curve.pdf ~/retina/DL/helpers/05/results/ROC_Curve_Hypertension_gr6_bc1_nif24_all_validation.pdf
```
## Saving and accesing the results
To "push" all results to github:
```
cd ~/retina/DL
git add --all . && git commit -a -m "results"
git push
```

Finally on your laptop:
```
cd ~/retina/DL
git pull
```

You may modify the codes on your laptop, and then "push" these modifications on github:
```
cd <your path>/retina/DL
git add --all . && git commit -a -m "my modifications"
git push
```
Then you "pull" these changes on Jura:
```
cd ~/retina/DL
git pull
```
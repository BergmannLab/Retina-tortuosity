# Tortuosity measurement and GWAS

## Introduction:
####  Fundus Image - basic notions:
We are using the image from the UKBB, particularly the datafields: `21015’ - Fundus retinal eye image left ( https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=21015 ) and the `21016’ - Fundus retinal eye image right ( https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=21016 ). 

As you can see on the links by clicking in ‘2 Instances’, there are two instances 0 and 1, which in turn can be divided into 0 and 1, i.e. in total, we have 0_0, 0_1 , 1_0 and 1_1  (_1 means that they repeated the image in general because the first try was not clear). 

So for some subjects, we are going to have images at different points in time. 

The images that you are going to find are written as, for example: 101771_21016_0_0.png i.e. subject’s eid = 101771, right eye image because 21016 and instance 0_0.

Note -> This code is prepared to work on UKBiobank data, use in in other type of images would require some changes.


####  '/config' include a folder '/dir_structure' this creates the structure needed, and assumes the following are configured (if not please modified):
  - a data location
  - an archive location
  - a scratch location


## Preprocessing (from images to phenotypes):

### Step 0: How to measure a vessel phenotype (Only needed to do this if you want to measure new traits):
1) Navigate to the file 'preprocessing/helpers/MeasureVessels/src/petebankhead-ARIA-328853d/Vessel_Classes/Vessel_data_IO.m'
2) The actual measurables, for each image, are stored in the variable stats_array. stats_array(1) is the first measurable, stats_array(2) the second, etc. Put whatever you measured in this variable.
3) Name all your measurables in corresponding order into the variable stats_names.
“name1\tname2\t...”
4) Navigate to file: '/GWAS/helpers/VesselStatsToPhenofile/run.py'
and add the same measurable names there, also in corresponding order
5) Commit code, compile ARIA, etc...


### Step 1: Pull from repo and compile matlab code:
*Every time you have changed the code, or if it is the first time that you use it, you have to begin with this step:*
- Make sure you have your server /retina up-to-date. If not, make a pull
- Then, go inside 'preprocessing/helpers/MeasureVessels/src' open the txt ¨how_to_compile¨ and follow the instructions. But, in step 3) you are going to replace the executable, in order to make sure we can redo our steps if something goes wrong, please save the last executable with another name before making step 3).

REMARK: You should have already the folder retina (and up-to-date), if this is not the case you have to clone the branch you want to work with 


### Step 2: ClassifyAVLwnet.sh (LWNET needed, you need to instal it (in python))
- *Description*: Slurm (cluster job management) script to automatically classify arteries and veins in raw retina fundus images. Before running it on a cluster, it may be worth installing the software on a laptop and playing around with predict_one_image.py (https://github.com/agaldran/lwnet) 
- *Before running the script*: One has to install lwnet on the server (personal computer)
Script location: 'preprocessing/ClassifyAVLwnet.sh'
- *Input location*: important to first copy the input files to scratch, and then delete them to make space for other people.
- *Output location*: wherever one chooses.
- *Approximate running time*: less than a day for all the images in the UK Biobank. 
- *After running the script*: the number of images in the output folder should be twice as many as in the input folder (command: ls | wc -l).



### Step 3: MeasureVessels.sh (Matlab needed, in Matlab (ARIA modfied is included in the repository, no need to instal))
- *Description*: In our case we are going to run 528 jobs on the cluster, so each one of these jobs are going to start to create an output. You have 3 possible scripts, MeasureVessels_all.sh, MeasureVessels_artery.sh and MeasureVessels_vein.sh. Run the one you want to work on (all is without using LWNET information, analyzing all the vessesls that ARIA detects). 
To run the script, once you are in the script location, type: `sbatch MeasureVessels_all.sh'
- *Before running the script*: 

  a) Open 'cd preprocessing/helpers/MeasureVessels/slurm_runs_all' and if there is something for the previous run you can delete it. Have it open during the run to verify that output is being generated.
  
  b) Open path_to_output : 'cd /scratch/beegfs/FAC/FBM/DBC/sbergman/' and 'cd preprocessing/output' and once you are there 'ls MeasureVessels_all  | wc -l' to check how many files are inside of there. Initially should be 0, if not delete the files. Once you run the script files are going to appear here.
  
- *Script location*: preprocessing/
- *Input location*: images
- *Output location*: '/scratch/beegfs/FAC/FBM/DBC/sbergman/' and  'preprocessing/output'
- *Approximate running time*: 2 hrs (all UKB bank images)
- *After running the script*: You can type: 'squeue  |  grep YourUsername' to see what is happening in the cluster. 
And, to check there are no more than 3 errors you can go to 'cd /preprocessing/helpers/MeasureVessels' and type './slurm_errors_inspect.sh'
You can see a picture of the comprobations below:
<img width="950" alt="image" src="https://user-images.githubusercontent.com/51050291/199187992-f4a32bfa-da97-4cf3-8e0d-aef7aa21d634.png">


### Step 4: StoreMeasurements.sh
- *Description*: You have 3 possible scripts, StroreMeasurements_all.sh, StroreMeasurements_artery.sh or StroreMeasurements_vein.sh. Run the one you want to work on. And to run the script type: ./StoreMeasurements_all.sh 
- *Before running the script*: Check that the previous script has finished
- *Script location*: '/preprocessing/'
- *Input location*: 'scratch/retina/preprocessing/output/MeasureVessels_all' (the place where the previous script put their outputs)
- *Output location*: 'archive/retina/preprocessing/output/StoreMeasurements/' and 'scratch/retina/preprocessing/output/backup/$run_id'
- *Approximate running time*: approx 1h to copy the images in the backup and to create a tar.gz file. Once the process is completely finished it will automatically move this tar.gz to the archive and will delete it from the backup (this takes approx 2h).
- *After running the script*: A directory is going to be created with the date of today in '/scratch/retina/preprocessing/output/backup'

NOTE -> At this stage you have already the traits (tortuosities and others) computed for each images. You can do step 5 to have all in one file.


## GWAS (from phenotypes to summary statistics):

### Step 5: VesselStatsToPhenofile.sh
- *Description*: This step is to change all the vessel's statistics that you have created by MeasureVessels into a Phenofile. 
Go to the script location and on it, change the ‘stats_dir’ with the name of the output that you have generated in the previous step (and save the change in the script). To run the script type 'sbatch VesselStatsToPhenofile.sh'
-> Remark: Again you have 3 possible scripts
- *Before running the script*: Check the backup of the previous step has finished
- *Script location*: 'GWAS/'
- *Input location*: 'scratch/retina/preprocessing/output/backup/$run_id'
- *Output location*: 'scratch/retina/GWAS/output/VesselStatsToPhenofile/' 
- *Approximate running time*: <30 min 
- *After running the script*: To check everything is working open: 'scratch/retine/GWAS/output/VesselStatsToPhenofile/'
New 2 files will appear once we run the command. Also, to check the script is running type: 
'squeue | grep yourusername'

### Step 6: Create covariates file (prepare a covariate file required for BGENIE GWAS)
- `./run_extractCovariates.sh`
- In `configs/config.sh`, specify `NB_PCS`, how many PCs are included as covariates.
- In `GWAS/extractCovariates.py`, further choose which UKBB datafields to choose as covariates. Currently used:
* sex
* age and age-squared when visiting assessment center
* 20 PCs

### Step 7: RunGWAS.sh (Need  to install BGENIE (https://jmarchini.org/bgenie/): Compute GWAS on given phenofile)
- *Description*: 
  a) Go to the script location and on it, change the ‘experiment_id’ with the name of the folder you have created (before running the script). Also check if the ‘pheno_file’ (in the script) is pointing to your phenofile_qqnorm.cvs, if not, change it.
  b) In ‘chromosome_file’ you have to decide if you want a run fast or a detailed one, the last one is the one to final results. For the first one write ’_subset _mini.bgen’ and for the last one ’_subset.bgen’ (and save the change in the script). 
  c)To run the script type 'sbatch RunGWAS_62751_all_with_covar.sh'
REMARK: Again you have 3 possible scripts, _all, _artery and _veins

- *Before running the script*: Create a folder in the previous output ('scratch/retine/GWAS/output/VesselStatsToPhenofile/') and move your three files in there ('phenofile.csv', 'phenofile_NotinSamplefile.csv', 'phenofile_qqnorm.csv')
- *Script location*: '/GWAS'
- *Input location*: The new folder created in before running the script.
- *Output location*: '/GWAS/output/RunGWAS/”$experiment_id”'
- *Approximate running time*: for ‘_mini’ approx 4h
- *After running the script*: To check the script is running type: 'squeue | grep yourusername'. Type 'cd /GWAS/helpers/RunGWAS/slurm_runs/' and check if there are errors (If there were previous files you can delete them).
Also, in the output location, should have been created a new folder with 23 files.

## GWAS post-processing (R needed):
### 8.1: Visualizations- Manhattan, QQ:

- Description: This step consists in running a simple R script on your machine. Using the GWAS output files from Jura you will have a ‘QQPLOT’ and ‘MANHATTAN’ plot, for each phenotype included in the R code.

- Before running the script: Take GWAS output files from Jura, sftp them to a folder in local and run gzip -d * in that folder. The files will be transformed to txt format (you can even read them with a txt reader like vim). Place the script in the same folder. Open R studio.
Change the path at the top of the script to point to your folder and press "source" to run the whole file.
 
REMARK: If you have not, install RStudio in your computer. Then install theses in your RStudio:
#install.packages("qqman")
#install.packages("BiocManager")
#BiocManager::install("GWASTools")
 
- Script location: 'GWAS/helpers/utils/ManhattanQQplot'
- Input location: GWAS output files from Jura
- Output location: The folder you have created
- Approximate running time: A few minutes for _mini, a few hours for the detailed one

- After running the script: Check the output is not empty. Below there is an QQ and a Manhattan plot example:
<img width="1093" alt="image" src="https://user-images.githubusercontent.com/51050291/199192357-1b3edc7c-2a99-4b32-a267-e572c1d02ed0.png">



### 8.2: Prepare PascalX (https://bergmannlab.github.io/PascalX/usage.html) and LDSC (https://github.com/bulik/ldsc) input for downstream analyses
Export results to text formats
- Description: This step consists in running a simple R script on your machine. The script is called ‘hit_to_csv.R’ As a result you will obtain ‘topHits’ and ‘pascalInput’ csvs for each phenotype.
- Before running the script: There are some instructions on the head of the script. Make sure to follow them. Also, change the direction of: setwd("/Users/...") . It should be pointing to the location of your folder.
- Script location: 'GWAS/helpers/utils/HitsExtract/'
- Input location: 'GWAS/helpers/utils/HitsExtract/'
- Output location: 'GWAS/helpers/utils/HitsExtract/'
- Approximate running time:  A few minutes for _mini or a few hours for the detailed one
- After running the script: Check the output is not empty

### 8.3: Prune results
- Description: This step consists in running a R script on your machine. 
There are 4 scripts: ‘LD_prune_all.R’, ‘LD_prune_artery.R’, ‘LD_prune_vein.R’  and ‘merge_LD_pruned_results_artery_vein_all.R’ , the last script merge the results of all the previous.
- Before running the script: When the script is running you have to be on internet
- Script location: 'GWAS/helpers/utils/HitsExtract/'
- Input location: 'GWAS/helpers/utils/HitsExtract/'
- Output location: 'GWAS/helpers/utils/HitsExtract/'
- Approximate running time: Very variant, between 1h and several hours
- After running the script: Check the correctness of the files generated

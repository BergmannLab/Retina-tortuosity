#!/bin/bash
#SBATCH --account=sbergman_retina
#SBATCH --job-name=StoreMeasurements_all
#SBATCH --output=helpers/StoreMeasurements/slurm_runs/slurm-%x_%j.out
#SBATCH --error=helpers/StoreMeasurements/slurm_runs/slurm-%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1GB
#SBATCH --time 00-01:00:00
#SBATCH --partition normal

# prevent running via SBATCH
if [ ! $SLURM_JOB_ID == "" ]; then
  echo "ERROR: (for now) this script cannot be run via sbatch."
  echo "       (/archive is not mounted on cpt nodes)"
  echo "Please, run on FRONT NODE (consider using SCREEN)"
  exit 1 # erorr status
fi

source $HOME/retina/configs/config.sh
begin=$(date +%s)

run_id=$(date +%Y_%m_%d__%H_%M_%S)_all
input_dir=$scratch/retina/preprocessing/output/MeasureVessels_all/
archive_dir=$archive/retina/preprocessing/output/StoreMeasurements/
backup_dir=$scratch/retina/preprocessing/output/backup/$run_id
mkdir $backup_dir

tot_png_files=$(find $raw_data_dir -name *png | wc -l) # count the number of raw input inputs
tot_mat_files=$(find $input_dir -name *imageStats.tsv | wc -l) # count the number of measured images
echo "$tot_mat_files measurements"
echo "$tot_png_files original raw images"

# back up in scratch - will be used by next step of the pipeline
# (cannot use cp: list of file too long)
rsync -r --include='*.mat' --exclude='*' $input_dir $backup_dir
rsync -r --include='*.tsv' --exclude='*' $input_dir $backup_dir

# archive on tape - will not be read again
cd $backup_dir/..
tar -zcf $run_id.tar.gz $run_id
mv $run_id.tar.gz $archive_dir

echo FINISHED: output has been written to: $backup_dir and $archive_dir

end=$(date +%s) # calculate execution time
tottime=$(expr $end - $begin)
echo "execution time: $tottime sec"

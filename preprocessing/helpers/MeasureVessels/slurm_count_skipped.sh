p=$(grep -R "processing: " slurm_runs_all | wc -l)
echo "$p images were processed"
s=$(grep -R "SKIPPING" slurm_runs_all | wc -l)
echo "$s of which were skipped"

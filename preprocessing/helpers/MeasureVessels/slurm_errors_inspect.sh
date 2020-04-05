tot_files=$(ls slurm_runs | wc -l)
tot_runs=$((tot_files/2))
echo "TOT: $tot_runs runs ($tot_files files in slurm_runs)"
success_runs=$(find slurm_runs -type f -name '*.err' -exec du -ch {} + | grep 512 | wc -l)
error_runs=$(find slurm_runs -type f -name '*.err' -exec du -ch {} + | grep -v 512 | wc -l)
echo "$success_runs OK"
echo "$error_runs ERROR"

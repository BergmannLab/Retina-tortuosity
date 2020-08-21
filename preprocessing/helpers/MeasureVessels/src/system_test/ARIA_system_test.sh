1) creating of an automated system test (to make sure things work after having refactor)
- take measureVessels.sh form Jura and move it to laptop
- remove all the slurm directives at the top
- copy data form Jura to laptop: fundus images and AV maps
- make the local measureVessels point to the copy of the data
- write a script called ARIA_system_test.sh which invokes measureVessels
- run it
- in output you will have stats files (e.g. 1018771_21016_0_0_stats.tsv)
- put the stats file in an "expected output"
- add code to the ARIA_system_test.sh script that checks that the outputs of new runs match "expected output"
  (i.e. make a loop that diffs test output and expected output)

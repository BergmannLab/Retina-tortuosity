#!/bin/bash

arr=( $(ls *.txt.sumstats.gz) )
N=${#arr[@]}

for i in $(seq 0 $N)-1 
do
	for j in $(seq 1 $N)-1
	do
		echo Pair: ${arr[i]} - ${arr[j]}
		nohup ldsc.py --rg ${arr[i]},${arr[j]} --ref-ld-chr ../../eur_w_ld_chr/ --w-ld-chr ../../eur_w_ld_chr/ --out ${arr[i]}_${arr[j]} &
	done
done 

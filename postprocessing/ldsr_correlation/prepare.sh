#!/bin/bash

for f in *.txt;
do
	nohup munge_sumstats.py --sumstats $f --out $f --merge-alleles ../../eur_w_ld_chr/w_hm3.snplist &
done

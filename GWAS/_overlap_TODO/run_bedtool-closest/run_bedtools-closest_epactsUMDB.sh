#!/bin/bash

# to be run from JADE

bedtools=/h-sara0/anneke/scratch/software/bedtools2/bin/bedtools
bedfile_1=confirmed_hits.bed
bedfile_2=epacts_UMDB.bed

$bedtools closest -a $bedfile_1 -b $bedfile_2 > confirmed_epacts_UMDB.bed

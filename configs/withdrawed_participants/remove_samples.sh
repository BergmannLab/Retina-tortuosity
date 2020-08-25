#!/bin/bash

source $HOME/retina/configs/config.sh
data_dir=$raw_data_dir # taken from config file

echo Removing files corresponding to participant that have withdrawn consents

function remove_files(){
  input=$1
  dos2unix server_list.txt
  echo Processing file $input
  while IFS=\t read -r eid
  do
    echo "Removing files for participant" "$eid"
    rm "$data_dir"/"$eid"_21015_0_0.png
    rm "$data_dir"/"$eid"_21016_0_0.png
    rm "$data_dir"/"$eid"_21015_1_0.png
    rm "$data_dir"/"$eid"_21016_1_0.png
  done < $input
}

remove_files "w43805_20200204.csv"
remove_files "w43805_20200820.csv"

echo Done.

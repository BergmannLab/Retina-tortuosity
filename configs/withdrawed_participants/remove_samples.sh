#!/bin/bash

source $HOME/retina/configs/config.sh
data_dir=$raw_data_dir # taken from config file
archive_dir=$raw_archive_dir # from config file too

echo Removing files corresponding to participant that have withdrawn consents

function remove_files(){
  input=$1
  echo Processing file $input
  while IFS=\t read -r eid
  do
    echo "Removing fundus images for participant" "$eid"
    
    # rm -f "$data_dir"/"$eid"* # this was too slow, probably because it has to search through huge image directory each time
    
    for i in 21015 21016 ; do
        for j in 0 1 ; do
            for k in 0 1; do
                rm -f "$data_dir"/"$eid"_"$i"_"$j"_"$k".png;
		rm -f "$archive_dir"/"$eid"_"$i"_"$j"_"$k".png;
            done
        done
    done
  done < $input
}

remove_files $archive/UKBiob/withdrawed_participants/"w43805_20200204.csv" #DONE
remove_files $archive/UKBiob/withdrawed_participants/"w43805_20200820.csv" #DONE
remove_files $archive/UKBiob/withdrawed_participants/"w43805_20210809.csv" #DONE
remove_files $archive/UKBiob/withdrawed_participants/"w43805_20220222.csv"

echo Done.

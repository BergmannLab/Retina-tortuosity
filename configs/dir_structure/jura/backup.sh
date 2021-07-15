# back up folder structure in scratch, data, archive

source $HOME/retina/configs/config.sh

find $scratch/retina -type d > $PWD/dirs/scratch.txt
find $data/retina -type d > $PWD/dirs/data.txt
find $archive/retina -type d > $PWD/dirs/archive.txt

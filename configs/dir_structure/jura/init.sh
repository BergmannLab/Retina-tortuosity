# Build necessary folder structure in scratch, data, archive

source $HOME/retina/configs/config.sh

xargs mkdir -p < $PWD/dirs/scratch.txt
xargs mkdir -p < $PWD/dirs/data.txt
xargs mkdir -p < $PWD/dirs/archive.txt

# Retina images traits: 

## Traits measured:
* Median diameter of: all the vessels, only arteries, only veins (' ')
* Median tortuosity of: all the vessels, only arteries, only veins (' ')
* Ratio between the diameters of the arteies and the diameters of the veins (' ')
* Ratio between the tortuosity of the arteies and the tortuosity of the veins (' ')
* Number of bifurcations and branching ('bifurcations')
* Main Temporal Venular Angle ('tva')
* Main Temporal Arteriolar Angle ('taa') 
* TO DO: define N_green or others 
* Fractal Dimensionality 


## Requirements:

* You will need to download WNET 
* Matlab licence (if you have not acess there are still some traits you can measure)

## Pipeline:
1- Modify `configs/config_sofia.sh`

2 - Run `preprocessing/ClassifyAVLwnet_sofia.sh`. Output: AV maps for your images 

3 - Run `preprocessing/MeasureVessels_Sofia.sh`. Output: Matlab output

4 - Run `preprocessing/run_measurePhenotype_sofia.sh`. Output: Trait measurements


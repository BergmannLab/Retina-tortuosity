setwd("/Users/sortinve/Desktop/Artery_Vein/2021_03_10_segmentLengthsQuintilesImageStatsArteries/")
list_pheno <- c("DF1st","DF2nd","DF3rd","DF4th","DF5th")

source("plotGWAS.R")
foo_plotGWAS(list_pheno)

source("hit_to_csv.R")
foo_hit_to_csv(list_pheno)

source("prepare_input.R")
foo_prepare_input(list_pheno)

# source("LD_prune_all.R")

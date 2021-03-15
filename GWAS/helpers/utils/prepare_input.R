# INPUT: ldscInput file produce by hit_extract/hit_to_csv.R
# this script generates in put for LD Hub http://ldsc.broadinstitute.org/ldhub/
# (calcultion of SNP heritability and rg, i.e., genetic correlation with other traits)

#setwd("/Users/sortinve/Desktop/Artery_Vein/2021_03_10_segmentLengthsQuintilesImageStatsArteries/Output/")
# pheno_list <- c("DF1st","DF2nd","DF3rd","DF4th","DF5th")

foo_prepare_input <- function(pheno_list) {
  for (pheno_name in pheno_list) {
    
    ldscInput <- read.table(paste(pheno_name,"__ldscInput.csv", sep=""), sep="\t",
                            header=T, stringsAsFactors= F)
    ldscInput['N']=62751 # add a column with sample size
    write.table(ldscInput, file=paste(pheno_name,"__ldscInput_withN.txt", sep="")
                ,row.names = FALSE, quote=FALSE, sep='\t')
  }
}
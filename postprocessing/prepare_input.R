# INPUT: ldscInput file produce by hit_extract/hit_to_csv.R
# this script generates in put for LD Hub http://ldsc.broadinstitute.org/ldhub/
# (calcultion of SNP heritability and rg, i.e., genetic correlation with other traits)
# setwd("/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/GWAS/tVA/2022_02_14_tVA_ageCorrectedVentile5QC/")
# pheno_list <- c("tVA")

for (pheno_name in pheno_list) {
  
  ldscInput <- read.table(paste(pheno_name,"__ldscInput.csv", sep=""), sep="\t",
                          header=T, stringsAsFactors= F)
  ldscInput['N']=62751 # add a column with sample size
  write.table(ldscInput, file=paste(pheno_name,"__ldscInput_withN.txt", sep="")
              ,row.names = FALSE, quote=FALSE, sep='\t')
}
# INPUT: ldscInput file produce by hit_extract/hit_to_csv.R
# this script generates in put for LD Hub http://ldsc.broadinstitute.org/ldhub/
# (calcultion of SNP heritability and rg, i.e., genetic correlation with other traits)

ldscInput <- read.table("ldscInput.csv", sep="\t",header=T, stringsAsFactors= F)
ldscInput['N']=62751 # add a column with sample size
write.table(ldscInput, file="ldscInput_withN.txt",row.names = FALSE, quote=FALSE, sep='\t')

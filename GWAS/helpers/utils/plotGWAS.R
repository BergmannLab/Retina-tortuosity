#install.packages("qqman")
#install.packages("BiocManager")
#BiocManager::install("GWASTools")
library(qqman)
library(GWASTools)
# setwd("/Users/sortinve/Desktop/Artery_Vein/2021_03_10_segmentLengthsQuintilesImageStatsArteries/")

# INSTRUCTIONS 
# - take GWAS output files from Jura and ungz-them (run gzip -d *)
# - place resulting txt files in the same folder as this script
# OUTPUT
# - for each phenotype: genomewide qqplot and manhattan plot

########################## FUNCTIONS ###############################

plotPvals <- function(name,pheno,do_qqplot,do_manhattan){
  # rename according to qqman requirements: SNP CHR BP P
  colnames(pheno) <- c("CHR","SNP","BP","P")
  pvalues <- `^`(10,-pheno$P) # transform -log10 p values
  pheno$P <- pvalues
  if(do_qqplot){
    try(GWASTools::qqPlot(pvalues, main=name))
  }
  if(do_manhattan){
    try(qqman::manhattan(pheno, main=name))
  }
}

Plot_QQ_Manhattan <- function(pheno, inputs){
  jpeg(file= paste( pheno, "_QQPLOT", sep=""), width=2000,height=1000)
  plotPvals(paste(pheno), inputs ,TRUE,FALSE)
  dev.off()
  jpeg(file= paste( pheno, "_MANHATTAN", sep=""), width=2000,height=1000)
  plotPvals(paste(pheno),inputs,FALSE,TRUE)
  dev.off()
}

################################## INIT ####################################

# aggregate GWAS results from each chromo
# pheno_list <- c("DF1st","DF2nd","DF3rd","DF4th","DF5th")

foo_plotGWAS <- function(pheno_list) {
  for (pheno_name in pheno_list){ # FOR EACH PHENOTYPE in GWAS
    write(paste("phenotype:",pheno_name), stdout())
    
    gwasResults_allChr__phenotype <- data.frame()
    for (i in c(1:22)){
      write(paste0("processing chromo",i), stdout())
      
      gwasResults <- read.table(paste("output_ukb_imp_chr", i,"_v3.txt", sep=""), sep=" ",header=T, stringsAsFactors= F)
      # gwasResults <- subset( gwasResults, select = -c( 60  : 63 )) # Sofia deleting tau0, because is always NA
      # gwasResults[is.na(gwasResults)] <- 0 # Sofia
      gwasResults <- gwasResults[complete.cases(gwasResults), ] # drop NAs (can happen when maf=1) 
      
      # Phenotype:
      pval_header <- paste(pheno_name,".log10p",sep="")
      pheno <- subset(gwasResults, select = c("chr","rsid","pos", pval_header))
      gwasResults_allChr__phenotype <- rbind(gwasResults_allChr__phenotype, pheno)
      
      Plot_QQ_Manhattan(pheno_name, gwasResults_allChr__phenotype)
    }
  }
}








#!/bin/R

library(parallel)

args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

phenos=read.table("phenotypes.txt")
phenos=as.character(as.vector(phenos[1,]))
print(phenos)



# INSTRUCTIONS
# - (if some chromosomes are missing, initialize chromo_list accordingly)
# OUTPUT
# - [pheno]__topHits: csv of GWAS hits (the text version of a Manhattan plot)
# - [pheno]__locusZoomInput: for locusZoom analysis
# - [pheno]__pascal2Input: for pascalX
# - [pheno]__pascal2Input: for pascal2 (a thresholded version of __pascal2Input)
# - [pheno]__ldcsInput: for LDSC (LD score regression)

# INITIALIZE APPROPRIATELY ####################################################
pheno_list = phenos


# pheno_list <- c("longCenter","longPeriphery","longAndMidDiam","longOrMidDiam")
chromo_list <- c(1:22)
# INITIALIZE APPROPRIATELY ####################################################


process_pheno = function(pheno_name) { # FOR EACH PHENOTYPE in GWAS
  write(paste("phenotype:",pheno_name), stdout())
  top_hits <- data.frame() # genomewide hits: merge all chromosomes
  locusZoomInput <- data.frame() # also used for FUMA
  pascal2Input <- data.frame()
  pascalInput <- data.frame()
  ldscInput <- data.frame()
  
  for (chromo_numb in chromo_list){ # FOR EACH CHROMOSOME
    write(paste("chromosome",chromo_numb), stdout())
 
    # ukbb
    # chromo_name <- paste("output_ukb_imp_chr",chromo_numb,"_v3.txt", sep="")
    # colaus
    chromo_name <- paste("output_CoLaus.HRC.chr",chromo_numb,".MAFsubsetted.txt", sep="")
    gwasResults <- read.table(chromo_name, sep=" ",header=T, stringsAsFactors= F)
    gwasResults <- gwasResults[complete.cases(gwasResults), ] # drop NAs (can happen when maf=1)
    # colaus-specific line:
    gwasResults <- gwasResults[gwasResults$af>0.05,]
    
    pval_header <- paste(pheno_name,".log10p",sep="")
    beta_header <- paste(pheno_name,"_beta",sep="")
    se_header <- paste(pheno_name,"_se",sep="")
    # select top hits from chromo
    hits_in_chromo <- subset(gwasResults, select = c("chr","rsid","pos","a_0","a_1",pval_header,beta_header, se_header,"af","info"))
    top_hits_in_chromo <- hits_in_chromo[hits_in_chromo[pval_header]>=7.301, ] # Bonferroni = -log10(5E-8) = 7.301
    if(nrow(top_hits_in_chromo)>0) { # perform QC (if there are any significant SNPs)
      top_hits_in_chromo <- top_hits_in_chromo[top_hits_in_chromo["af"]>=0.0005, ] # QC on MAF: "af">=0.0005? (with 63899 samples, that's 30+ subjects)
    }
    if(nrow(top_hits_in_chromo)>0) { # perform QC (if there are any significant SNPs... after QC on MAF)
      top_hits_in_chromo <- top_hits_in_chromo[top_hits_in_chromo["info"]>=0.3, ] # QC on quality of imputation: "info">0.3 https://pubmed.ncbi.nlm.nih.gov/25293720/
    }
    top_hits <- rbind(top_hits, top_hits_in_chromo) # add chromosome hits to genomewide list
    # add chromosome to locusZoom input list
#    locusZoomInput_in_chromo <- subset(hits_in_chromo, select = c("rsid",pval_header))
#    pvalues <- `^`(10,-locusZoomInput_in_chromo[[2]]) # transform -log10 p values
#    locusZoomInput_in_chromo[2] <- pvalues
#    locusZoomInput <- rbind(locusZoomInput, locusZoomInput_in_chromo)
    # add chromosome to pascal input list
    pascalInput_in_chromo <- subset(gwasResults, select = c("chr","rsid","pos",pval_header,beta_header, se_header))
    pvalues <- `^`(10,-pascalInput_in_chromo[[4]]) # transform -log10 p values
    pascalInput_in_chromo[4] <- pvalues
    pascalInput <- rbind(pascalInput, pascalInput_in_chromo)
    # add chromosome to pascal2 input list (just threshold pascalInput results)
    top_pascalInput_in_chromo <- pascalInput_in_chromo[pascalInput_in_chromo[pval_header]<0.05, ] # cut off 0.05
    pascal2Input <- rbind(pascal2Input, top_pascalInput_in_chromo)
    # add chromosome to ldsc input list
   ldscInput_in_chromo <- subset(gwasResults, select = c("rsid","a_0","a_1",pval_header,beta_header))
   pvalues <- `^`(10,-ldscInput_in_chromo[[4]]) # transform -log10 p values
   ldscInput_in_chromo[4] <- pvalues
   ldscInput <- rbind(ldscInput, ldscInput_in_chromo)
  }
  
  # output top hits for pheno (visual inspection and plotting)
  write.csv(top_hits,paste(pheno_name,"__topHits.csv",sep=""),row.names = FALSE,quote=FALSE)
  # output for locusZoom / FUMA (cols: MarkerName, P-value)
#  names(locusZoomInput) <- c("MarkerName", "P-value") # rename headers appropriately
#  write.csv(locusZoomInput,paste(pheno_name,"__locusZoomInput.txt",sep=""),row.names = FALSE,quote=FALSE)
  # output for pascal
  names(pascalInput)[4] <- "pvalue" # rename headers appropriately
  write.csv(pascalInput,paste(pheno_name,"__pascalInput.csv",sep=""),row.names = FALSE,quote=FALSE)
  # output for pascal2
  names(pascal2Input)[4] <- "pvalue" # rename headers appropriately
  write.csv(pascal2Input,paste(pheno_name,"__pascal2Input.csv",sep=""),row.names = FALSE,quote=FALSE)
  # output for LDSC
  names(ldscInput) <- c("rsid","A1","A2","P","beta")
  write.table(ldscInput, file=paste(pheno_name,"__ldscInput.csv",sep=""),row.names = FALSE, quote=FALSE, sep='\t')
  ldscInput <- read.table(paste(pheno_name, "__ldscInput.csv", sep=""), sep="\t",header=T, stringsAsFactors= F)
  ldscInput['N']=63247 # add a column with sample size
  write.table(ldscInput, file=paste(pheno_name, "__ldscInput_withN.txt", sep=""),row.names = FALSE, quote=FALSE, sep='\t')

}

mclapply(pheno_list, process_pheno, mc.cores=15) # too many cores will use too much memory

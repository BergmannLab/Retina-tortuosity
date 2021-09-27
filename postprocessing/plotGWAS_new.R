#install.packages("qqman")
#install.packages("BiocManager")
#BiocManager::install("GWASTools")
#library(qqman)
#library(GWASTools)
setwd("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/GWAS/output/RunGWAS/2021_08_26_subsampleGWAS_N1000/1/")


# FUNCTIONS


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


plotPv <- function(name,pheno,do_qqplot,coleur, adding){
  # rename according to qqman requirements: SNP CHR BP P
  colnames(pheno) <- c("CHR","SNP","BP","P")
  pvalues <- `^`(10,-pheno$P) # transform -log10 p values
  pheno$P <- pvalues
  if(do_qqplot){
    try(GWASTools::qqPlot(pvalues, main=name, col = coleur, add = adding, 
                          ylim=c(-1,150),xlim=c(-1,7)))
  }
}

Plot_QQ_Manhattan <- function(pheno, inputs )
{
  jpeg(file= paste(pheno, "_QQPLOT", sep=""), width=2000,height=1000)
  plotPvals(paste(pheno), inputs ,TRUE,FALSE)
  dev.off()
  jpeg(file= paste(pheno, "_MANHATTAN", sep=""), width=2000,height=1000)
  plotPvals(paste(pheno),inputs,FALSE,TRUE)
  dev.off()
}


# INIT


# aggregate GWAS results from each chromo

# gwasResults_allChr__median_diameter <- data.frame()
# gwasResults_allChr__D9_diameter <- data.frame()
# gwasResults_allChr__median_tortuosity <- data.frame()
# gwasResults_allChr__short_tortuosity <- data.frame()
# gwasResults_allChr__D9_tortuosity <- data.frame()
# gwasResults_allChr__D95_tortuosity <- data.frame()
# gwasResults_allChr__tau1_tortuosity <- data.frame()
# gwasResults_allChr__ht <- data.frame()
# gwasResults_allChr__ht_INT <- data.frame()
gwasResults_allChr__DF <- data.frame()
# gwasResults_allChr__DF1st <- data.frame()
# gwasResults_allChr__DF2nd <- data.frame()
# gwasResults_allChr__DF3rd <- data.frame()
# gwasResults_allChr__DF4th <- data.frame()
gwasResults_allChr__DF5th <- data.frame()
# gwasResults_allChr__tau1 <- data.frame()
# gwasResults_allChr__tau2 <- data.frame()
# gwasResults_allChr__tau3 <- data.frame()
# gwasResults_allChr__tau4 <- data.frame()
# gwasResults_allChr__tau5 <- data.frame()
# gwasResults_allChr__tau6 <- data.frame()
# gwasResults_allChr__tau7 <- data.frame()
# gwasResults_allChr__nVessels <- data.frame()

# gwasResults_allChr__DF5th <- data.frame()
# gwasResults_allChr__DF <- data.frame()
# gwasResults_allChr__DF1_DF2 <- data.frame()
# gwasResults_allChr__DF1_DF5 <- data.frame()

for (i in c(1:22)){
  write(paste0("processing chromo",i), stdout())
  
  #UKBB
  gwasResults <- read.table(paste("output_ukb_imp_chr", i,"_v3.txt", sep=""), sep=" ",header=T, stringsAsFactors= F)
  #COLAUS
  # gwasResults <- read.table(paste("output_CoLaus.HRC.chr", i,".txt", sep=""), sep=" ",header=T, stringsAsFactors= F)
  
    # gwasResults <- subset( gwasResults, select = -c( 36  : 39 )) #sofia deleting tau0, beacuse is always NA
  #gwasResults[is.na(gwasResults)] <- 0 #sofia
  gwasResults <- gwasResults[complete.cases(gwasResults), ] # drop NAs (can happen when maf=1) 
  # filtering for AF, done in colaus cohort
  #gwasResults <- gwasResults[gwasResults$af>0.05,]
  
  # # ht
  # ht <- subset(gwasResults, select = c("chr","rsid","pos","ht.log10p"))
  # gwasResults_allChr__ht <- rbind(gwasResults_allChr__ht,ht)
  # # ht_INT
  # ht_INT <- subset(gwasResults, select = c("chr","rsid","pos","ht_INT.log10p"))
  # gwasResults_allChr__ht_INT <- rbind(gwasResults_allChr__ht_INT,ht_INT)
  
  # DF
  DF <- subset(gwasResults, select = c("chr","rsid","pos","DF.log10p"))
  gwasResults_allChr__DF <- rbind(gwasResults_allChr__DF,DF)

  # # DF1st
  # DF1st <- subset(gwasResults, select = c("chr","rsid","pos","DF1st.log10p"))
  # gwasResults_allChr__DF1st <- rbind(gwasResults_allChr__DF1st,DF1st)
  # 
  # # DF2nd
  # DF2nd <- subset(gwasResults, select = c("chr","rsid","pos","DF2nd.log10p"))
  # gwasResults_allChr__DF2nd <- rbind(gwasResults_allChr__DF2nd,DF2nd)
  # 
  # # DF3rd
  # DF3rd <- subset(gwasResults, select = c("chr","rsid","pos","DF3rd.log10p"))
  # gwasResults_allChr__DF3rd <- rbind(gwasResults_allChr__DF3rd,DF3rd)
  # 
  # # DF4th
  # DF4th <- subset(gwasResults, select = c("chr","rsid","pos","DF4th.log10p"))
  # gwasResults_allChr__DF4th <- rbind(gwasResults_allChr__DF4th,DF4th)
  # # 
  # DF5th
  DF5th <- subset(gwasResults, select = c("chr","rsid","pos","DF5th.log10p"))
  gwasResults_allChr__DF5th <- rbind(gwasResults_allChr__DF5th,DF5th)

  # # tau1
  # tau1 <- subset(gwasResults, select = c("chr","rsid","pos","tau1.log10p"))
  # gwasResults_allChr__tau1 <- rbind(gwasResults_allChr__tau1,tau1)
  # 
  # # tau2
  # tau2 <- subset(gwasResults, select = c("chr","rsid","pos","tau2.log10p"))
  # gwasResults_allChr__tau2 <- rbind(gwasResults_allChr__tau2,tau2)
  # 
  # # tau3
  # tau3 <- subset(gwasResults, select = c("chr","rsid","pos","tau3.log10p"))
  # gwasResults_allChr__tau3 <- rbind(gwasResults_allChr__tau3,tau3)
  # 
  # # tau4
  # tau4 <- subset(gwasResults, select = c("chr","rsid","pos","tau4.log10p"))
  # gwasResults_allChr__tau4 <- rbind(gwasResults_allChr__tau4,tau4)
  # 
  # # tau5
  # tau5 <- subset(gwasResults, select = c("chr","rsid","pos","tau5.log10p"))
  # gwasResults_allChr__tau5 <- rbind(gwasResults_allChr__tau5,tau5)
  # 
  # # tau6
  # tau6 <- subset(gwasResults, select = c("chr","rsid","pos","tau6.log10p"))
  # gwasResults_allChr__tau6 <- rbind(gwasResults_allChr__tau6,tau6)
  # 
  # # tau6
  # tau6 <- subset(gwasResults, select = c("chr","rsid","pos","tau6.log10p"))
  # gwasResults_allChr__tau6 <- rbind(gwasResults_allChr__tau6,tau6)
  # 
  # # tau7
  # tau7 <- subset(gwasResults, select = c("chr","rsid","pos","tau7.log10p"))
  # gwasResults_allChr__tau7 <- rbind(gwasResults_allChr__tau7,tau7)
  # 
  # # nVessels
  # nVessels <- subset(gwasResults, select = c("chr","rsid","pos","nVessels.log10p"))
  # gwasResults_allChr__nVessels <- rbind(gwasResults_allChr__nVessels,nVessels)

  # DF5th
  # DF5th <- subset(gwasResults, select = c("chr","rsid","pos","DF5th.log10p"))
  # gwasResults_allChr__DF5th <- rbind(gwasResults_allChr__DF5th,DF5th)

  # DF_control
  # DF <- subset(gwasResults, select = c("chr","rsid","pos","DF.log10p"))
  # gwasResults_allChr__DF <- rbind(gwasResults_allChr__DF,DF)
  
  # DF1_DF2
  # DF1_DF2 <- subset(gwasResults, select = c("chr","rsid","pos","DF1_DF2.log10p"))
  # gwasResults_allChr__DF1_DF2 <- rbind(gwasResults_allChr__DF1_DF2,DF1_DF2)

  # DF1_DF5
  # DF1_DF5 <- subset(gwasResults, select = c("chr","rsid","pos","DF1_DF5.log10p"))
  # gwasResults_allChr__DF1_DF5 <- rbind(gwasResults_allChr__DF1_DF5,DF1_DF5)
}

# Plot_QQ_Manhattan("ht", gwasResults_allChr__ht)
# Plot_QQ_Manhattan("ht_INT", gwasResults_allChr__ht_INT)
Plot_QQ_Manhattan("DF", gwasResults_allChr__DF)
# Plot_QQ_Manhattan("DF1st", gwasResults_allChr__DF1st)
# Plot_QQ_Manhattan("DF2nd", gwasResults_allChr__DF2nd)
# Plot_QQ_Manhattan("DF3rd", gwasResults_allChr__DF3rd)
# Plot_QQ_Manhattan("DF4th", gwasResults_allChr__DF4th)
Plot_QQ_Manhattan("DF5th", gwasResults_allChr__DF5th)
# Plot_QQ_Manhattan("tau1", gwasResults_allChr__tau1)
# Plot_QQ_Manhattan("tau2", gwasResults_allChr__tau2)
# Plot_QQ_Manhattan("tau3", gwasResults_allChr__tau3)
# Plot_QQ_Manhattan("tau4", gwasResults_allChr__tau4)
# Plot_QQ_Manhattan("tau5", gwasResults_allChr__tau5)
# Plot_QQ_Manhattan("tau6", gwasResults_allChr__tau6)
# Plot_QQ_Manhattan("tau7", gwasResults_allChr__tau7)
# Plot_QQ_Manhattan("nVessels", gwasResults_allChr__nVessels)

# Plot_QQ_Manhattan("DF5th", na.omit(gwasResults_allChr__DF5th))
# Plot_QQ_Manhattan("DF5th", gwasResults_allChr__DF5th)
# Plot_QQ_Manhattan("DF", gwasResults_allChr__DF)
# Plot_QQ_Manhattan("DF1_DF2", gwasResults_allChr__DF1_DF2)
# Plot_QQ_Manhattan("DF1_DF5", gwasResults_allChr__DF1_DF5)
# Plot_QQ_Manhattan("tau4", gwasResults_allChr__tau4_tortuosity)
# Plot_QQ_Manhattan("tau5", gwasResults_allChr__tau5_tortuosity)
# Plot_QQ_Manhattan("tau6", gwasResults_allChr__tau6_tortuosity)
# Plot_QQ_Manhattan("tau7", gwasResults_allChr__tau7_tortuosity)

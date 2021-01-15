#install.packages("qqman")
#install.packages("BiocManager")
#BiocManager::install("GWASTools")
library(qqman)
library(GWASTools)
setwd("/Users/sortinve/Desktop/2020_12")

# INSTRUCTIONS
# - take chromosome files outputted by BGENIE, ungzip them (run "gzip -d *")
# - place resulting txt files in the same folder as this script
# - (if some chromosomes are missing, initialize for loop accordingly)
# OUTPUT
# - for each phenotype: genomewide qqplot and manhattan plot

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

# aggregate GWAS results from each chromo
###gwasResults_allChr__median_diameter <- data.frame()
###gwasResults_allChr__D9_diameter <- data.frame()
###gwasResults_allChr__short_tortuosity <- data.frame()
###gwasResults_allChr__D9_tortuosity <- data.frame()
###gwasResults_allChr__D95_tortuosity <- data.frame()
gwasResults_allChr__median_tortuosity <- data.frame()
gwasResults_allChr__tau2_tortuosity <- data.frame()
gwasResults_allChr__tau3_tortuosity <- data.frame()
gwasResults_allChr__tau4_tortuosity <- data.frame()
gwasResults_allChr__tau5_tortuosity <- data.frame()
gwasResults_allChr__tau6_tortuosity <- data.frame()
gwasResults_allChr__tau7_tortuosity <- data.frame()
gwasResults_allChr__tau1_tortuosity <- data.frame() #sofia to check is the same that median 

for (i in c(1:22)){ # change for loop range in case some chromosomes are misssing
  write(paste0("processing chromo",i), stdout())
  
  # read input
  gwasResults <- read.table(paste("output_ukb_imp_chr", i,"_v3.txt", sep=""), sep=" ",header=T, stringsAsFactors= F)
  gwasResults <- subset( gwasResults, select = -c( 60  : 63 )) #sofia deleting tau0, beacuse is always NA
  #gwasResults[is.na(gwasResults)] <- 0 #sofia
  gwasResults <- gwasResults[complete.cases(gwasResults), ] # drop NAs (can happen when maf=1) 

  # median_diameter
  ###median_diameter <- subset(gwasResults, select = c("chr","rsid","pos","median_diameter.log10p"))
  ###gwasResults_allChr__median_diameter <- rbind(gwasResults_allChr__median_diameter,median_diameter)

  # D9_diameter
  ###D9_diameter <- subset(gwasResults, select = c("chr","rsid","pos","D9_diameter.log10p"))
  ###gwasResults_allChr__D9_diameter <- rbind(gwasResults_allChr__D9_diameter,D9_diameter)

   # short_tortuosity
  ###short_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","short_tortuosity.log10p"))
  ###gwasResults_allChr__short_tortuosity <- rbind(gwasResults_allChr__short_tortuosity,short_tortuosity)

  # D9_tortuosity
  ###D9_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","D9_tortuosity.log10p"))
  ###gwasResults_allChr__D9_tortuosity <- rbind(gwasResults_allChr__D9_tortuosity,D9_tortuosity)

  # D95_tortuosity
  ###D95_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","D95_tortuosity.log10p"))
  ###gwasResults_allChr__D95_tortuosity <- rbind(gwasResults_allChr__D95_tortuosity,D95_tortuosity)

  # median_tortuosity
  median_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","median_tortuosity.log10p"))
  gwasResults_allChr__median_tortuosity <- rbind(gwasResults_allChr__median_tortuosity,median_tortuosity)
  
  # tau2_tortuosity
  tau2_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","tau2.log10p"))
  gwasResults_allChr__tau2_tortuosity <- rbind(gwasResults_allChr__tau2_tortuosity,tau2_tortuosity)
  
  # tau3_tortuosity
  tau3_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","tau3.log10p"))
  gwasResults_allChr__tau3_tortuosity <- rbind(gwasResults_allChr__tau3_tortuosity,tau3_tortuosity)
  
  # tau4_tortuosity
  tau4_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","tau4.log10p"))
  gwasResults_allChr__tau4_tortuosity <- rbind(gwasResults_allChr__tau4_tortuosity,tau4_tortuosity)

  # tau5_tortuosity
  tau5_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","tau5.log10p"))
  gwasResults_allChr__tau5_tortuosity <- rbind(gwasResults_allChr__tau5_tortuosity,tau5_tortuosity)
  
  # tau6_tortuosity
  tau6_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","tau6.log10p"))
  gwasResults_allChr__tau6_tortuosity <- rbind(gwasResults_allChr__tau6_tortuosity,tau6_tortuosity)
  
  # tau7_tortuosity
  tau7_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","tau7.log10p"))
  gwasResults_allChr__tau7_tortuosity <- rbind(gwasResults_allChr__tau7_tortuosity,tau7_tortuosity)
  
  # tau1_tortuosity
  tau1_tortuosity <- subset(gwasResults, select = c("chr","rsid","pos","tau1.log10p"))
  gwasResults_allChr__tau1_tortuosity <- rbind(gwasResults_allChr__tau1_tortuosity,tau1_tortuosity)
  
}

# GENOME-WIDE plot: median_diameter
###jpeg(file="median_diameter_QQPLOT", width=2000,height=1000)
###plotPvals("median_diameter",gwasResults_allChr__median_diameter,TRUE,FALSE)
###dev.off()
###jpeg(file="median_diameter_MANHATTAN", width=2000,height=1000)
###plotPvals("median_diameter",gwasResults_allChr__median_diameter,FALSE,TRUE)
###dev.off()

# GENOME-WIDE plot: D9_diameter
###jpeg(file="D9_diameter_QQPLOT", width=2000,height=1000)
###plotPvals("D9_diameter",gwasResults_allChr__D9_diameter,TRUE,FALSE)
###dev.off()
###jpeg(file="D9_diameter_MANHATTAN", width=2000,height=1000)
###plotPvals("D9_diameter",gwasResults_allChr__D9_diameter,FALSE,TRUE)
###dev.off()

# GENOME-WIDE plot: short_tortuosity
###jpeg(file="short_tortuosity_QQPLOT", width=2000,height=1000)
###plotPvals("short_tortuosity",gwasResults_allChr__short_tortuosity,TRUE,FALSE)
###dev.off()
###jpeg(file="short_tortuosity_MANHATTAN", width=2000,height=1000)
###plotPvals("short_tortuosity",gwasResults_allChr__short_tortuosity,FALSE,TRUE)
###dev.off()

# GENOME-WIDE plot: D9_tortuosity
###jpeg(file="D9_tortuosity_QQPLOT", width=2000,height=1000)
###plotPvals("D9_tortuosity",gwasResults_allChr__D9_tortuosity,TRUE,FALSE)
###dev.off()
###jpeg(file="D9_tortuosity_MANHATTAN", width=2000,height=1000)
###plotPvals("D9_tortuosity",gwasResults_allChr__D9_tortuosity,FALSE,TRUE)
###dev.off()

# GENOME-WIDE plot: D95_tortuosity
###jpeg(file="D95_tortuosity_QQPLOT", width=2000,height=1000)
###plotPvals("D95_tortuosity",gwasResults_allChr__D95_tortuosity,TRUE,FALSE)
###dev.off()
###jpeg(file="D95_tortuosity_MANHATTAN", width=2000,height=1000)
###plotPvals("D95_tortuosity",gwasResults_allChr__D95_tortuosity,FALSE,TRUE)
###dev.off()

# GENOME-WIDE plot: median_tortuosity
jpeg(file="median_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("median_tortuosity",gwasResults_allChr__median_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="median_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("median_tortuosity",gwasResults_allChr__median_tortuosity,FALSE,TRUE)
dev.off()

# GENOME-WIDE plot: tau2_tortuosity
jpeg(file="tau2_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("tau2_tortuosity",gwasResults_allChr__tau2_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="tau2_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("tau2_tortuosity",gwasResults_allChr__tau2_tortuosity,FALSE,TRUE)
dev.off()

# GENOME-WIDE plot: tau3_tortuosity
jpeg(file="tau3_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("tau3_tortuosity",gwasResults_allChr__tau3_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="tau3_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("tau3_tortuosity",gwasResults_allChr__tau3_tortuosity,FALSE,TRUE)
dev.off()

# GENOME-WIDE plot: tau4_tortuosity
jpeg(file="tau4_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("tau4_tortuosity",gwasResults_allChr__tau4_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="tau4_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("tau4_tortuosity",gwasResults_allChr__tau4_tortuosity,FALSE,TRUE)
dev.off()

# GENOME-WIDE plot: tau5_tortuosity
jpeg(file="tau5_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("tau5_tortuosity",gwasResults_allChr__tau5_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="tau5_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("tau5_tortuosity",gwasResults_allChr__tau5_tortuosity,FALSE,TRUE)
dev.off()


# GENOME-WIDE plot: tau6_tortuosity
jpeg(file="tau6_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("tau6_tortuosity",gwasResults_allChr__tau6_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="tau6_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("tau6_tortuosity",gwasResults_allChr__tau6_tortuosity,FALSE,TRUE)
dev.off()

# GENOME-WIDE plot: tau7_tortuosity
jpeg(file="tau7_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("tau7_tortuosity",gwasResults_allChr__tau7_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="tau7_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("tau7_tortuosity",gwasResults_allChr__tau7_tortuosity,FALSE,TRUE)
dev.off()


# GENOME-WIDE plot: tau1_tortuosity
jpeg(file="tau1_tortuosity_QQPLOT", width=2000,height=1000)
plotPvals("tau1_tortuosity",gwasResults_allChr__tau1_tortuosity,TRUE,FALSE)
dev.off()
jpeg(file="tau1_tortuosity_MANHATTAN", width=2000,height=1000)
plotPvals("tau1_tortuosity",gwasResults_allChr__tau1_tortuosity,FALSE,TRUE)
dev.off()

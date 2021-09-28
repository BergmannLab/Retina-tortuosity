#install.packages("qqman")
#install.packages("BiocManager")
#BiocManager::install("GWASTools")
#library(qqman)
#library(GWASTools)

args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

phenos=read.table("phenotypes.txt")
phenos=as.character(as.vector(phenos[1,]))
print(phenos)

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
# defining empty data frames for all the phenotypes
tmp <- data.frame()
df_names = c()
for (i in phenos){
  name=paste("gwasResults_allChr__",i,sep="")
  df_names=append(df_names,name)
  assign(name,tmp)
}
# old way:
#gwasResults_allChr__DF <- data.frame()
# gwasResults_allChr__DF1st <- data.frame()
# gwasResults_allChr__DF2nd <- data.frame()
# gwasResults_allChr__DF3rd <- data.frame()
# gwasResults_allChr__DF4th <- data.frame()
# gwasResults_allChr__DF5th <- data.frame()

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
  
  # DF
  for (j in seq_along(phenos)){
    df <- subset(gwasResults, select = c("chr","rsid","pos",paste(phenos[j],".log10p",sep="")))
    assign(df_names[j],rbind(get(df_names[j]),df))
  }
}

for (j in seq_along(phenos)){
  Plot_QQ_Manhattan(phenos[j], get(df_names[j]))
}
# old way, just hardcode for all phenotypes:
#Plot_QQ_Manhattan("DF", gwasResults_allChr__DF)
#Plot_QQ_Manhattan("DF1st", gwasResults_allChr__DF1st)
#Plot_QQ_Manhattan("DF2nd", gwasResults_allChr__DF2nd)
#Plot_QQ_Manhattan("DF3rd", gwasResults_allChr__DF3rd)
#Plot_QQ_Manhattan("DF4th", gwasResults_allChr__DF4th)
#Plot_QQ_Manhattan("DF5th", gwasResults_allChr__DF5th)

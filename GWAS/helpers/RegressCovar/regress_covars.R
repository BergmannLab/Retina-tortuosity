#args = commandArgs(trailingOnly=TRUE)
setwd("/Users/mtomason/Documents/projects/retina/data_UKBiobank/03_gwas/regress_covars/")

# INSTRUCTIONS 
# - this is  the final script to regress out covariates for the tortuosity GWAS. DO NOT CHANGE
#   - it is tortuosity-specific (vars that correlate with tortuosity were hand picked)
# OUTPUT
# - phenofile_resid_qqnorm.csv
#   file containing residuals of regressing covars on all TORTUOSITY

cov <- "./base_covar.csv"
pheno <- "./phenofile.csv"

# read from file
pheno_matrix <- read.csv(pheno, header=TRUE, sep=" ",check.names=FALSE)
pheno_matrix <- pheno_matrix[c("median_diameter","D9_diameter","median_tortuosity","short_tortuosity","D9_tortuosity","D95_tortuosity")]
# read from file
cov_matrix <- read.csv(cov, header=TRUE, sep=" ",check.names=FALSE)
#cov_matrix <- cov_matrix[c(1:4, 7:10, 18:20)] # only KEEP COVARS that CORRELATE with tortuosity: "age","sex","PC1","PC2","PC5","PC6","PC7","PC8","PC16","PC17","PC18"
# merge
merged <- data.frame(c(cov_matrix, pheno_matrix),check.names=FALSE)
merged[merged=="-999"] <- NA
merged_qqnorm <- data.frame(merged) # deep copy of df: to hold qqnorm equvalent

colnames(merged)[1:42] <- c("age","sex","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","PC11","PC12","PC13","PC14","PC15","PC16","PC17","PC18","PC19","PC20","PC21","PC22","PC23","PC24","PC25","PC26","PC27","PC28","PC29","PC30","PC31","PC32","PC33","PC34","PC35","PC36","PC37","PC38","PC39","PC40")

for(i in 43:48){ # loop over 6 phenos
  pheno_name <- colnames(merged)[i]
  
  # VISUALIZE CONTRIBUTION OF EACH COVAR
  for(j in 1:42){   # for each covar
    covar_name <- colnames(merged)[j]
    pheno <-merged[i]; 
    covar <-merged[j];
    
    # put into fuction the rest
    # invokje twice for age and ageˆ2
    plotCorr_Pheno_Covar <- function(pheno, covar){
      formula <- paste0(pheno_name,"~",covar_name)
      # calculate correlation pheno/covar
      fit <- lm(formula,data=c(pheno,covar), na.action=na.exclude)
      R2 <- summary(fit)$r.squared; R2 <- formatC(R2, format = "e", digits = 2);
      pval <- summary(fit)$coefficients[2,4]; pval <- formatC(pval, format = "e", digits = 2);
      beta <- summary(fit)$coefficients[2,1]; beta <- formatC(beta, format = "e", digits = 2);
      jpeg(filename=paste(pheno_name,"~",covar_name,".jpg",sep=""));
      scatter.smooth(covar[[1]],pheno[[1]], xlab=covar_name, ylab=pheno_name,
                     main=paste0(formula,"\n R2: ",R2,", P: ",pval,", beta: ",beta));
      dev.off()
    }
    
    plotCorr_Pheno_Covar(pheno, covar)
    # for certain covars, try non linear effects
    if (covar_name == "age"){
      covar2 <- '^'(covar,2)
      covar_name <- paste0(covar_name,"2")
      names(covar2) <- covar_name
      plotCorr_Pheno_Covar(pheno, covar2)
    }
  }

  # REGRESS OUT out all covars to get resid
  formula <-paste0(pheno_name,"~age+sex+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20+PC21+PC22+PC23+PC24+PC25+PC26+PC27+PC28+PC29+PC30+PC31+PC32+PC33+PC34+PC35+PC36+PC37+PC38+PC39+PC40")
  res_i <- residuals(lm(formula,data=merged, na.action=na.exclude))

  # PLOT hist res before qq norm
  jpeg(filename=paste(pheno_name,"->all_covars_RESIDUALS.jpg",sep="")); hist(res_i); dev.off()
  # replace pheno with residuals
  merged[i] <- res_i
  # qqnorm residuals
  qq_res_i <- qnorm((rank(res_i,na.last="keep")-0.5)/sum(!is.na(res_i)))
  # replace pheno with qqnorm residuals
  merged_qqnorm[i] <- qq_res_i
  # PLOT hist res before qq norm
  jpeg(filename=paste(pheno_name,"->all_covars_RESIDUALS_qqnorm.jpg",sep="")); hist(qq_res_i); dev.off()
}



#put back -999
merged[is.na(merged)]<-"-999" 
merged_qqnorm[is.na(merged_qqnorm)]<-"-999"
# split
pheno_matrix <- merged[c("median_diameter","D9_diameter","median_tortuosity","short_tortuosity","D9_tortuosity","D95_tortuosity")]
pheno_matrix_qqnorm <- merged_qqnorm[c("median_diameter","D9_diameter","median_tortuosity","short_tortuosity","D9_tortuosity","D95_tortuosity")]
# output
write.table(pheno_matrix_qqnorm,file="./phenofile_resid_qqnorm.csv",row.names=FALSE,sep=" ",quote =FALSE)

# I always qq norm residuals, optionally output non-normalized ones to debug
### write.table(pheno_matrix,file="./phenofile_resid.csv",row.names=FALSE,sep=" ",quote =FALSE)

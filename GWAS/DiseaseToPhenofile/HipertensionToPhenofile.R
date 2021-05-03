setwd("/Users/sortinve/Desktop/Data_UKB/")
# Hypertension
###########################################################################################
# 4079-0.0 DBP
# 4080-0.0 SBP
###########################################################################################
input <- read.table("ukb34181.csv", sep=",",header=T, stringsAsFactors= F)

# select top hits from chromo
input <- subset(input, select = c("eid", "X4079.0.0","X4080.0.0"))
input[,"Class"] <- NA # add a column for hypertension status

# loop over DBP and SBP to determine hypertension status
BP <- data.frame(c(input["X4079.0.0"],input["X4080.0.0"]))
for (i in 1:nrow(input)) {
  DBP_i <- BP[i, 1]; SBP_i <- BP[i, 2]
  if(is.na(DBP_i) | is.na(SBP_i)) { # skip is BP is not defined
    next; 
  }
  if(DBP_i<80 & SBP_i<120) { # control
    input[i,"Class"] <- 0
  }
  if(DBP_i>90 | SBP_i>140) { # stage 2 hypertension
    input[i,"Class"] <- 1 
  }
  # all other subjects, remain NA:
  # - subjectst with "only" elevated blood pressure and light (stage 1) hypertension
}

df_ukb_chr1 <- read.table("ukb43805_imp_chr1_v3_s487297.sample", sep=" ",header=T, stringsAsFactors= F)
names(df_ukb_chr1)[1] <- "eid"
df_hypertension = merge(df_ukb_chr1, input, by="eid")
df_hypertension[1] <- NULL  
df_hypertension[1] <- NULL  
df_hypertension[1] <- NULL  
df_hypertension[1] <- NULL  
df_hypertension[1] <- NULL  
df_hypertension[1] <- NULL  
df_hypertension[is.na(df_hypertension)] <- -999
write.table(df_hypertension, file = "phenotype_hipertension.csv", sep = " ", row.names = FALSE,quote=FALSE)

library(stringr)
library(dplyr)
library(tidyr)

### Initialization:
ukbb_files_dir <- '/NVME/decrypted/ukbb/labels/'
phenofiles_dir <- '/NVME/decrypted/ukbb/fundus/phenotypes'
output_dir <- '/SSD/home/sofia/retina/tratis_association_with_diseases/'

list_diseases<- c('SBP', 'DBP', 'hypertension','age_diabetes', 'age_angina', 'age_heartattack', 'age_DVT', 'age_stroke', 'myopia')


list_diseases_logit <- c('hypertension','age_diabetes', 'age_angina', 'age_heartattack', 'age_DVT', 'age_stroke', 'myopia')
### Read disease data:
# source("~/retina/tratis_association_with_diseases/auxiliar_survival_MLR.R") # Modify location
# data_aux = read_disease_data(ukbb_files_dir)
data_all <- read.csv(file= paste(survival_data_dir, "/Diseases_file_LR.csv", sep=""), header = TRUE, sep=",",check.names=FALSE)

### Read phenofile data and create data set:
# data_all = create_dataset(data_aux, phenofiles_dir)
# colnames(data_all)
# data_all["age2"]= data_all["age"]^2

# write.csv(data_all,"/SSD/home/sofia/retina/tratis_association_with_diseases/Diseases_file_LR.csv", row.names = FALSE)
### MLR: 

variables <- c("DF_all", "DF_artery", "DF_vein", "medianDiameter_all", "medianDiameter_artery", "medianDiameter_vein",
               "N_green", "N_bif", "tVA", "tAA", "pixels_close_OD_over_total", "green_pixels_over_total_OD", "N_total_green_segments",
               "FD_all", "FD_artery", "FD_vein", "VD_orig_all", "VD_orig_artery", "VD_orig_vein", "VD_200px_all", "VD_200px_artery", "VD_200px_vein",
               "age", "age2","sex", "cov1", "cov2", "cov3", "cov4","cov5", "cov6","cov7", "cov8","cov9")


jpeg(file= paste(output_dir, "/hist_SBP.jpeg", sep="") )
hist(data_all$SBP)
dev.off()

jpeg(file= paste(output_dir, "/hist_DBP.jpeg", sep="") )
hist(data_all$DBP)
dev.off()


for (i in list_diseases){
  outcome <- as.name(i)
  f <- as.formula(paste(outcome, paste(variables, collapse = " + "), sep = " ~ "))
  print(i)
  model <- eval(bquote(   lm(.(f), data = data_all)   ))
  
  # MLR <- lm(SBP ~ DF_all+ DF_artery + DF_vein+ medianDiameter_artery + 
  #                 medianDiameter_vein + medianDiameter_all + 
  #                 age+sex+cov1+cov2+cov3+cov4+cov5+cov6+cov7+cov8+cov9, data=data_all)
  
  sink(file= paste(output_dir, "/MLR_",i,".txt", sep=""))
  print(summary(model))
  sink()
  
  # Other useful functions
  #coefficients(model) # model coefficients
  #confint(model, level=0.95) # CIs for model parameters
  #fitted(model) # predicted values
  #residuals(model) # residuals
  #anova(model) # anova table
  #vcov(model) # covariance matrix for model parameters
  #influence(model) # regression diagnostics
  
  pdf(file= paste(output_dir, "/MLR_",i,".pdf", sep=""),         # File name
       width = 8, height = 7, # Width and height in inches
       bg = "white",          # Background color
       colormodel = "cmyk",    # Color model (cmyk is required for most publications)
       paper = "A4")          # Paper size
  #diagnostic plots
  #layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
  #plot(model)
  #dev.off() 
}


###Modify:
#replaces the negative numbers with zeros
data_all['age_diabetes'][data_all['age_diabetes'] >=1] <- 1
data_all['age_angina'][data_all['age_angina'] >=1] <- 1
data_all['age_heartattack'][data_all['age_heartattack'] >=1] <- 1
data_all['age_DVT'][data_all['age_DVT'] >=1] <- 1
data_all['age_stroke'][data_all['age_stroke'] >=1] <- 1
data_all['myopia'][data_all['myopia'] >=1] <- 1
data_all['myopia'][data_all['myopia'] =='1'] <- 1

##Missing values are controls
data_all["age_diabetes"][is.na(data_all["age_diabetes"])] <- 0
data_all["age_angina"][is.na(data_all["age_angina"])] <- 0
data_all["age_heartattack"][is.na(data_all["age_heartattack"])] <- 0
data_all["age_DVT"][is.na(data_all["age_DVT"])] <- 0
data_all["age_stroke"][is.na(data_all["age_stroke"])] <- 0
data_all["myopia"][is.na(data_all["myopia"])] <- 0

## -1 do not know, -3 Prefer not to answer
data_all['age_diabetes'][data_all['age_diabetes'] ==-1] <- NaN
data_all['age_angina'][data_all['age_angina'] ==-1] <- NaN
data_all['age_heartattack'][data_all['age_heartattack'] ==-1] <- NaN
data_all['age_heartattack'][data_all['age_heartattack'] ==-3] <- NaN
data_all['age_DVT'][data_all['age_DVT'] ==-1] <- NaN
data_all['age_stroke'][data_all['age_stroke'] ==-1] <- NaN
data_all['myopia'][data_all['myopia'] ==-1] <- NaN


data_all['hypertension']<- NaN
data_all['hypertension'][(data_all['DBP'] <80) & (data_all['SBP'] <120)] <- 0
data_all['hypertension'][(data_all['DBP'] >90) & (data_all['SBP'] >140)] <- 1

jpeg(file= paste(output_dir, "/hist_hypertension.jpeg", sep="") )
hist(data_all$hypertension)
dev.off()

jpeg(file= paste(output_dir, "/hist_age_diabetes.jpeg", sep="") )
hist(data_all$age_diabetes)
dev.off()

jpeg(file= paste(output_dir, "/hist_age_angina.jpeg", sep="") )
hist(data_all$age_angina)
dev.off()

jpeg(file= paste(output_dir, "/hist_age_heartattack.jpeg", sep="") )
hist(data_all$age_heartattack)
dev.off()

jpeg(file= paste(output_dir, "/hist_age_DVT.jpeg", sep="") )
hist(data_all$age_DVT)
dev.off()

jpeg(file= paste(output_dir, "/hist_age_stroke.jpeg", sep="") )
hist(data_all$age_stroke)
dev.off()

jpeg(file= paste(output_dir, "/hist_myopia.jpeg", sep="") )
hist(data_all$myopia)
dev.off()

for (i in list_diseases_logit){
  outcome <- as.name(i)
  f <- as.formula(paste(outcome, paste(variables, collapse = " + "), sep = " ~ "))
  
  print(i)
  
  model <- eval(bquote(   glm(.(f), family=binomial(link='logit'), data = data_all)   ))
  
  # MLR <- lm(SBP ~ DF_all+ DF_artery + DF_vein+ medianDiameter_artery + 
  #                 medianDiameter_vein + medianDiameter_all + 
  #                 age+sex+cov1+cov2+cov3+cov4+cov5+cov6+cov7+cov8+cov9, data=data_all)
  
  sink(file= paste(output_dir, "/MLogR_",i,".txt", sep=""))
  print(summary(model))
  sink()
  
  # Other useful functions
  #coefficients(model) # model coefficients
  #confint(model, level=0.95) # CIs for model parameters
  #fitted(model) # predicted values
  #residuals(model) # residuals
  #anova(model) # anova table
  #vcov(model) # covariance matrix for model parameters
  #influence(model) # regression diagnostics
  
  # pdf(file= paste(output_dir, "/MLR_",i,".pdf", sep=""),         # File name
  #     width = 8, height = 7, # Width and height in inches
  #     bg = "white",          # Background color
  #     colormodel = "cmyk",    # Color model (cmyk is required for most publications)
  #     paper = "A4")          # Paper size
  # diagnostic plots
  # layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
  # plot(model)
  # dev.off() 
}


############## Complementary
# # compare models
# fit1 <- lm(y ~ x1 + x2 + x3 + x4, data=mydata)
# fit2 <- lm(y ~ x1 + x2)
# anova(fit1, fit2)
# 
# 
# 
# # Stepwise Regression
# library(MASS)
# fit <- lm(y~x1+x2+x3,data=mydata)
# step <- stepAIC(fit, direction="both")
# step$anova # display results
# 
# 
# # All Subsets Regression
# library(leaps)
# attach(mydata)
# leaps<-regsubsets(y~x1+x2+x3+x4,data=mydata,nbest=10)
# # view results
# summary(leaps)
# # plot a table of models showing variables in each model.
# # models are ordered by the selection statistic.
# plot(leaps,scale="r2")
# # plot statistic by subset size
# library(car)
# subsets(leaps, statistic="rsq")
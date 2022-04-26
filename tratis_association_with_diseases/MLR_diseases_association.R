library(stringr)
library(dplyr)

### Initialization:
ukbb_files_dir <- '/Users/sortinve/Desktop'
phenofiles_dir <- '/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/Auxiliar'
output_dir <- '/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/Auxiliar/Output'

list_diseases<- c('SBP', 'DBP', 'age_diabetes', 'age_angina', 'age_heartattack', 'age_DVT', 'age_stroke', 'myopia')


### Read disease data:
source("/Users/sortinve/develop/retina/tratis_association_with_diseases/auxiliar_survival_MLR.R") # Modify location
data_aux = read_disease_data(ukbb_files_dir)

### Read phenofile data and create data set:
data_all = create_dataset(data_aux, phenofiles_dir)
colnames(data_all)

### MLR: 

variables <- c("DF_all", "DF_artery", "DF_vein", "medianDiameter_all", "medianDiameter_artery", "medianDiameter_vein",
               "N_green", "N_bif", "tVA", "tAA", "pixels_close_OD_over_total", "green_pixels_over_total_OD", "N_total_green_segments",
               "FD_all", "FD_artery", "FD_vein", "VD_orig_all", "VD_orig_artery", "VD_orig_vein", "VD_200px_all", "VD_200px_artery", "VD_200px_vein",
               "age", "sex", "cov1", "cov2", "cov3", "cov4","cov5", "cov6","cov7", "cov8","cov9")

for (i in list_diseases){
  outcome <- as.name(i)
  f <- as.formula(paste(outcome, paste(variables, collapse = " + "), sep = " ~ "))
  
  model <- eval(bquote(   lm(.(f), data = data_all)   ))
  
  # MLR <- lm(SBP ~ DF_all+ DF_artery + DF_vein+ medianDiameter_artery + 
  #                 medianDiameter_vein + medianDiameter_all + 
  #                 age+sex+cov1+cov2+cov3+cov4+cov5+cov6+cov7+cov8+cov9, data=data_all)
  
  sink(file= paste(output_dir, "/MLR_",i,".txt", sep=""))
  print(summary(model))
  sink()
  
  # Other useful functions
  coefficients(model) # model coefficients
  confint(model, level=0.95) # CIs for model parameters
  fitted(model) # predicted values
  residuals(model) # residuals
  anova(model) # anova table
  vcov(model) # covariance matrix for model parameters
  influence(model) # regression diagnostics
  
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
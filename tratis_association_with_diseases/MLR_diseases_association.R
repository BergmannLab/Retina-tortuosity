################### RELEVANT FILES: #####################################
#######  DATA 1:
#	2976-0.0, 2976-1.0, 2976-2.0		Integer	Age diabetes diagnosed
# 3627-0.0, 3627-1.0, 3627-2.0 		Integer	Age angina diagnosed
# 3894-0.0, 3894-1.0, 3894-2.0		Integer	Age heart attack diagnosed
# 4012-0.0, 4012-1.0, 4012-2.0	  Integer	Age deep-vein thrombosis (DVT, blood clot in leg) diagnosed
# 4056-0.0, 4056-1.0, 4056-2.0		Integer	Age stroke diagnosed
# 4079-0.0, 4079-0.1, 4079-1.0, 4079-1.1, 4079-2.0, 4079-2.1	Integer	Diastolic blood pressure, automated reading
# 4080-0.0, 4080-0.1, 4080-1.0,	4080-1.1, 4080-2.0, 4080-2.1 Integer	Systolic blood pressure, automated reading
# 40000-0.0, 40000-1.0	Date	Date of death


###### DATA 6:
# 30750 Glycated haemoglobin (HbA1c)
# 40006 Type of cancer: ICD10
# 40012 Behaviour of cancer tumour
# 40013 Type of cancer: ICD9
# 40021 Cancer record origin
# 40000 Date of death
# 40001 Underlying (primary) cause of death: ICD10
# 40002 Contributory (secondary) causes of death: ICD10
# 40007 Age at death
# 40010 Description of cause of death
# 5325 Ever had refractive laser eye surgery
# 5326 Ever had surgery for glaucoma or high eye pressure
# 5327 Ever had laser treatment for glaucoma or high eye pressure
# 131380 Date I70 first reported (atherosclerosis)
# 131390 Date I77 first reported (other disorders of arteries and arterioles)
# 2207 Wears glasses or contact lenses
# 2217 Age started wearing glasses or contact lenses
# 2227 Other eye problems
# 4689 Age glaucoma diagnosed
# 4700 Age cataract diagnosed
# 5408 Which eye(s) affected by amblyopia (lazy eye)
# 5419 Which eye(s) affected by injury or trauma resulting in loss of vision
# 5430 Age when loss of vision due to injury or trauma diagnosed
# 5441 Which eye(s) are affected by cataract
# 5610 Which eye(s) affected by presbyopia
# 5832 Which eye(s) affected by hypermetropia (long sight)
# 5843 Which eye(s) affected by myopia (short sight)
# 5855 Which eye(s) affected by astigmatism
# 5877 Which eye(s) affected by other eye condition
# 5890 Which eye(s) affected by diabetes-related eye disease
# 5901 Age when diabetes-related eye disease diagnosed
# 5912 Which eye(s) affected by macular degeneration
# 5923 Age macular degeneration diagnosed
# 5934 Which eye(s) affected by other serious eye condition
# 5945 Age other serious eye condition diagnosed
# 6119 Which eye(s) affected by glaucoma
# 6147 Reason for glasses/contact lenses
# 6148 Eye problems/disorders
# 6205 Which eye(s) affected by strabismus (squint)

# 84 Cancer year/age first occurred
# 2443 Diabetes diagnosed by doctor
# 2453 Cancer diagnosed by doctor
# 2966 Age high blood pressure diagnosed
# 2976 Age diabetes diagnosed
# 3005 Fracture resulting from simple fall
# 3627 Age angina diagnosed
# 3894 Age heart attack diagnosed
# 3992 Age emphysema/chronic bronchitis diagnosed
# 4012 Age deep-vein thrombosis (DVT, blood clot in leg) diagnosed
# 4022 Age pulmonary embolism (blood clot in lung) diagnosed
# 4056 Age stroke diagnosed
# 6150 Vascular/heart problems diagnosed by doctor
# 6151 Fractured bone site(s)
# 6152 Blood clot, DVT, bronchitis, emphysema, asthma, rhinitis, eczema, allergy diagnosed by doctor
# 1717 Skin colour
# 1747 Hair colour (natural, before greying)

###### DATA 8:
# 20262-0.0		Categorical (single)	Myopia diagnosis

### GWAS covar:
# 21022-0.0 31-0.0 22009-0.1 22009-0.2 22009-0.5 22009-0.6 22009-0.7 22009-0.8 22009-0.16 22009-0.17 22009-0.18

###############################################################################

library(stringr)
library(dplyr)

### Initialization:
ukbb_files_dir <- '...'
phenofiles_dir <- '...'
output_dir <- '...'

list_diseases<- c('SBP', 'DBP', 'age_diabetes', 'age_angina', 'age_heartattack', 'age_DVT',
                  'age_stroke', 'myopia')

# setwd("/.../")

### Read Ukbb files:
data_1 <- read.csv(file= paste(ukbb_files_dir, "/ukb34181.csv", sep=""),
                   header = TRUE, sep=",",check.names=FALSE)

gwas_covar <- data_1

gwas_covar <- gwas_covar[, c('21022-0.0', '31-0.0', '22009-0.1', '22009-0.2', '22009-0.5', '22009-0.6', 
                         '22009-0.7', '22009-0.8', '22009-0.16', '22009-0.17', '22009-0.18', 'eid')]
names(gwas_covar) <- c('age', 'sex', 'cov1', 'cov2', 'cov3', 'cov4', 'cov5', 'cov6', 'cov7', 'cov8', 'cov9', 'eid')

data_1 <- data_1[, c('2976-0.0', '3627-0.0', '3894-0.0', '4012-0.0', '4056-0.0', '4079-0.0', '4080-0.0', '40000-0.0', 'eid')]
names(data_1) <- c('age_diabetes', 'age_angina', 'age_heartattack', 'age_DVT', 'age_stroke', 'DBP', 'SBP', 'date_death',  'eid')


# data_2 <- read.csv("/.../2_data_extraction_BMI_height_IMT/ukb42432.csv",
#                    header = TRUE, sep=",",check.names=FALSE)

# data_3 <- read.csv("/../3_data_extraction_tinnitus/ukb42625.csv",
#                    header = TRUE, sep=",",check.names=FALSE)


data_6 <- read.csv(file= paste(ukbb_files_dir, "/ukb49907.csv", sep=""),
                   header = TRUE, sep=",",check.names=FALSE)

data_6 <- data_6[, c('30750-0.0', '40006-0.0', '40013-0.0', '40007-0.0', 
                     '4689-0.0', '4700-0.0', '5408-0.0', '5610-0.0', '5832-0.0', 
                     '5843-0.0', '5855-0.0', '5890-0.0', '5945-0.0', '2443-0.0', 
                     '3005-0.0', '6150-0.0', '6152-0.0', '1717-0.0', '1747-0.0', 'eid')]

names(data_6) <- c('HbA1c', 'type_cancer', 'type_cancer_2', 'age_death', 
                   'age_glaucoma', 'age_cataract', 'eye_amblyopia', 'eye_presbyopia', 'eye_hypermetropia',
                   'eye_myopia', 'eye_astigmatism', 'eye_diabetes', 'age_other_serious_eye_condition', 'diabetes',
                   'fractura', 'vascular_heart_problems', 'variate', 'skin_colour',  'hair_colour', 'eid')


# data_7 <- read.csv("/.../7_data_extraction/ukb50488.csv",
#                    header = TRUE, sep=",",check.names=FALSE)

data_8 <- read.csv(file= paste(ukbb_files_dir, "/ukb51076.csv", sep=""),
                   header = TRUE, sep=",",check.names=FALSE)

data_8 <- data_8[, c('20262-0.0', 'eid')]

names(data_8)  <- c('myopia', 'eid')


### Read phenofiles : 
pheno_ARIA <- read.csv(file= paste(phenofiles_dir, "/2021-12-28_ARIA_phenotypes.csv", sep=""),
                       header = TRUE, sep=",",check.names=FALSE)
pheno_N_green <- read.csv(file= paste(phenofiles_dir, "/2022-02-01_N_green_pixels.csv", sep=""),
                       header = TRUE, sep=",",check.names=FALSE)
pheno_N_bif <- read.csv(file= paste(phenofiles_dir, "/2022-02-04_bifurcations.csv", sep=""),
                          header = TRUE, sep=",",check.names=FALSE)
pheno_tVA <- read.csv(file= paste(phenofiles_dir, "/2022-02-13_tVA_phenotypes.csv", sep=""),
                        header = TRUE, sep=",",check.names=FALSE)
pheno_tAA <- read.csv(file= paste(phenofiles_dir, "/2022-02-14_tAA_phenotypes.csv", sep=""),
                      header = TRUE, sep=",",check.names=FALSE)
pheno_NeoOD <- read.csv(file= paste(phenofiles_dir, "/2022-02-17_NeovasOD_phenotypes.csv", sep=""),
                      header = TRUE, sep=",",check.names=FALSE)
pheno_greenOD <- read.csv(file= paste(phenofiles_dir, "/2022-02-21_green_pixels_over_total_OD_phenotypes.csv", sep=""),
                      header = TRUE, sep=",",check.names=FALSE)
pheno_N_green_seg <- read.csv(file= paste(phenofiles_dir, "/2022-02-21_N_green_segments_phenotypes.csv", sep=""),
                          header = TRUE, sep=",",check.names=FALSE)

# From images names to eids
#colnames(pheno_ARIA)
names(pheno_ARIA)[1] <- 'eid'
names(pheno_N_green)[1] <- 'eid'
names(pheno_N_bif)[1] <- 'eid'
names(pheno_tVA)[1] <- 'eid'
names(pheno_tAA)[1] <- 'eid'
names(pheno_NeoOD)[1] <- 'eid'
names(pheno_greenOD)[1] <- 'eid'
names(pheno_N_green_seg)[1] <- 'eid'

pheno_ARIA[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_ARIA$eid, '_', 4)
pheno_N_green[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_N_green$eid, '_', 4)
pheno_N_bif[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_N_bif$eid, '_', 4)
pheno_tVA[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_tVA$eid, '_', 4)
pheno_tAA[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_tAA$eid, '_', 4)
pheno_NeoOD[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_NeoOD$eid, '_', 4)
pheno_greenOD[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_greenOD$eid, '_', 4)
pheno_N_green_seg[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_N_green_seg$eid, '_', 4)

# Only select 21015
pheno_ARIA <- pheno_ARIA %>% group_by(image) %>% filter(image == 21015)
pheno_N_green <- pheno_N_green %>% group_by(image) %>% filter(image == 21015)
pheno_N_bif <- pheno_N_bif %>% group_by(image) %>% filter(image == 21015)
pheno_tVA <- pheno_tVA %>% group_by(image) %>% filter(image == 21015)
pheno_tAA <- pheno_tAA %>% group_by(image) %>% filter(image == 21015)
pheno_NeoOD <- pheno_NeoOD %>% group_by(image) %>% filter(image == 21015)
pheno_greenOD <- pheno_greenOD %>% group_by(image) %>% filter(image == 21015)
pheno_N_green_seg <- pheno_N_green_seg %>% group_by(image) %>% filter(image == 21015)

### Merge all:
data_all = merge(gwas_covar, data_1, by = "eid") 
data_all = merge(data_all, data_6, by = "eid") 
data_all = merge(data_all, data_8, by = "eid") 

data_all = merge(data_all, pheno_ARIA, by = "eid") 
data_all = merge(data_all, pheno_N_green, by = "eid") 
data_all = merge(data_all, pheno_N_bif, by = "eid") 
data_all = merge(data_all, pheno_tVA, by = "eid") 
data_all = merge(data_all, pheno_tAA, by = "eid") 
data_all = merge(data_all, pheno_NeoOD, by = "eid") 
data_all = merge(data_all, pheno_greenOD, by = "eid") 
data_all = merge(data_all, pheno_N_green_seg, by = "eid") 

colnames(data_all)

### MLR: 
for (i in list_diseases){
  
  outcome <- as.name(i)
  variables <- c("DF_all", "DF_artery", "DF_vein", "medianDiameter_all", "medianDiameter_artery", "medianDiameter_vein",
  "N_green", "N_bif", "tVA", "tAA", "pixels_close_OD_over_total", "green_pixels_over_total_OD", "N_total_green_segments",
  "age", "sex", "cov1", "cov2", "cov3", "cov4","cov5", "cov6","cov7", "cov8","cov9")
  
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
  layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
  plot(model)
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
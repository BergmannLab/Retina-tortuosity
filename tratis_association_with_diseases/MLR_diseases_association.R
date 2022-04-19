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

# setwd("/.../")
data_1 <- read.csv("/.../1_data_extraction/ukb34181.csv",
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

data_6 <- read.csv("/.../6_data_extraction/ukb49907.csv",
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

data_8 <- read.csv("/.../8_data_extraction/ukb51076.csv",
                   header = TRUE, sep=",",check.names=FALSE)

data_8 <- data_8[, c('20262-0.0', 'eid')]

names(data_8)  <- c('myopia', 'eid')


# Read phenofiles:
pheno_ARIA <- read.csv("/.../2021-12-28_ARIA_phenotypes.csv",
                   header = TRUE, sep=",",check.names=FALSE)
names(pheno_ARIA) <- c('image')
colnames(pheno_ARIA)

# TO DO: convert "image" into "eid" 
# strsplit(as.character(pheno_ARIA$image),'_2101')
# pheno_ARIA <- pheno_ARIA %>% separate(image, c('eid', 'other'))

data_all = merge(gwas_covar, data_1, by = "eid") 
data_all = merge(data_all, data_6, by = "eid") 
data_all = merge(data_all, data_8, by = "eid") 
# TO DO: data_all = merge(data_all, pheno_ARIA, by = "eid") 

# colnames(data_all)

# Multiple Linear Regression Example - SBP: 4080-0.0 and diameter artery
MLR_SBP <- lm(SBP ~ age+sex+cov1+cov2+cov3+cov4+cov5+cov6+cov7+cov8+cov9, data=data_all)
summary(MLR_SBP)

# MLR_SBP_diameter_artery <- lm(SBP ~ medianDiameter_artery + age+sex+cov1+cov2+cov3+cov4+cov5+cov6+cov7+cov8+cov9, data=data_all)
# summary(MLR_SBP_diameter_artery)

# Other useful functions
coefficients(fit) # model coefficients
confint(fit, level=0.95) # CIs for model parameters
fitted(fit) # predicted values
residuals(fit) # residuals
anova(fit) # anova table
vcov(fit) # covariance matrix for model parameters
influence(fit) # regression diagnostics


# diagnostic plots
layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
plot(fit)


############## TO DO: MODIFY!
# compare models
fit1 <- lm(y ~ x1 + x2 + x3 + x4, data=mydata)
fit2 <- lm(y ~ x1 + x2)
anova(fit1, fit2)



# Stepwise Regression
library(MASS)
fit <- lm(y~x1+x2+x3,data=mydata)
step <- stepAIC(fit, direction="both")
step$anova # display results


# All Subsets Regression
library(leaps)
attach(mydata)
leaps<-regsubsets(y~x1+x2+x3+x4,data=mydata,nbest=10)
# view results
summary(leaps)
# plot a table of models showing variables in each model.
# models are ordered by the selection statistic.
plot(leaps,scale="r2")
# plot statistic by subset size
library(car)
subsets(leaps, statistic="rsq")
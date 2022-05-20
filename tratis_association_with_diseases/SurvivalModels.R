library(survival) # this is the cornerstone command for survival analysis in R
library(ggplot2) # newer package that does nice plots # or `library(tidyverse)`
library(tidyr)
library(dplyr)
library(survminer)
#require("survival")
# install.packages(c("survival", "survminer", "ggplot"))

### Set up directories:
survival_data_dir <- '/SSD/home/sofia/retina/tratis_association_with_diseases/' # Modify dir
phenofiles_dir <- '/NVME/decrypted/ukbb/fundus/phenotypes'
survival_output_dir <- '/SSD/home/sofia/retina/tratis_association_with_diseases/' # Modify dir

###################### OLD VERSION #################################
### Read survival data:
#source("/SSD/home/sofia/retina/tratis_association_with_diseases/auxiliar_survival_MLR.R") # Modify dir
#data_aux = read_survival_data(survival_data_dir)

### Read phenofile data and create data set:
#g = create_dataset(data_aux, phenofiles_dir)
####################################################################

g <- read.csv(file= paste(survival_data_dir, "/pruebas_survival.csv", sep=""), header = TRUE, sep=",",check.names=FALSE)

### Define variables:
sex <- as.factor(g[,"sex"]) # R calls categorical variables factors
year_death <- g[,"year_death"] # continuous variable (numeric) 
death <- g[,"death"] # binary variable (numeric) 
age <- g[,"age_at_recruitment"] # continuous variable (numeric) 
g["age_at_recruitment2"]= g["age_at_recruitment"]^2
age_at_recruitment2 <- g[,"age_at_recruitment2"] # continuous variable (numeric) 
age_65plus <- ifelse(g[,'age_at_recruitment']>=65, 1, 0) # separate age in two classes
etnia <- factor(g[,"etnia"]) 

###################### OLD VERSION #################################
#g$cov1 <- as.numeric(as.factor(g$cov1))
### Assumption: We can not analyze Covs as Real (Z neither) => Separate in quartile
#g$quart_cov1 <- ntile(g$cov1, 2) 
#g$quart_cov2 <- ntile(g$cov2, 2) 
#g$quart_cov3 <- ntile(g$cov3, 2) 
#g$quart_cov4 <- ntile(g$cov4, 2) 
#g$quart_cov5 <- ntile(g$cov5, 2) 
#g$quart_cov6 <- ntile(g$cov6, 2) 
#g$quart_cov7 <- ntile(g$cov7, 4) 
#g$quart_cov8 <- ntile(g$cov8, 4) 
#g$quart_cov9 <- ntile(g$cov9, 4) 
# Other covariants: Should be group or quartile???
#quart_cov1 <- g[,"quart_cov1"]
#quart_cov2 <- g[,"quart_cov2"]
#quart_cov3 <- g[,"quart_cov3"]
#quart_cov4 <- g[,"quart_cov4"]
#quart_cov5 <- g[,"quart_cov5"]
#quart_cov6 <- g[,"quart_cov6"]
#quart_cov7 <- g[,"quart_cov7"]
#quart_cov8 <- g[,"quart_cov8"]
#quart_cov9 <- g[,"quart_cov9"]
########################################################### 

# Phenotypes:
DF_all <- g[,"DF_all"]
DF_artery <- g[,"DF_artery"]
DF_vein <- g[,"DF_vein"]
medianDiameter_all <- g[,"medianDiameter_all"]
medianDiameter_artery <- g[,"medianDiameter_artery"]
medianDiameter_vein <- g[,"medianDiameter_vein"]
N_green <- g[,"N_green"]
N_bif <- g[,"N_bif"]
tVA <- g[,"tVA"]
tAA <- g[,"tAA"]
pixels_close_OD_over_total <- g[,"pixels_close_OD_over_total"]
green_pixels_over_total_OD <- g[,"green_pixels_over_total_OD"]
N_total_green_segments <- g[,"N_total_green_segments"]
FD_all <- g[,"FD_all"]
FD_artery <- g[,"FD_artery"]
FD_vein <- g[,"FD_vein"]
VD_orig_all <- g[,"VD_orig_all"]
VD_orig_artery <- g[,"VD_orig_artery"] 
VD_orig_vein <- g[,"VD_orig_vein"]
VD_200px_all <- g[,"VD_200px_all"]
VD_200px_artery <- g[,"VD_200px_artery"]
VD_200px_vein <- g[,"VD_200px_vein"]

VD_orig_all_binary <-  ifelse(g[,'VD_orig_all']>=0.07, 1, 0) # separate in two classes 
FD_all_binary <- ifelse(g[,'FD_all']>=1.4, 1, 0) # separate age in two classes 1.4 more or less arbitrary 
FD_all_binary <- as.factor(g[,"FD_all_binary"])
############################# GENERAL CASE: MULTIPLE VARIABLES ################
#fit_cox1 <- survfit( Surv(year_death, death) ~ FD_all_binary + age_at_recruitment + age_at_recruitment2 + sex + etnia, data =  g)
#summary(fit_cox1)

### Plot survival curves by sex and facet by rx and adhere: This will plot all:
#ggsurv <- ggsurvplot(fit_cox1, fun = "event", conf.int = TRUE, ggtheme = theme_bw(), title="Surv FD, age, sex", legend = "left", font.legend = c(8, "plain"))
#ggsurv$plot 
#pdf(file= paste(survival_output_dir, "/ggsurv_FD_age65_sex_cov1.pdf", sep=""))
#print(ggsurv, newpage = FALSE)
#dev.off()

### Selecting plotting:
fit_cox2 <- coxph(Surv(year_death, death) ~ FD_all_binary + age_at_recruitment + age_at_recruitment2 + sex + etnia, data =  g) 
ggadjustedcurves(fit_cox2, data = g, method = "average", variable = "sex")
curve <- surv_adjustedcurves(fit_cox2, data = g, method = "average", variable = "sex")

#plot(curve$surv)
#  method = "marginal", method = "conditional"
#ggadjustedcurves(fit2, data = g)
#curve <- surv_adjustedcurves(fit2, data = g)
############### Other plots:
# or to ggsurvplot:  ggsurvplot(survfit(fit_cox2), data = g, palette = "#2E9FDF")
# ggsurvplot(survfit(fit_cox2), data = g,
#            conf.int = TRUE,
#            risk.table.col = "strata", # Change risk table color by groups
#            ggtheme = theme_bw(), # Change ggplot2 theme
#            palette = c("#E7B800", "#2E9FDF"),
#            fun = "event")

# ---- Apply the test to the model 
temp <- cox.zph(fit_cox2)    
# ---- Plot the curves 
plot(temp) 


# Generate diagnostic plots 

# 2. Plotting the estimated changes in the regression coefficients on deleting each patient 
ggcoxdiagnostics(fit_cox2, type = "dfbeta", 
                 linear.predictions = FALSE, ggtheme = theme_bw())

# 3. Plotting deviance residuals 
ggcoxdiagnostics(fit_cox2, type = "deviance", 
                 linear.predictions = FALSE, ggtheme = theme_bw())

# 4. Plotting Martingale residuals 
fit <- coxph(Surv(year_death, death) ~ age_65plus + log(age_65plus) + sqrt(age_65plus)) 
ggcoxfunctional(fit, data = g) # note we must specify original dataframe 




############################# SIMPLEST CASE: ONLY ONE VARIABLE ################
############################# COMPUTE SURVIVAL CURVES: sex
fit <- survfit(Surv(year_death, death) ~ sex, data = g)
print(fit)
summary(fit)
summary(fit)$table

###############  Visualize survival curves (KM plots) ###############

##### 1° plot:
ggsurvplot(fit, ggtheme = theme_minimal()) ##### Very simple KM plot
##ggsave(file = "ggsurv.jpg", print(survp))
##### 2° plot:
ggsurvplot(fit,
           pval = TRUE, conf.int = TRUE,
           risk.table = TRUE, # Add risk table
           risk.table.col = "strata", # Change risk table color by groups
           linetype = "strata", # Change line type by groups
           #surv.median.line = "hv", # Specify median survival
           ggtheme = theme_bw(), # Change ggplot2 theme
           palette = c("#eeb277", "#2E9FDF")) ##### More complete KM plot
##### 3° plot:
# ggsurvplot(fit,
#            conf.int = TRUE,
#            risk.table.col = "strata", # Change risk table color by groups
#            ggtheme = theme_bw(), # Change ggplot2 theme
#            palette = c("#E7B800", "#2E9FDF"),
#            xlim = c(0, 600))


###############  Plot cumulative events  ###############

ggsurvplot(fit,
           conf.int = TRUE,
           risk.table.col = "strata", # Change risk table color by groups
           ggtheme = theme_bw(), # Change ggplot2 theme
           palette = c("#E7B800", "#2E9FDF"),
           fun = "event")


###############  Plot cumulative hazard  ###############

ggsurvplot(fit,
           conf.int = TRUE,
           risk.table.col = "strata", # Change risk table color by groups
           ggtheme = theme_bw(), # Change ggplot2 theme
           palette = c("#E7B800", "#2E9FDF"),
           fun = "cumhaz")


###############  Log-Rank test comparing survival curves  ###############

surv_diff <- survdiff(Surv(year_death, death) ~ sex, data = g)
print(surv_diff)
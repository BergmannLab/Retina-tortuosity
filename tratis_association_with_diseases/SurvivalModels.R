library(survival) # this is the cornerstone command for survival analysis in R
library(ggplot2) # newer package that does nice plots
library("survminer")
require("survival")
# install.packages(c("survival", "survminer", "ggplot"))


### Set up directories:

survival_data_dir <- '/Users/sortinve/Desktop'
phenofiles_dir <- '/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/Auxiliar'

### Read survival data:
source("/Users/sortinve/develop/retina/tratis_association_with_diseases/auxiliar_survival_MLR.R") # Modify dir
data_aux = read_survival_data(survival_data_dir)

### Read phenofile data and create data set:
g = create_dataset(data_aux, phenofiles_dir)


### Define variables:
sex <- as.factor(g[,"sex"]) # R calls categorical variables factors
year_death <- g[,"year_death"] # continuous variable (numeric) 
death <- g[,"death"] # binary variable (numeric) 
age <- g[,"age"] # continuous variable (numeric) 
age_65plus <- ifelse(g[,'age']>=65, 1, 0) # separate age in two classes

# Other covariants:
cov1 <- g[,"cov1"]
cov2 <- g[,"cov2"]
cov3 <- g[,"cov3"]
cov4 <- g[,"cov4"]
cov5 <- g[,"cov5"]
cov6 <- g[,"cov6"]
cov7 <- g[,"cov7"]
cov8 <- g[,"cov8"]
cov9 <- g[,"cov9"]

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


############################# GENERAL CASE: MULTIPLE VARIABLES ################
fit2 <- survfit( Surv(year_death, death) ~ age_65plus + sex, data =  g)
summary(fit2)

# Plot survival curves by sex and facet by rx and adhere
ggsurv <- ggsurvplot(fit2, fun = "event", conf.int = TRUE, ggtheme = theme_bw())
ggsurv$plot 

# or to ggsurvplot:  ggsurvplot(survfit(res.cox), data = g, palette = "#2E9FDF")
# 1. Define model 
res.cox <- coxph(Surv(year_death, death) ~ age_65plus + sex) 

# ggsurvplot(survfit(res.cox), data = g,
#            conf.int = TRUE,
#            risk.table.col = "strata", # Change risk table color by groups
#            ggtheme = theme_bw(), # Change ggplot2 theme
#            palette = c("#E7B800", "#2E9FDF"),
#            fun = "event")

# ---- Apply the test to the model 
temp <- cox.zph(res.cox)    
# ---- Plot the curves 
plot(temp) 

# Generate diagnostic plots 

# 2. Plotting the estimated changes in the regression coefficients on deleting each patient 
ggcoxdiagnostics(res.cox, type = "dfbeta", 
                 linear.predictions = FALSE, ggtheme = theme_bw())

# 3. Plotting deviance residuals 
ggcoxdiagnostics(res.cox, type = "deviance", 
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
setwd("/Users/sortinve/Desktop/")

g <- read.csv("/Users/sortinve/Desktop/pruebas_survival.csv", header = TRUE, sep=",",check.names=FALSE)

# list_datafields = ['eid', '31-0.0', '34-0.0', '40000-0.0', '40000-1.0']
# 31 - sex, 34 - year of birth, 40000- death
# install.packages(c("survival", "survminer", "ggplot"))

library(survival) # this is the cornerstone command for survival analysis in R
library(ggplot2) # newer package that does nice plots
library("survminer")
require("survival")
#dev.off() 
#plot(rnorm(50), rnorm(50))

# Define variables 
gender <- as.factor(g[,"gender"]) # R calls categorical variables factors
year <- g[,"year"] # continuous variable (numeric) 
death <- g[,"death"] # binary variable (numeric) 
age <- g[,"age"] # continuous variable (numeric) 
age_65plus <- ifelse(g[,'age']>=65, 1, 0) 

############################# SIMPLEST CASE: ONLY ONE VARIABLE ################
############################# COMPUTE SURVIVAL CURVES: GENDER
fit <- survfit(Surv(year, death) ~ gender, data = g)
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

surv_diff <- survdiff(Surv(year, death) ~ gender, data = g)
print(surv_diff)






############################# GENERAL CASE: MULTIPLE VARIABLES ################
fit2 <- survfit( Surv(year, death) ~ age_65plus + gender, data =  g)
summary(fit2)


# Plot survival curves by sex and facet by rx and adhere
ggsurv <- ggsurvplot(fit2, fun = "event", conf.int = TRUE,
                     ggtheme = theme_bw())

ggsurv$plot 


# or to ggsurvplot:  ggsurvplot(survfit(res.cox), data = g, palette = "#2E9FDF")
# 1. Define model 
res.cox <- coxph(Surv(year, death) ~ age_65plus + gender) 

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


# 1. Define model 
res.cox <- coxph(Surv(year, death) ~ age_65plus) 

# Generate diagnostic plots 

# 2. Plotting the estimated changes in the regression coefficients on deleting each patient 
ggcoxdiagnostics(res.cox, type = "dfbeta", 
                 linear.predictions = FALSE, ggtheme = theme_bw())

# 3. Plotting deviance residuals 
ggcoxdiagnostics(res.cox, type = "deviance", 
                 linear.predictions = FALSE, ggtheme = theme_bw())

# 4. Plotting Martingale residuals 
fit <- coxph(Surv(year, death) ~ age_65plus + log(age_65plus) + sqrt(age_65plus)) 
ggcoxfunctional(fit, data = g) # note we must specify original dataframe 


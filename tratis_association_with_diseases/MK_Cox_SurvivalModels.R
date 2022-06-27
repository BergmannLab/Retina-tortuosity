setwd("/Users/sortinve/Desktop/General_PhD/Administrativo_cursos/ETCS/coursera/cox model/")

g <- read.csv("/Users/sortinve/Desktop/General_PhD/Administrativo_cursos/ETCS/coursera/cox\ model/6AiBbg-BEem6Gg6vVM6M8A_e872b4600f8111e9b2f4133a1edfbb40_simulated-HF-mort-data-for-GMPH-_1K_-final-_2_.csv",
              header = TRUE, sep=",",check.names=FALSE)
#df_data_init <- read.csv("/.../ukb34181.csv", header = TRUE, sep=",",check.names=FALSE)

# install.packages(c("survival", "survminer", "ggplot"))
library(survival) # this is the cornerstone command for survival analysis in R
library(ggplot2) # newer package that does nice plots
library("survminer")
require("survival")


#####  KM Plot and log-rank test
simple_survival_curve_KM <-function(g)
{
  gender <- as.factor(g[,"gender"]) # R calls categorical variables factors
  fu_time <- g[,"fu_time"] # continuous variable (numeric) 
  death <- g[,"death"] # binary variable (numeric) 

  fit <- survfit(Surv(fu_time, death) ~ gender, data = g)
  suvp <- ggsurvplot(fit,
                     pval = TRUE, conf.int = TRUE,
                     risk.table = TRUE, # Add risk table
                     risk.table.col = "strata", # Change risk table color by groups
                     linetype = "strata", # Change line type by groups
                     surv.median.line = "hv", # Specify median survival
                     ggtheme = theme_bw(), # Change ggplot2 theme
                     palette = c("#eeb277", "#2E9FDF"))
  print(suvp, newpage = FALSE)
  
  #Log-Rank test comparing survival curves: survdiff()
  surv_diff <- survdiff(Surv(fu_time, death) ~ gender, data = g)
  surv_diff
  
  res.sum <- surv_summary(fit)
  head(res.sum)
  attr(res.sum, "table")
}


#####  Complex KM Plot 
complex_survival_curves_KM <- function(g)
{
  gender <- as.factor(g[,"gender"]) # R calls categorical variables factors
  fu_time <- g[,"fu_time"] # continuous variable (numeric) 
  death <- g[,"death"] # binary variable (numeric) 
  diabetes <- g[,"diabetes"] # binary variable (numeric) 
  
  fit2 <- survfit( Surv(fu_time, death) ~ gender + diabetes, data = g)
  
  # Plot survival curves by sex and facet by rx and adhere
  ggsurv <- ggsurvplot(fit2, fun = "event", conf.int = TRUE,
                       ggtheme = theme_bw())
  
  ggsurv <- ggsurv$plot +theme_bw() + 
    theme (legend.position = "right")+
    facet_grid(cancer ~ diabetes)
  
  print(ggsurv, newpage = FALSE)
}

#####  Cox Model
cox_model <- function(g)
{
  gender <- as.factor(g[,"gender"]) # R calls categorical variables factors
  fu_time <- g[,"fu_time"] # continuous variable (numeric) 
  death <- g[,"death"] # binary variable (numeric) 
  age <- g[,"age"] # continuous variable (numeric) 
  copd <- g[,"copd"] # binary variable (numeric) 
  prior_dnas <- g[,"prior_dnas"]
  ethnicgroup <- g[,"ethnicgroup"] 
  fit <- coxph(Surv(fu_time, death) ~ age + gender + copd + prior_dnas + ethnicgroup)
  summary(fit)
  
  temp <- cox.zph(fit)# apply the cox.zph function to the desired model
  print(temp) # display the results
  plot(temp) # plot the curves
  cox.zph(fit, transform="km", global=TRUE)
}


simple_survival_curve_KM(g)
complex_survival_curves_KM(g)
cox_model(g)

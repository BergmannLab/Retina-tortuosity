# Auxiliary functions:
library(tidyverse)
library(Hmisc)
#install.packages("Hmisc")

read_survival_data <- function(survival_data_dir) 
{ 
  ################# Read survival data ############################
  data_survival_cov <- read.csv(file= paste(survival_data_dir, "/pruebas_survival.csv", sep=""), 
                                header = TRUE, sep=",",check.names=FALSE)
  colnames(data_survival_cov)
  data_survival_cov <- data_survival_cov %>% 
    rename(
      'age'='21022-0.0',
      'sex'='31-0.0',
      'cov1'='22009-0.1' , 
      'cov2'='22009-0.2', 
      'cov3'='22009-0.5', 
      'cov4'='22009-0.6', 
      'cov5'='22009-0.7', 
      'cov6'='22009-0.8', 
      'cov7'='22009-0.16', 
      'cov8'='22009-0.17', 
      'cov9'='22009-0.18'
    )
  
  # plot histograms
  survival_data_dir <- '/Users/sortinve/Desktop'
  dev.new()
  pdf(file= paste(survival_output_dir, "/histogramas.pdf", sep=""))
  hist.data.frame(data_survival_cov)
  dev.off()
  # names(data_survival_cov) <- c( 'eid', '40000-0.0', '40000-1.0', 'age', 'sex', 
  #                                'cov1', 'cov2', 'cov3', 'cov4', 'cov5', 'cov6', 
  #                                'cov7', 'cov8', 'cov9', 'year_death', 'death') 
  # "eid"        "40000-0.0"  "40000-1.0"  "21022-0.0"  "31-0.0"     "22009-0.1"  "22009-0.2"  "22009-0.5" 
  # "22009-0.6"  "22009-0.7"  "22009-0.8"  "22009-0.16" "22009-0.17" "22009-0.18" "year_death"       "death"
  
  # Lo uso para comprobar que funcione lo de pintar: dev.off() 
  #plot(rnorm(50), rnorm(50))
  return(data_survival_cov)
}


read_disease_data <- function(ukbb_files_dir) 
{ 
  ### Read Ukbb files:
  data_1 <- read.csv(file= paste(ukbb_files_dir, "/ukb34181.csv", sep=""), header = TRUE, sep=",",check.names=FALSE)
  gwas_covar <- data_1
  gwas_covar <- gwas_covar[, c('21022-0.0', '31-0.0', '22009-0.1', '22009-0.2', '22009-0.5', '22009-0.6', '22009-0.7', '22009-0.8', '22009-0.16', '22009-0.17', '22009-0.18', 'eid')]
  gwas_covar <- gwas_covar %>% 
    rename(
      'age'='21022-0.0',
      'sex'='31-0.0',
      'cov1'='22009-0.1' , 
      'cov2'='22009-0.2', 
      'cov3'='22009-0.5', 
      'cov4'='22009-0.6', 
      'cov5'='22009-0.7', 
      'cov6'='22009-0.8', 
      'cov7'='22009-0.16', 
      'cov8'='22009-0.17', 
      'cov9'='22009-0.18'
    )
  # names(gwas_covar) <- c('age', 'sex', 'cov1', 'cov2', 'cov3', 'cov4', 'cov5', 'cov6', 'cov7', 'cov8', 'cov9', 'eid')
  data_1 <- data_1[, c('2976-0.0', '3627-0.0', '3894-0.0', '4012-0.0', '4056-0.0', '4079-0.0', '4080-0.0', '40000-0.0', 'eid')]
  data_1 <- data_1 %>% 
    rename(
      'age_diabetes'='2976-0.0', 
      'age_angina'='3627-0.0', 
      'age_heartattack'='3894-0.0', 
      'age_DVT'='4012-0.0', 
      'age_stroke'='4056-0.0', 
      'DBP'='4079-0.0', 
      'SBP'='4080-0.0', 
      'date_death'='40000-0.0'
    )
  # names(data_1) <- c('age_diabetes', 'age_angina', 'age_heartattack', 'age_DVT', 'age_stroke', 'DBP', 'SBP', 'date_death',  'eid')
  
  # data_2 <- read.csv("/.../2_data_extraction_BMI_height_IMT/ukb42432.csv", header = TRUE, sep=",",check.names=FALSE)
  # data_3 <- read.csv("/../3_data_extraction_tinnitus/ukb42625.csv", header = TRUE, sep=",",check.names=FALSE)
  
  # TO DO: Re rewite how to rename!
  data_6 <- read.csv(file= paste(ukbb_files_dir, "/ukb49907.csv", sep=""),header = TRUE, sep=",",check.names=FALSE)
  data_6 <- data_6[, c('30750-0.0', '40006-0.0', '40013-0.0', '40007-0.0', 
                       '4689-0.0', '4700-0.0', '5408-0.0', '5610-0.0', '5832-0.0', 
                       '5843-0.0', '5855-0.0', '5890-0.0', '5945-0.0', '2443-0.0', 
                       '3005-0.0', '6150-0.0', '6152-0.0', '1717-0.0', '1747-0.0', 'eid')]
  names(data_6) <- c('HbA1c', 'type_cancer', 'type_cancer_2', 'age_death', 
                     'age_glaucoma', 'age_cataract', 'eye_amblyopia', 'eye_presbyopia', 'eye_hypermetropia',
                     'eye_myopia', 'eye_astigmatism', 'eye_diabetes', 'age_other_serious_eye_condition', 'diabetes',
                     'fractura', 'vascular_heart_problems', 'variate', 'skin_colour',  'hair_colour', 'eid')
  
  # data_7 <- read.csv("/.../7_data_extraction/ukb50488.csv", header = TRUE, sep=",",check.names=FALSE)
  
  data_8 <- read.csv(file= paste(ukbb_files_dir, "/ukb51076.csv", sep=""),  header = TRUE, sep=",",check.names=FALSE)
  data_8 <- data_8[, c('20262-0.0', 'eid')]
  names(data_8)  <- c('myopia', 'eid')
  
  data_all = merge(gwas_covar, data_1, by = "eid") 
  data_all = merge(data_all, data_6, by = "eid") 
  data_all = merge(data_all, data_8, by = "eid") 
  
  return(data_all)
}

create_dataset <- function(data_cov, phenofiles_dir) 
  { 
  ################# Read phenofiles data ############################
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
  pheno_FD <- read.csv(file= paste(phenofiles_dir, "/2021-11-30_fractalDimension.csv", sep=""),
                       header = TRUE, sep=",",check.names=FALSE)
  pheno_VD <- read.csv(file= paste(phenofiles_dir, "/2022-04-12_vascular_density.csv", sep=""),
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
  names(pheno_FD)[1] <- 'eid'
  names(pheno_VD)[1] <- 'eid'
  
  pheno_ARIA[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_ARIA$eid, '_', 4)
  pheno_N_green[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_N_green$eid, '_', 4)
  pheno_N_bif[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_N_bif$eid, '_', 4)
  pheno_tVA[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_tVA$eid, '_', 4)
  pheno_tAA[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_tAA$eid, '_', 4)
  pheno_NeoOD[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_NeoOD$eid, '_', 4)
  pheno_greenOD[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_greenOD$eid, '_', 4)
  pheno_N_green_seg[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_N_green_seg$eid, '_', 4)
  pheno_FD[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_FD$eid, '_', 4)
  pheno_VD[c('eid', 'image', 'year', 'instance')] <- str_split_fixed(pheno_VD$eid, '_', 4)
  
  # Only select 21015
  pheno_ARIA <- pheno_ARIA %>% group_by(image) %>% filter(image == 21015)
  pheno_N_green <- pheno_N_green %>% group_by(image) %>% filter(image == 21015)
  pheno_N_bif <- pheno_N_bif %>% group_by(image) %>% filter(image == 21015)
  pheno_tVA <- pheno_tVA %>% group_by(image) %>% filter(image == 21015)
  pheno_tAA <- pheno_tAA %>% group_by(image) %>% filter(image == 21015)
  pheno_NeoOD <- pheno_NeoOD %>% group_by(image) %>% filter(image == 21015)
  pheno_greenOD <- pheno_greenOD %>% group_by(image) %>% filter(image == 21015)
  pheno_N_green_seg <- pheno_N_green_seg %>% group_by(image) %>% filter(image == 21015)
  pheno_FD <- pheno_FD %>% group_by(image) %>% filter(image == 21015)
  pheno_VD <- pheno_VD %>% group_by(image) %>% filter(image == 21015)
  
  
  ################# Read phenofiles data ############################
  g = merge(pheno_ARIA, data_cov, by = "eid") 
  g = merge(g, pheno_N_green, by = "eid") 
  g = merge(g, pheno_N_bif, by = "eid") # To do: avoid warnings!
  g = merge(g, pheno_tVA, by = "eid") 
  g = merge(g, pheno_tAA, by = "eid") 
  g = merge(g, pheno_NeoOD, by = "eid") 
  g = merge(g, pheno_greenOD, by = "eid") 
  g = merge(g, pheno_N_green_seg, by = "eid") 
  g = merge(g, pheno_FD, by = "eid") 
  g = merge(g, pheno_VD, by = "eid") 
  
  return(g)
  } 



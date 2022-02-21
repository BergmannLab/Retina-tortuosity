import pandas as pd
from datetime import datetime

# experiment id

### For measure ratios as qqnorm(ratio)
DATE = datetime.now().strftime("%Y-%m-%d")
DATE2 = datetime.now().strftime("%Y_%m_%d")

df_data = pd.read_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/"
                      "2021-12-28_ARIA_phenotypes.csv", sep=',')

df_data = df_data[['Unnamed: 0', 'medianDiameter_all', 'medianDiameter_artery', 'medianDiameter_vein',
                   'DF_all', 'DF_artery', 'DF_vein']]

df_data['ratio_AV_medianDiameter'] = df_data['medianDiameter_artery']/df_data['medianDiameter_vein']
df_data['ratio_VA_medianDiameter'] = df_data['medianDiameter_vein']/df_data['medianDiameter_artery']
df_data['ratio_AV_DF'] = df_data['DF_artery']/df_data['DF_vein']
df_data['ratio_VA_DF'] = df_data['DF_vein']/df_data['DF_artery']

df_data.to_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/" + DATE + "_ratios_ARIA_phenotypes.csv", sep=',', index= False)


### For measure ratios as qqnorm(Pheno1)/qqnorm(Pheno2)
df_data_qqnorm = pd.read_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/phenofiles/"
                      "2022_02_13_multitrait_ageCorrectedVentile5QC_qqnorm.csv", sep=' ')

df_data_qqnorm = df_data_qqnorm[[ 'medianDiameter_all', 'medianDiameter_artery', 'medianDiameter_vein',
                   'DF_all', 'DF_artery', 'DF_vein']]

df_data_qqnorm['ind_ratio_AV_medianDiameter'] = df_data_qqnorm['medianDiameter_artery']/df_data_qqnorm['medianDiameter_vein']
df_data_qqnorm['ind_ratio_VA_medianDiameter'] = df_data_qqnorm['medianDiameter_vein']/df_data_qqnorm['medianDiameter_artery']
df_data_qqnorm['ind_ratio_AV_DF'] = df_data_qqnorm['DF_artery']/df_data_qqnorm['DF_vein']
df_data_qqnorm['ind_ratio_VA_DF'] = df_data_qqnorm['DF_vein']/df_data_qqnorm['DF_artery']

df_data_qqnorm.to_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/phenofiles/" + DATE2 + "_ratios_ind_ageCorrectedVentile5QC_qqnorm.csv", sep=' ', index= False)



df_data2 = pd.read_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/phenofiles/"
                      "2022_02_13_multitrait_ageCorrectedVentile5QC.csv", sep=' ')

df_data2 = df_data2[[ 'medianDiameter_all', 'medianDiameter_artery', 'medianDiameter_vein',
                   'DF_all', 'DF_artery', 'DF_vein']]

df_data2['ind_ratio_AV_medianDiameter'] = df_data2['medianDiameter_artery']/df_data2['medianDiameter_vein']
df_data2['ind_ratio_VA_medianDiameter'] = df_data2['medianDiameter_vein']/df_data2['medianDiameter_artery']
df_data2['ind_ratio_AV_DF'] = df_data2['DF_artery']/df_data2['DF_vein']
df_data2['ind_ratio_VA_DF'] = df_data2['DF_vein']/df_data2['DF_artery']

df_data2.to_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/phenofiles/" + DATE2 + "_ratios_ind_ageCorrectedVentile5QC.csv", sep=' ', index= False)

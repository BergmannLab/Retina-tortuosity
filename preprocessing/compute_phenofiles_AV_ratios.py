import pandas as pd
from datetime import datetime

# experiment id
DATE = datetime.now().strftime("%Y_%m_%d")

df_data = pd.read_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/"
                      "2021-12-28_ARIA_phenotypes.csv", sep=',')

df_data = df_data[['Unnamed: 0', 'medianDiameter_all', 'medianDiameter_artery', 'medianDiameter_vein',
                   'DF_all', 'DF_artery', 'DF_vein']]

df_data['ratio_AV_medianDiameter'] = df_data['medianDiameter_artery']/df_data['medianDiameter_vein']
df_data['ratio_VA_medianDiameter'] = df_data['medianDiameter_vein']/df_data['medianDiameter_artery']
df_data['ratio_AV_DF'] = df_data['DF_artery']/df_data['DF_vein']
df_data['ratio_VA_DF'] = df_data['DF_vein']/df_data['DF_artery']

df_data.to_csv("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/fundus_phenotypes/" + DATE + "_ratios_ARIA_phenotypes.csv", sep=',')


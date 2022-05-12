import pandas as pd
import numpy as np
from datetime import date


def actual():
    return current_year - Fist_year

current_year = date.today().year

dir_ukb_csv_1 ='/NVME/decrypted/ukbb/labels/1_data_extraction/ukb34181.csv' 
save_file = '/SSD/home/sofia/retina/tratis_association_with_diseases/pruebas_survival.csv' 

#list_datafields_GWAS_covariants = ['eid', '40000-0.0', '40000-1.0', '21022-0.0', '31-0.0', '22009-0.1', '22009-0.2', '22009-0.5', '22009-0.6', 
#                         '22009-0.7', '22009-0.8', '22009-0.16', '22009-0.17', '22009-0.18'] # Death info and covariants

list_datafields = ['eid', '40000-0.0', '40000-1.0', '21022-0.0', '31-0.0', '21000-0.0'] # Death info, and static covariants
# 20161Pack years of smoking, 1160Sleep duration, 1200Sleeplessness / insomnia
# 20022 Birth weight

df_data = pd.read_csv(dir_ukb_csv_1, sep=',')

df_data = df_data[list_datafields]
print('Fisrt count values: ', df_data['40000-0.0'].value_counts(), ' and second values: ', df_data['40000-1.0'].value_counts())
#df_data['40000']=df_data['40000-0.0']+ df_data['40000-1.0'] # It looks like the -1.0 have nothing new!
#print('After count values: ', df_data['40000'].value_counts())
df_data = df_data.sort_values(by="40000-0.0")
df_data['year_death'] = pd.DatetimeIndex(df_data['40000-0.0']).year 
df_data['40000-0.0'] = df_data['40000-0.0'].fillna(0)
df_data['40000-1.0'] = df_data['40000-1.0'].fillna(0)
df_data['death']= np.where(df_data['40000-0.0']==0, 0, 1)
Fist_year = df_data['year_death'].min()
df_data['year_death'] = df_data['year_death'] - Fist_year  # To initializate
df_data['year_death'] = df_data['year_death'].fillna(actual()) # NaN== Survive to date => give the max value
# df_data['sex'] = df_data['31-0.0']
# df_data['age'] = 2022 - df_data['34-0.0']

df_data.to_csv(save_file, sep=',', index=False)

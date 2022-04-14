import pandas as pd
import numpy as np

dir_input = '/Users/sortinve/Desktop/ukb34181.csv'
list_datafields = ['eid', '31-0.0', '34-0.0', '40000-0.0', '40000-1.0']

df_data = pd.read_csv(dir_input, sep=',')
df_data = df_data[list_datafields]
print('Fisrt count values: ', df_data['40000-0.0'].value_counts(), ' and second values: ', df_data['40000-1.0'].value_counts())
#df_data['40000']=df_data['40000-0.0']+ df_data['40000-1.0'] Parece que los de 1.0 estan repetidos!
#print('After count values: ', df_data['40000'].value_counts())
df_data = df_data.sort_values(by="40000-0.0")
df_data['year'] = pd.DatetimeIndex(df_data['40000-0.0']).year 
df_data['40000-0.0'] = df_data['40000-0.0'].fillna(0)
df_data['40000-1.0'] = df_data['40000-1.0'].fillna(0)
df_data['death']= np.where(df_data['40000-0.0']==0, 0, 1)
df_data['year'] = df_data['year'] - 2006
df_data['year'] = df_data['year'].fillna(16)
df_data['gender'] = df_data['31-0.0']
df_data['age'] = 2022 - df_data['34-0.0']

df_data.to_csv("/Users/sortinve/Desktop/pruebas_survival.csv",
                          sep=',', index=False)
print(1)
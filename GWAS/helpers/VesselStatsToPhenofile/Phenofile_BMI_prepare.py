import pandas as pd
import numpy as np


df_BMI = pd.read_csv("/.../ukb34181.csv", sep=',')
df_BMI = df_BMI[['eid', '21001-0.0']]

df_height = pd.read_csv("/.../ukb49907.csv", sep=',')
df_height = df_height[['eid', '50-0.0']]

df_phenos = pd.merge(df_BMI, df_height, how='left', on=['eid'])
df_phenos['weight']= df_phenos['21001-0.0']*df_phenos['50-0.0']*df_phenos['50-0.0']
df_phenos['PI']= df_phenos['weight']/(df_phenos['50-0.0'])^(3)
df_phenos['BMI_half']= df_phenos['weight']/(df_phenos['50-0.0'])^(2.5)
print(df_phenos.head(15))

df_ref= df_height = pd.read_csv("/.../ukb43805_imp_chr1_v3_s487297.sample", sep=',') 
df_phenos = pd.merge(df_ref, df_phenos, how='left', on=['eid'])

df_phenos.drop('eid', axis=1, inplace=True)

df_phenos.fillna(-999, inplace=True)
print(df_phenos.head(15))
# output
df_phenos.to_csv( sep=' ', index = False)

print(1)

#extracted_phenos.columns = ['BMI', 'Height']
#extracted_phenos['Weight'] = extracted_phenos['BMI']*extracted_phenos['Height']*extracted_phenos['Height']/10000

#extracted_phenos.fillna(-999, inplace=True)
#extracted_phenos.to_csv("/Users/sortinve/Desktop/Data_UKB/phenofile.csv", sep=' ', index=False)
# Height = df_data['12144-2.0']
# Weight = NO HAY
# BMI = df_data['21001-0.0']
# Weight = Weight.fillna(-1)
# BMI = BMI.fillna(-1)

# h = math.sqrt(Weight/BMI)
# Height = Height[~np.isnan(Height)]
# Weight = Weight[~np.isnan(Weight)]
# BMI = BMI[~np.isnan(BMI)]

# BMI_proof = Weight/(Height*0.01*Height*0.01)
# Df = BMI - BMI_proof
# Df = Df[~np.isnan(Df)]
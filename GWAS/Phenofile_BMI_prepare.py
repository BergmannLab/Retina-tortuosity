import pandas as pd

df_BMI = pd.read_csv("/.../ukb42432.csv", sep=',')
df_BMI = df_BMI[['eid', '21001-0.0']]

df_height = pd.read_csv("/.../ukb49907.csv", sep=',')
df_height = df_height[['eid', '50-0.0']]

df_phenos = pd.merge(df_BMI, df_height, how='left', on=['eid'])
df_phenos['weight'] = df_phenos['21001-0.0']*df_phenos['50-0.0']*df_phenos['50-0.0']
df_phenos['PI'] = df_phenos['weight']/(df_phenos['50-0.0'])**3
df_phenos['BMI_half'] = df_phenos['weight']/(df_phenos['50-0.0'])**2.5
df_phenos['BMI'] = df_phenos['weight']/(df_phenos['50-0.0'])**2
df_phenos['weight'] = df_phenos['weight'] /10**4
print(df_phenos.head(15))

df_ref = df_height = pd.read_csv("/.../ukb43805_imp_chr1_v3_s487297.sample", sep=' ')
df_phenos = pd.merge(df_ref, df_phenos, how='left', left_on=['ID_1'], right_on=['eid'])
df_phenos = df_phenos.iloc[1:]
df_phenos.drop('eid', axis=1, inplace=True)
df_phenos.drop('ID_1', axis=1, inplace=True)
df_phenos.drop('ID_2', axis=1, inplace=True)
df_phenos.drop('missing', axis=1, inplace=True)
df_phenos.drop('sex', axis=1, inplace=True)

df_phenos.fillna(-999, inplace=True)
print(df_phenos.head(15))
# output
df_phenos.to_csv('/.../phenofile_BMI_2_half_3.csv', sep=' ', index=False)


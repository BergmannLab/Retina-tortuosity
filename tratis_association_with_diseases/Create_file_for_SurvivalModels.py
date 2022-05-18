import pandas as pd
import numpy as np
from datetime import date

### Set up directories and the list of variants:
dir_ukb_csv_1 ='/NVME/decrypted/ukbb/labels/1_data_extraction/ukb34181.csv' 
save_file = '/SSD/home/sofia/retina/tratis_association_with_diseases/pruebas_survival.csv' 
phenofiles_dir = '/NVME/decrypted/ukbb/fundus/phenotypes/'
current_year = date.today().year
list_datafields = ['eid', '40000-0.0', '40000-1.0', '21022-0.0', '31-0.0', '21000-0.0'] # Death info, and static covariants # 20161Pack years of smoking, 1160Sleep duration, 1200Sleeplessness / insomnia, 20022 Birth weight
# list_datafields_GWAS_covariants = ['eid', '40000-0.0', '40000-1.0', '21022-0.0', '31-0.0', '22009-0.1', '22009-0.2', '22009-0.5', '22009-0.6', '22009-0.7', '22009-0.8', '22009-0.16', '22009-0.17', '22009-0.18'] # Death info and covariants

def actual():
    return current_year - Fist_year


def create_dataset(df_data, phenofiles_dir):
    ## Read phenofiles data 
    pheno_ARIA = pd.read_csv(phenofiles_dir + '/2021-12-28_ARIA_phenotypes.csv')
    pheno_N_green = pd.read_csv(phenofiles_dir + '/2022-02-01_N_green_pixels.csv')
    print(pheno_N_green.head(5))
    pheno_N_bif = pd.read_csv(phenofiles_dir+ '/2022-02-04_bifurcations.csv')
    print(pheno_N_bif.head(5))
    pheno_tVA = pd.read_csv(phenofiles_dir+ '/2022-02-13_tVA_phenotypes.csv')
    pheno_tAA = pd.read_csv(phenofiles_dir + '/2022-02-14_tAA_phenotypes.csv')
    pheno_NeoOD = pd.read_csv(phenofiles_dir + '/2022-02-17_NeovasOD_phenotypes.csv')
    pheno_greenOD = pd.read_csv(phenofiles_dir + "/2022-02-21_green_pixels_over_total_OD_phenotypes.csv")
    pheno_N_green_seg = pd.read_csv(phenofiles_dir + "/2022-02-21_N_green_segments_phenotypes.csv")
    pheno_FD = pd.read_csv(phenofiles_dir + "/2021-11-30_fractalDimension.csv")
    pheno_VD = pd.read_csv(phenofiles_dir + "/2022-04-12_vascular_density.csv")

    ## Add name to the first column (N_bif and N_green are wrong)
    pheno_ARIA.rename(columns={pheno_ARIA.columns[0]: 'image'}, inplace=True)
    pheno_N_green.rename(columns={pheno_N_green.columns[0]: 'image', pheno_N_green.columns[1]: 'N_green'}, inplace=True)
    pheno_N_bif.rename(columns={pheno_N_bif.columns[0]: 'image', pheno_N_bif.columns[1]: 'N_bif'}, inplace=True)
    pheno_tVA.rename(columns={pheno_tVA.columns[0]: 'image'}, inplace=True)
    pheno_tAA.rename(columns={pheno_tAA.columns[0]: 'image'}, inplace=True)
    pheno_NeoOD.rename(columns={pheno_NeoOD.columns[0]: 'image'}, inplace=True)
    pheno_greenOD.rename(columns={pheno_greenOD.columns[0]: 'image'}, inplace=True)
    pheno_N_green_seg.rename(columns={pheno_N_green_seg.columns[0]: 'image'}, inplace=True)
    pheno_FD.rename(columns={pheno_FD.columns[0]: 'image'}, inplace=True)
    pheno_VD.rename(columns={pheno_VD.columns[0]: 'image'}, inplace=True)

    ## Merge all phenotypes:
    from functools import reduce
    data_frames = [pheno_ARIA, pheno_N_green, pheno_N_bif, pheno_tVA, pheno_tAA, pheno_NeoOD, pheno_greenOD, pheno_N_green_seg, pheno_FD, pheno_VD]
    #nan_value = np.nan
    df_pheno = reduce(lambda  left,right: pd.merge(left,right,on=['image'], how='inner'), data_frames)
    #df_pheno = pd.concat(dfs, join='outer', axis=1).fillna(nan_value)
    print(df_pheno.columns)
    df_pheno[['eid','type_image', 'year', 'instance']] = df_pheno['image'].str.split('_',expand=True)

    ## Filter by QC
    df_QC = pd.read_csv('/SSD/home/sofia/Codigos_auxiliares/ageCorrected_ventiles5.txt', sep=',', header=None)
    df_QC.rename(columns={df_QC.columns[0]: 'image'}, inplace=True)
    df_pheno = df_QC.merge(df_pheno, how='left', on='image')

    # Only select 21015
    df_pheno = df_pheno.query("type_image == '21015'") 
    df_pheno['eid'] = df_pheno['eid'].astype(int)
    print(df_pheno.columns)

    df_all = df_pheno.merge(df_data, how='left', on='eid')
    return(df_all)

df_data = pd.read_csv(dir_ukb_csv_1, sep=',')
df_data = df_data[list_datafields]

print('Fisrt count values: ', df_data['40000-0.0'].value_counts(), ' and second values: ', df_data['40000-1.0'].value_counts())
#df_data['40000']=df_data['40000-0.0']+ df_data['40000-1.0'] # It looks like the -1.0 have nothing new!

df_data = df_data.sort_values(by="40000-0.0")
df_data['year_death'] = pd.DatetimeIndex(df_data['40000-0.0']).year 
df_data['40000-0.0'] = df_data['40000-0.0'].fillna(0)
df_data['40000-1.0'] = df_data['40000-1.0'].fillna(0)
df_data['death']= np.where(df_data['40000-0.0']==0, 0, 1)
Fist_year = df_data['year_death'].min()
df_data['year_death'] = df_data['year_death'] - Fist_year  # To initializate
df_data['year_death'] = df_data['year_death'].fillna(actual()) # NaN== Survive to date => give the max value
# df_data['age'] = 2022 - df_data['34-0.0']

## rename columns
df_data.rename(columns = {'21022-0.0':'age_at_recruitment', '31-0.0':'sex', '21000-0.0':'etnia'}, inplace = True)
df_all = create_dataset(df_data, phenofiles_dir)

df_all.to_csv(save_file, sep=',', index=False)

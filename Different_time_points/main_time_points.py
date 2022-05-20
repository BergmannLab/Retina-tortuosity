import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import pickle5 as pickle
import seaborn as sns

## Analize subjects with images at different instances

def create_ukbb_dfs(dir_ukb_csv_1,list_right_eyes, list_left_eyes):
    df_data = pd.read_csv(dir_ukb_csv_1, sep=',')
    df_data_right = df_data[list_right_eyes]
    df_data_left = df_data[list_left_eyes]

    return df_data_right,df_data_left

def read_phenotypes_per_image(phenofiles_dir):
    pheno_ARIA = pd.read_csv(phenofiles_dir + '/2021-12-28_ARIA_phenotypes.csv')
    pheno_N_green = pd.read_csv(phenofiles_dir + '/2022-02-01_N_green_pixels.csv')
    pheno_N_bif = pd.read_csv(phenofiles_dir+ '/2022-02-04_bifurcations.csv')
    pheno_tVA = pd.read_csv(phenofiles_dir+ '/2022-02-13_tVA_phenotypes.csv')
    pheno_tAA = pd.read_csv(phenofiles_dir + '/2022-02-14_tAA_phenotypes.csv')
    pheno_NeoOD = pd.read_csv(phenofiles_dir + '/2022-02-17_NeovasOD_phenotypes.csv')
    pheno_greenOD = pd.read_csv(phenofiles_dir + "/2022-02-21_green_pixels_over_total_OD_phenotypes.csv")
    pheno_N_green_seg = pd.read_csv(phenofiles_dir + "/2022-02-21_N_green_segments_phenotypes.csv")
    pheno_FD = pd.read_csv(phenofiles_dir + "/2021-11-30_fractalDimension.csv")
    pheno_VD = pd.read_csv(phenofiles_dir + "/2022-04-12_vascular_density.csv")

    ## Add name to the first column and solve a misslabeling! (This should be solved!)
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

    print(pheno_NeoOD.columns, pheno_greenOD.columns, pheno_N_green_seg.columns, pheno_FD.columns, pheno_VD.columns)
    return pheno_ARIA,pheno_N_green,pheno_N_bif,pheno_tVA,pheno_tAA,pheno_NeoOD,pheno_greenOD,pheno_N_green_seg,pheno_FD,pheno_VD


def plt_RL_00_10(df_right_intersection_00, df_right_intersection_10, df_left_intersection_00, df_left_intersection_10, pheno_name):
    y1 = df_right_intersection_00[pheno_name+'_00']
    print('len(df_right_intersection_00): ', len(df_right_intersection_00))

    y2 = df_left_intersection_00[pheno_name+'_00']
    print('len(df_left_intersection_00): ', len(df_left_intersection_00))

    y3 = df_right_intersection_10[pheno_name+'_10']
    print('len(df_right_intersection_10): ', len(df_right_intersection_10))

    y4 = df_left_intersection_10[pheno_name+'_10']
    print('len(df_left_intersection_10): ', len(df_left_intersection_10))

    fig = sns.kdeplot(y1, shade=True)#, color="r")
    fig = sns.kdeplot(y2, shade=True)#, color="b")
    fig = sns.kdeplot(y3, shade=True)#, color="r")
    fig = sns.kdeplot(y4, shade=True)#, color="b")
    plt.legend(['R00', 'L00', 'R10', 'L10'])
    #plt.axes()
    #plt.title('Right eye')
    plt.show()

def plt_RL_00_menis_10(df_right_intersection_all, df_left_intersection_all, pheno_name, QC):
    y_a = df_right_intersection_all['00_menos_10']
    y_b = df_left_intersection_all['00_menos_10']

    print('len(df_right_intersection_all): ', len(df_right_intersection_all),' and len(df_left_intersection_all): ', len(df_left_intersection_all))

    fig = sns.kdeplot(y_a, shade=True)#, color="r")
    fig = sns.kdeplot(y_b, shade=True)#, color="b")
    plt.legend(['R', 'L'])
    #plt.axes()
    plt.title(pheno_name+ QC)
    plt.show()


def create_different_time_points_df(df_right_intersection_00, df_right_intersection_10, df_left_intersection_00, df_left_intersection_10, pheno_name):
    df_right_intersection_all = pd.DataFrame([])
    df_left_intersection_all = pd.DataFrame([])

    ## Merge 00 and 10
    # Right: 
    df_right_intersection_all = df_right_intersection_00.merge(df_right_intersection_10, how='inner', on='image_00', suffixes=('', '_y'))
    df_right_intersection_all.drop(df_right_intersection_all.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
    print('len(df_right_intersection_all)', len(df_right_intersection_all))

    # Left: 
    df_left_intersection_all = df_left_intersection_00.merge(df_left_intersection_10, how='inner', on='image_00', suffixes=('', '_y'))
    df_left_intersection_all.drop(df_left_intersection_all.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
    print('len(df_left_intersection_all)', len(df_left_intersection_all))

    ### Create two new columns abs(00-10) and |00-10|
    #Right 
    df_right_intersection_all['00_menos_10']=(df_right_intersection_all[pheno_name+'_00']-df_right_intersection_all[pheno_name+'_10'])
    df_right_intersection_all['00_menos_10']=(df_right_intersection_all['00_menos_10']-df_right_intersection_all['00_menos_10'].mean())/df_right_intersection_all['00_menos_10'].std()
    #df_right_intersection_all['00_menos_10'].hist(bins=20)
    print('len(df_right_intersection_all)', len(df_right_intersection_all))

    #Left 
    df_left_intersection_all['00_menos_10']=(df_left_intersection_all[pheno_name+'_00']-df_left_intersection_all[pheno_name+'_10'])
    df_left_intersection_all['00_menos_10']=(df_left_intersection_all['00_menos_10']-df_left_intersection_all['00_menos_10'].mean())/df_left_intersection_all['00_menos_10'].std()
    print('len(df_left_intersection_all)', len(df_left_intersection_all))

    return df_right_intersection_all, df_left_intersection_all

def create_different_time_points_df2(df_QC, df_right_intersection_all, df_left_intersection_all, pheno_name):
    df_right_QC = pd.DataFrame([])
    df_left_QC = pd.DataFrame([])

    ## Merge 00 and 10
    #Right:
    df_right_QC = pd.merge(df_QC, df_right_intersection_all, how='inner', left_on=['image_QC'],right_on=['image_00'], suffixes=('', '_y'))
    df_right_QC.drop(df_right_QC.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
    df_right_QC = pd.merge(df_QC, df_right_intersection_all, how='inner', left_on=['image_QC'],right_on=['image_10'], suffixes=('', '_y'))
    df_right_QC.drop(df_right_QC.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)

    df_right_QC['abs00_menos_10']=abs(df_right_QC[pheno_name+'_00']-df_right_QC[pheno_name+'_10'])
    df_right_QC['abs00_menos_10']=(df_right_QC['abs00_menos_10']-df_right_QC['abs00_menos_10'].mean())/df_right_QC['abs00_menos_10'].std()
    print('len(df_right_QC): ', len(df_right_QC))
    #df_right_QC['abs00_menos_10'].hist(bins=20)

    df_right_QC['00_menos_10']=(df_right_QC[pheno_name+'_00']-df_right_QC[pheno_name+'_10'])
    df_right_QC['00_menos_10']=(df_right_QC['00_menos_10']-df_right_QC['00_menos_10'].mean())/df_right_QC['00_menos_10'].std()
    #df_right_QC['00_menos_10'].hist(bins=20)

    #Left:
    df_left_QC = pd.merge(df_QC, df_left_intersection_all, how='inner', left_on=['image_QC'],right_on=['image_00'], suffixes=('', '_y'))
    df_left_QC.drop(df_left_QC.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
    df_left_QC = pd.merge(df_QC, df_left_intersection_all, how='inner', left_on=['image_QC'],right_on=['image_10'], suffixes=('', '_y'))
    df_left_QC.drop(df_left_QC.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)

    df_left_QC['abs00_menos_10']=abs(df_left_QC[pheno_name+'_00']-df_left_QC[pheno_name+'_10'])
    df_left_QC['abs00_menos_10']=(df_left_QC['abs00_menos_10']-df_left_QC['abs00_menos_10'].mean())/df_left_QC['abs00_menos_10'].std()
    print('len(df_left_QC): ', len(df_left_QC))
    #df_left_QC['abs00_menos_10'].hist(bins=20)

    df_left_QC['00_menos_10']=(df_left_QC[pheno_name+'_00']-df_left_QC[pheno_name+'_10'])
    df_left_QC['00_menos_10']=(df_left_QC['00_menos_10']-df_left_QC['00_menos_10'].mean())/df_left_QC['00_menos_10'].std()
    #df_left_QC['00_menos_10'].hist(bins=20)

    return df_right_QC, df_left_QC

if __name__ == '__main__':

    dir_ukb_csv_1 = '/NVME/decrypted/ukbb/labels/1_data_extraction/ukb34181.csv'
    phenofiles_dir = '/NVME/decrypted/ukbb/fundus/phenotypes'
    dir_save_results = '/SSD/home/sofia/retina/Different_time_points/results/'
    QC_dir = '/SSD/home/sofia/Codigos_auxiliares/'

    df_QC = pd.read_csv(QC_dir + '/ageCorrected_ventiles5.txt', sep=',', header=None)
    df_QC.columns = ['image_QC']
    
    # Select the files
    list_right_eyes = ['eid', '21016-0.0', '21016-1.0', '21016-0.1', '21016-1.1']
    list_left_eyes = ['eid', '21015-0.0', '21015-1.0', '21015-0.1', '21015-1.1']

    # Create dfs
    df_data_right,df_data_left = create_ukbb_dfs(dir_ukb_csv_1,list_right_eyes, list_left_eyes)

    # Replace na by 0 to avoid nans issues
    df_data_right.fillna(0, inplace=True)
    df_data_left.fillna(0, inplace=True)

    # Only select subjects with: (0.0 or 0.1) and (1.0 or 1.1) !=nan
    df_right_intersection = df_data_right[((df_data_right['21016-0.0']!=0)|(df_data_right['21016-0.1']!=0)) & 
                                        ((df_data_right['21016-1.0']!=0)|(df_data_right['21016-1.1']!=0))]
    df_left_intersection = df_data_left[((df_data_left['21015-0.0']!=0)|(df_data_left['21015-0.1']!=0)) & 
                                        ((df_data_left['21015-1.0']!=0)|(df_data_left['21015-1.1']!=0))]
    print('len df_right_intersection:',len(df_right_intersection), ', and len df_left_intersection:',len(df_left_intersection))

    # Uniformizate keys, from eid to image names
    df_right_intersection['image_00']=df_right_intersection['eid'].astype(str) + '_21016_0_0.png'
    df_right_intersection['image_01']=df_right_intersection['eid'].astype(str) + '_21016_0_1.png'
    df_right_intersection['image_10']=df_right_intersection['eid'].astype(str) + '_21016_1_0.png'
    df_right_intersection['image_11']=df_right_intersection['eid'].astype(str) + '_21016_1_1.png'

    df_left_intersection['image_00']=df_left_intersection['eid'].astype(str) + '_21015_0_0.png'
    df_left_intersection['image_01']=df_left_intersection['eid'].astype(str) + '_21015_0_1.png'
    df_left_intersection['image_10']=df_left_intersection['eid'].astype(str) + '_21015_1_0.png'
    df_left_intersection['image_11']=df_left_intersection['eid'].astype(str) + '_21015_1_1.png'

    # Read phenotypes per image  
    pheno_ARIA,pheno_N_green,pheno_N_bif,pheno_tVA,pheno_tAA,pheno_NeoOD,pheno_greenOD,pheno_N_green_seg,pheno_FD,pheno_VD = read_phenotypes_per_image(phenofiles_dir)
    
    l_pheno_of_interest = [pheno_N_bif, pheno_ARIA, pheno_ARIA, pheno_N_green, pheno_tVA, pheno_tAA, pheno_NeoOD, pheno_greenOD, pheno_N_green_seg,pheno_FD, pheno_VD] 
            # pheno_N_bif, pheno_ARIA, pheno_N_green, pheno_tVA, pheno_tAA, pheno_NeoOD, pheno_greenOD, pheno_N_green_seg, pheno_FD, pheno_VD
    l_pheno_name= ['N_bif', 'medianDiameter_all', 'DF_all', 'N_green', 'tVA', 'tAA', 'pixels_close_OD_over_total','green_pixels_over_total_OD', 'N_total_green_segments', 'FD_all', 'VD_orig_all']
            #'N_bif', 'medianDiameter_all', 'DF_all', 'N_green', 'tVA', 'tAA', 'pixels_close_OD_over_total', 'green_pixels_over_total_OD', 'N_total_green_segments', 'FD_all', 'VD_orig_all'
        ## To add: medianDiameter_artery, medianDiameter_vein, DF_artery, DF_vein
    for i in range(len(l_pheno_of_interest)):
        pheno_of_interest = l_pheno_of_interest[i]
        pheno_name = l_pheno_name[i]

        ## right eye. Only 00 and 10
        df_right_intersection_00 = df_right_intersection.merge(pheno_of_interest, how='left', left_on=['image_00'], right_on=['image'], suffixes=('', '_y'))
        df_right_intersection_00.drop(df_right_intersection_00.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
        #df_right_intersection_01 = df_right_intersection.merge(pheno_of_interest, how='left', left_on=['image_01'], right_on=['image'], suffixes=('', '_y'))
        #df_right_intersection_01.drop(df_right_intersection_01.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
        df_right_intersection_10 = df_right_intersection.merge(pheno_of_interest, how='left', left_on=['image_10'], right_on=['image'], suffixes=('', '_y'))
        df_right_intersection_10.drop(df_right_intersection_10.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
        #df_right_intersection_11 = df_right_intersection.merge(pheno_of_interest, how='left', left_on=['image_11'], right_on=['image'], suffixes=('', '_y'))
        #df_right_intersection_11.drop(df_right_intersection_11.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)

        ## left eye. Only 00 and 10
        df_left_intersection_00 = df_left_intersection.merge(pheno_of_interest, how='left', left_on=['image_00'], right_on=['image'], suffixes=('', '_y'))
        df_left_intersection_00.drop(df_left_intersection_00.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
        #df_left_intersection_01 = df_left_intersection.merge(pheno_of_interest, how='left', left_on=['image_01'], right_on=['image'], suffixes=('', '_y'))
        #df_left_intersection_01.drop(df_left_intersection_01.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
        df_left_intersection_10 = df_left_intersection.merge(pheno_of_interest, how='left', left_on=['image_10'], right_on=['image'], suffixes=('', '_y'))
        df_left_intersection_10.drop(df_left_intersection_10.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)
        #df_left_intersection_11 = df_left_intersection.merge(pheno_of_interest, how='left', left_on=['image_11'], right_on=['image'], suffixes=('', '_y'))
        #df_left_intersection_11.drop(df_left_intersection_11.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)

        # To avaid having the same name
        ## right 
        df_right_intersection_00.rename(columns = {pheno_name: pheno_name+'_00'}, inplace = True)
        df_right_intersection_10.rename(columns = {pheno_name: pheno_name+'_10'}, inplace = True)
        #df_right_intersection_01.rename(columns = {pheno_name: pheno_name+'_01'}, inplace = True)
        #df_right_intersection_11.rename(columns = {pheno_name: pheno_name+'_11'}, inplace = True)

        ## left
        df_left_intersection_00.rename(columns = {pheno_name: pheno_name+'_00'}, inplace = True)
        df_left_intersection_10.rename(columns = {pheno_name: pheno_name+'_10'}, inplace = True)
        #df_left_intersection_01.rename(columns = {pheno_name: pheno_name+'_01'}, inplace = True)
        #df_left_intersection_11.rename(columns = {pheno_name: pheno_name+'_11'}, inplace = True)

        ## Plot:
        #plt_RL_00_10(df_right_intersection_00, df_right_intersection_10, df_left_intersection_00, df_left_intersection_10, pheno_name)

        ## Create datafields with (00-10) and |00-10|:
        df_right_intersection_all, df_left_intersection_all = create_different_time_points_df(df_right_intersection_00, df_right_intersection_10, df_left_intersection_00, df_left_intersection_10, pheno_name)

        ## Plot:
        #plt_RL_00_menis_10(df_right_intersection_all, df_left_intersection_all, pheno_name, ' No QC')

        ## Save file before QC:
        df_right_intersection_all.to_csv(dir_save_results + pheno_name + '_right_before_QC.csv') 
        df_left_intersection_all.to_csv(dir_save_results + pheno_name + '_left_before_QC.csv')  

        ## Filter by QC
        df_right_QC, df_left_QC = create_different_time_points_df2(df_QC, df_right_intersection_all, df_left_intersection_all, pheno_name)
        
        ### Saving files after QC
        df_right_QC.to_csv(dir_save_results + pheno_name + '_right_QC.csv') 
        df_left_QC.to_csv(dir_save_results + pheno_name + '_left_QC.csv')

        #plt_RL_00_menis_10(df_right_QC, df_left_QC, pheno_name, ' with QC')
import pandas as pd
import seaborn as sns
import os
import glob
import numpy as np
import matplotlib as plt

# df_data_completo = pd.read_csv("/Users/sortinve/Desktop/GWAS_phenofiles/data_manual_and_DL_features.csv", sep=' ')
# # Reemplazar los -999 por np.NaN
# # Comparar si borrando los NaNs disminuye mucho la muestra
# sns_plot = sns.pairplot(df_data_completo[["0", "1", "2", "3"]], diag_kind="hist",  kind="reg")
# sns_plot.savefig('example_phenofile_seaborn.png')

df_data_completo = pd.read_csv("/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/"
                               "Phenofiles/2021_12_28_multitrait_mattiaQC_qqnorm.csv", sep=' ')
df_data_bif = pd.read_csv("/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/"
                               "Phenofiles/2022_02_04_bifurcations_ageCorrectedVentile5QC_qqnorm.csv", sep=' ')

df_data_tVA = pd.read_csv("/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/"
                               "Phenofiles/2022_02_14_tVA_ageCorrectedVentile5QC_qqnorm.csv", sep=' ')

df_data_tAA = pd.read_csv("/Users/sortinve/Desktop/Vascular_shared_genetics_in_the_retina/"
                               "Phenofiles/2022_02_14_tAA_ageCorrectedVentile5QC_qqnorm.csv", sep=' ')

df_data_completo['N_bif'] = df_data_bif
df_data_completo['tAA'] = df_data_tAA
df_data_completo['tVA'] = df_data_tVA
df_data_completo = df_data_completo.rename(columns = {'medianDiameter_all': 'ɸ', 'DF_all': 'τ'}, inplace = False)

print(df_data_completo.columns)

# Reemplazar los -999 por np.NaN
# Comparar si borrando los NaNs disminuye mucho la muestra
print("Sample size before delete the -999: ", len(df_data_completo))
df_data_completo = df_data_completo[df_data_completo != -999]
df_data_completo = df_data_completo.dropna()
print("Sample size after delete the -999: ", len(df_data_completo))

### First type of image -  Simple version: Scatter plots with lines and histogram in the diagonal
sns_plot = sns.pairplot(df_data_completo[["ɸ", "τ", "tVA", "tAA", "N_bif"]], diag_kind="hist",  kind="reg",
                        plot_kws={'scatter_kws': {'alpha': 0.8, 's': 0.5}
                                    # ,'line_kws':{'color':'red'}
                                  })

sns.set(font_scale = 2)
sns.set_context("paper", rc={"axes.labelsize":28})
sns_plot.savefig('example_type1_phenofile_seaborn.png')


##### Second type of image: Scatter plots with corr values in the first half and histogram in the diagonal
# Function to calculate correlation coefficient between two arrays
def corr(x, y, **kwargs):
    # Calculate the value
    coef = np.corrcoef(x, y)[0][1]
    # Make the label
    label = r'$\rho$ = ' + str(round(coef, 2))
    # Add the label to the plot
    ax = plt.pyplot.gca()
    ax.annotate(label, xy=(0.2, 0.95), size=20, xycoords=ax.transAxes)


# Create a pair grid instance
grid = sns.PairGrid(data=df_data_completo,
                    vars=["ɸ", "τ", "tVA", "tAA", "N_bif"], size=4)

# Map the plots to the locations
grid = grid.map_upper(plt.pyplot.scatter)
grid = grid.map_upper(corr)
grid = grid.map_diag(plt.pyplot.hist, bins=10, edgecolor='k')
grid = grid.map_lower(sns.scatterplot)
grid.savefig('example_type2_phenofile_seaborn.png')


print(1)

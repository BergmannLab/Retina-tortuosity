import pandas as pd
import numpy as np
import glob
import os

os.chdir('/Users/sortinve/PycharmProjects/DL_retina/Features/archive_1_to_40000')
i = 0
# data_0 = np.load('/Users/sortinve/PycharmProjects/DL_retina/Features/archive_1_to_1000/1018804_train_feature_0_activation.npy')
for img in glob.glob("*train_feature_11_activation.npy"):
    if i == 0:
        df_concat = np.load(img)
        df_concat = df_concat[0, 0, :, :]
        df_concat = pd.DataFrame(df_concat)
    else:
        df_0 = np.load(img)
        df_0 = df_0[0, 0, :, :]
        df_0 = pd.DataFrame(df_0)
        df_concat = pd.concat((df_0, df_concat))
    i = i + 1

by_row_index = df_concat.groupby(df_concat.index)
df_means = by_row_index.mean()
df_median = by_row_index.median()
df_std = by_row_index.std()

df_means.to_csv("/Users/sortinve/PycharmProjects/DL_retina/Features/rawdata/mean_11.csv", sep=' ', index=False)
df_median.to_csv("/Users/sortinve/PycharmProjects/DL_retina/Features/rawdata/median_11.csv", sep=' ', index=False)
df_std.to_csv("/Users/sortinve/PycharmProjects/DL_retina/Features/rawdata/std_11.csv", sep=' ', index=False)


import pandas as pd

samples = pd.read_csv("~/data_sbergman/retina/colaus_axiom_hrc.r1.1.2016_imputed/CoLaus.sample", delimiter=' ', index_col="ID_1")
samples = samples.drop(0)

covars = pd.read_csv("~/covar.txt", delimiter=",", index_col="pt")


covars_ordered = covars.loc[samples.index]
print(covars_ordered.shape)
print(covars_ordered)

covars_ordered.to_csv("~/data_sbergman/retina/covar.csv", sep=" ", index=False)

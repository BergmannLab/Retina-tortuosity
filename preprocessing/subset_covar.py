import pandas as pd

genotypedir="/data/FAC/FBM/DBC/sbergman/retina/UKBiob/genotypes/"
covardir="/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/GWAS/output/ExtractCovariatePhenotypes/2020_10_03_final_covar/"

full=pd.read_csv(genotypedir+"ukb43805_imp_chr1_v3_s487297.sample",delimiter=" ",skiprows=2, header=None,dtype=int)
fundus=pd.read_csv(genotypedir+"ukb_imp_v3_subset_fundus.sample",delimiter=" ",skiprows=2, header=None,dtype=int)
covar = pd.read_csv(covardir+"final_covar.csv", delimiter=" ")
covar=covar.set_index(full[0])


subsamples = covar.loc[fundus[0]]
print(subsamples.shape, fundus.shape)
subsamples.to_csv(covardir+"final_covar_fundus.csv", sep=" ", index=False)

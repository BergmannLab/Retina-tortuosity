# Little script converting bgenie output into
# 1) Top GWAS hits file
# 2) GWAS sumstats file readable by LD Score Regression and PascalX

import sys,os
import pandas as pd
import numpy as np
from multiprocessing import Pool
import time

path = sys.argv[1] #"/users/mbeyele5/scratch_sbergman/retina/GWAS/output/RunGWAS/2022_07_08_ventile2_corrected/"
outpath = path

pheno = sys.argv[2] #'DF_all'
sample_size = sys.argv[3] #34343

def process_chromosome(chr_no):
	start_time = time.time()
	print("Chromosome", chr_no)
	
	pval_label = pheno+'-log10p'
	beta_label = pheno+'_beta'
	se_label = pheno+'_se'

	columns = ['chr','rsid','pos','a_0','a_1',pval_label,beta_label,se_label, "af", "info"]
	
	print("Read columns:\n",columns)

	df = pd.read_csv(path+"output_ukb_imp_chr"+str(chr_no)+"_v3.txt", sep=" ", usecols=columns)
	
	df.dropna(inplace=True)

	print("chr file read", time.time()-start_time)
	
	# Processing to various output formats

	df['ordinary_pvals'] = 10**(df[pval_label]*-1)
	df['N'] = sample_size
		
	# 1) Top hits
	top_hits_chr = df[df[pval_label]>7.3].copy()
	if len(top_hits_chr) > 0:
		top_hits_chr = top_hits_chr[top_hits_chr['af']>0.0005]
		top_hits_chr = top_hits_chr[top_hits_chr['info']>=0.3]
	
	## 2) Pascal
	#pascal_cols = ['chr','rsid','pos','ordinary_pvals',beta_label,se_label]
	#pascal_colnames = pascal_cols.copy()
	#pascal_colnames[3] = 'pvalue'
	#pascal_dict = dict(zip(pascal_cols, pascal_colnames))
	
	# 2) GWAS summary statistics for both PascalX and LD Score Regression    # previously only LD score regression
	ldsc_cols = ['rsid','a_0','a_1','ordinary_pvals',beta_label,se_label,'N']
	ldsc_colnames = ['rsid','A1','A2','P','beta','se','N']
	ldsc_dict = dict(zip(ldsc_cols,ldsc_colnames))

	#input("press any key")

	top_hits_file = outpath+pheno+"__top_hits.csv"
	#pascal_file = outpath+pheno+"__pascalInput.csv"
	ldsc_file = outpath+pheno+"__gwas_sumstats.tsv"                          #"__ldscInput.txt"
	
	
	print("chr processed", time.time() - start_time)
	
	# Writing output

	# Case chromosome 1
	if chr_no==1:
		top_hits_chr.to_csv(top_hits_file, index=False)
	
		#df[pascal_cols].rename(pascal_dict, axis=1).to_csv(pascal_file, index=False)
	
		df[ldsc_cols].rename(ldsc_dict, axis=1).to_csv(ldsc_file, sep='\t', index=False)

	# Case all other chromosomes
	else:
		top_hits_chr.to_csv(top_hits_file, mode='a', header=False, index=False)

		#df[pascal_cols].to_csv(pascal_file, mode='a', header=False, index=False)
		print("Chr no", chr_no)
		df[ldsc_cols].to_csv(ldsc_file, sep='\t', mode='a', header=False, index=False)
	print("chr", chr_no, "end", time.time() - start_time)



if __name__ == '__main__':

	start_time = time.time()	

	print(pheno)

	for i in range(1,23):
		process_chromosome(i)

	print("END", time.time()-start_time)

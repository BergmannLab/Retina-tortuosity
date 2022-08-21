import pandas as pd
import numpy as np
import sys
from datetime import datetime

# input
phenofile_dir=sys.argv[1]
phenofile_id=sys.argv[2]
nb_pcs = int(sys.argv[3])

instances = pd.read_csv(phenofile_dir + phenofile_id + "_instances.csv", index_col=0)

# raw covariates
usecols = ['eid', '31-0.0', '21003-0.0', '21003-1.0', '5084-0.0', '5085-0.0', '5086-0.0', '5087-0.0', '5084-1.0', '5085-1.0', '5086-1.0', '5087-1.0']
# 21003: age when visiting center
# 5084-5: spherical power, R L
# 5086-7: cylindrical power, R L
usecols = usecols + ['22009-0.' + str(i) for i in range(1,41)]

covars_in = pd.read_csv("/data/FAC/FBM/DBC/sbergman/retina/UKBiob/phenotypes/2_data_extraction_BMI_height_IMT/ukb42432.csv",\
                     sep=",", usecols=usecols, index_col='eid', skiprows=[1])
covars_in = covars_in.loc[instances.index] # ordering to match phenofile order

# sex
covars_out = covars_in[['31-0.0']].copy()
covars_out.rename({'31-0.0':'sex'}, axis=1, inplace=True)

# age
#date_of_visit = []
#for i,inst in enumerate(instances['instance']): # matching assessment dates
#	if inst==0:
#		date_of_visit.append(covars_in['53-0.0'].iloc[i])
#	elif inst==1:
#		date_of_visit.append(covars_in['53-1.0'].iloc[i])
#	else:
#		date_of_visit.append(covars_in['53-0.0'].iloc[i]) # this is arbitrary, just not to have nans
#
#year_of_visit = [str(i).split("-")[0] for i in date_of_visit]
#year_of_visit = list(map(int, year_of_visit))
#age_at_visit = year_of_visit - covars_in['34-0.0']
#day_of_visit = [datetime.strptime(date, '%Y-%m-%d').timetuple().tm_yday for date in date_of_visit]
#age_at_visit = np.round(age_at_visit + np.array(day_of_visit) / 365.25, 2)

covs = []
for i,inst in enumerate(instances['instance']):
	if inst==0:
		covs.append(covars_in[['21003-0.0', '5084-0.0','5085-0.0','5086-0.0','5087-0.0']].iloc[i].values)
	elif inst==1:
		covs.append(covars_in[['21003-1.0','5084-1.0','5085-1.0','5086-1.0','5087-1.0']].iloc[i].values)
	else:
		covs.append(np.nan)

age = [i[0] if isinstance(i, np.ndarray) else np.nan for i in covs]
spher_pow = [np.nanmean(i[1:3]) if isinstance(i, np.ndarray) else np.nan for i in covs]
cyl_pow = [np.nanmean(i[3:5]) if isinstance(i, np.ndarray) else np.nan for i in covs]

covars_out['age'] = age
covars_out['age-squared'] = np.round(np.square(age), 2)
covars_out['spherical_power'] = spher_pow
covars_out['spherical_power-squared'] = np.round(np.square(spher_pow),2)
covars_out['cylindrical_power'] = cyl_pow
covars_out['cylindrical_power-squared'] = np.round(np.square(spher_pow),2)

# PCs
for i in range(1,nb_pcs+1):
	covars_out['PC'+str(i)] = covars_in['22009-0.'+str(i)].values

print(covars_out.isna().sum())

covars_out = covars_out.astype('str')
covars_out = covars_out.replace('nan', '-999')

covars_out.to_csv(phenofile_dir+phenofile_id+'_covar.csv', index=False, sep=' ')

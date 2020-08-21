import pandas as pd
import os as os

# read samples file: create a dataframe that contains uniquely the participant ids
def read_samples(sample_file):
    samples = pd.read_csv(sample_file, sep=" ")
    # use the participant id (eid) as index
    ##########samples.set_index("ID_1")
    # drop test value at index 0: "0 0 0 D"
    samples.drop(samples.index[0], inplace=True) 
    # keep non-missing samples only
    samples = samples[samples['missing'] == 0]
    # drop column that are not needed (missing and sex)
    samples.drop(samples.columns[[1,2,3]], axis=1, inplace=True)
    # rename the one column that is needed: eid
    samples.rename(columns = {'ID_1':'eid'}, inplace = True)
    return samples
    
def Extract_GWAS_Phenotypes(output, UKBB_pheno_file, phenos_to_extract, sample_file):
    
    # read phenotypes and samples
    UKBB_phenotypes = pd.read_csv(UKBB_pheno_file)
    samples = read_samples(sample_file)

    # create a dataframe containing the participant id (eid) from phenotypes
    extracted_phenos = UKBB_phenotypes["eid"]
    # all column corresponding to required phenos
    for pheno_UID in phenos_to_extract.split(","):
        extracted_phenos = pd.concat([extracted_phenos, UKBB_phenotypes[pheno_UID]], axis=1)
    # inner merge with samples file: only keep eids in the sample
    extracted_phenos = pd.merge(samples, extracted_phenos, how='left', on=['eid'])
    extracted_phenos.drop('eid', axis=1, inplace = True) # after merge, this is no longer needed
    # replace NAs according to BGENIE convention
    extracted_phenos.fillna(-999, inplace=True)
    # output
    extracted_phenos.to_csv(output, sep=' ', index = False)

def main():
    output = os.sys.argv[1]
    UKBB_pheno_file = os.sys.argv[2]
    phenos_to_extract = os.sys.argv[3]
    sample_file = os.sys.argv[4]
    print("Starting Extraction of phenotypes: " + phenos_to_extract)
    print("from UKBB phenotype file: " + UKBB_pheno_file)
    print("using sample file: " + sample_file)
    Extract_GWAS_Phenotypes(output, UKBB_pheno_file, phenos_to_extract, sample_file)
    print("done")
  
if __name__== "__main__":
    main()
  


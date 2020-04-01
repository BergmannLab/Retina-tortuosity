import pandas as pd

def assemble_bedfiles():
    # import data: only interesting columns
    print("PROCESSING catalogue")
    input_gwas_catalogue = './input/gwas-catalogue_EBI__glucose__europeans-only___v37.tsv'
    gwas_catalogue = pd.read_csv(input_gwas_catalogue, usecols=['CHR_ID', 'CHR_POS'], sep='\t')
    gwas_catalogue.sort_values(['CHR_ID', 'CHR_POS'], ascending=[True, True], inplace=True) # sort
    gwas_catalogue['CHR_ID'] = 'chr' + gwas_catalogue['CHR_ID'].astype(str) # add prefix to first column
    gwas_catalogue.insert(1, 'CHR_POS_END', gwas_catalogue['CHR_POS']) # duplicate position to crate an interval
    gwas_catalogue.drop_duplicates(subset=['CHR_ID', 'CHR_POS'], inplace=True)# remove duplicated entries

    #print("PROCESSING ISA gwas output")
    input_epacts_ISA = './input/epacts_dGlucose_ISA_serum.tsv'
    epacts_ISA = pd.read_csv(input_epacts_ISA, usecols=['#CHROM', 'BEGIN', 'PVALUE'], sep='\t')
    epacts_ISA = epacts_ISA[pd.notnull(epacts_ISA['PVALUE'])]
    epacts_ISA['#CHROM'] = 'chr' + epacts_ISA['#CHROM'].astype(str)
    epacts_ISA.insert(1, '', epacts_ISA['BEGIN'])
    
    #print("PROCESSING UMDB gwas output")
    input_epacts_UMDB = './input/epacts_dGlucose_UMDB_serum.tsv'
    epacts_UMDB = pd.read_csv(input_epacts_UMDB, usecols=['#CHROM', 'BEGIN', 'PVALUE'], sep='\t')
    epacts_UMDB = epacts_UMDB[pd.notnull(epacts_UMDB['PVALUE'])]
    epacts_UMDB['#CHROM'] = 'chr' + epacts_UMDB['#CHROM'].astype(str)
    epacts_UMDB.insert(1, '', epacts_UMDB['BEGIN'])
    
    #print("PROCESSING MEASURED-GLUCOSE gwas output")
    input_epacts_measured = './input/epacts_dGlucose_measured.tsv'
    epacts_measured = pd.read_csv(input_epacts_measured, usecols=['#CHROM', 'BEGIN', 'PVALUE'], sep='\t')
    epacts_measured = epacts_measured[pd.notnull(epacts_measured['PVALUE'])]
    epacts_measured['#CHROM'] = 'chr' + epacts_measured['#CHROM'].astype(str)
    epacts_measured.insert(1, '', epacts_measured['BEGIN'])
    
    # output
    print("WRITING catalogue")
    gwas_catalogue.to_csv('./run_bedtool-closest/confirmed_hits.bed', sep='\t', index=False, header=None)
    print("WRITING ISA gwas output")
    epacts_ISA.to_csv('./run_bedtool-closest/epacts_ISA.bed', sep='\t', index=False, header=None)
    print("WRITING UMDB gwas output")
    epacts_UMDB.to_csv('./run_bedtool-closest/epacts_UMDB.bed', sep='\t', index=False, header=None)
    print("WRITING UMDB gwas output")
    epacts_measured.to_csv('./run_bedtool-closest/epacts_measured.bed', sep='\t', index=False, header=None)

if __name__ == '__main__':
    print("\n-------------------PREPARING BEDFILE FOR TOOL 'BEDTOOLS CLOSETS'--------------------\n")
    assemble_bedfiles()
    print("\n--------------DONE: PREPARING BEDFILE FOR TOOL 'BEDTOOLS CLOSETS'--------------------\n")

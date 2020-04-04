import pandas as pd
import os
            
# read samples file: create a dataframe that contains uniquely the participant ids
def read_samples(sample_file):
    samples = pd.read_csv(sample_file, sep=" ")
    # drop test value at index 0: "0 0 0 D"
    samples.drop(samples.index[0], inplace=True) 
    # keep non-missing samples only
    samples = samples[samples['missing'] == 0]
    # drop column that are not needed (missing and sex)
    samples.drop(samples.columns[[1,2,3]], axis=1, inplace=True)
    # rename the one column that is needed: eid
    samples.rename(columns = {'ID_1':'eid'}, inplace = True)
    samples.set_index("eid", inplace = True)
    return samples

def calculate_average(stats_i, stats_collision):
    return (stats_i.values + stats_collision.values) / 2
    
def VesselStatsToPhenofile(output_dir, sample_file, stats_dir):
    
    # create an empty dataframe to hold stats
    # use the ei) from sample file as first column (to respect UKBBB ordering)
    stats_phenotypes = read_samples(sample_file)
    # add stats columns to dataframe
    stats_phenotypes['max_diameter'] = None
    stats_phenotypes['min_diameter'] = None
    stats_phenotypes['median_diameter'] = None
    stats_phenotypes['median_tortuosity'] = None
    stats_phenotypes['std_tortuosity'] = None
    
    # import stats for each input file
    for i in os.listdir(stats_dir):
        if not i.endswith("stats.tsv"): continue # process stats files only
        # import file stats to dataframe
        stats_i = pd.read_csv(stats_dir+"/"+i, sep="\t").iloc[0]
        # remove first element (it is a quality measure, not needed now)
        stats_i = stats_i.drop(stats_i.index[0])
        eid_i = float(i[0:7])
        try: # eid might not be present in stats_phenotypes
            collision = stats_phenotypes.loc[eid_i] 
            not_present = collision[0] == None
            if not_present: # simply add
                stats_phenotypes.loc[eid_i] = stats_i
            else: # average stats from iteration (stats_i) and those present (collision)
                stats_phenotypes.loc[eid_i] = calculate_average(stats_i,collision)

        except KeyError:
            print("WARNING: eid " + str(eid_i)[:-2] + " will not be included: not in sample file.")
                
        
    # replace NAs according to BGENIE convention
    valid = stats_phenotypes.iloc[:,1].notna().sum()
    print("\nA phenotype file has been built: " + str(valid) + "entries")
    stats_phenotypes.fillna(-999, inplace=True)
    # output
    output_file  = output_dir + "/VesselStatsPhenofile.csv"
    stats_phenotypes.to_csv(output_file, sep=' ', index = False)


def main():
    output_dir = os.sys.argv[1]
    sample_file = os.sys.argv[2]
    stats_dir = os.sys.argv[3]
    print("Turning Vessel Stats (ARIA) to GWAS phenofile")
    print("using sample file: " + sample_file + "\n")
    VesselStatsToPhenofile(output_dir, sample_file, stats_dir)
    print("DONE")
  
if __name__== "__main__":
    main() 
  

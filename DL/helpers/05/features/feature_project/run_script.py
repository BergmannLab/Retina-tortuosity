#set image transformation
from lib.inputs import Parameters
from lib.calc_feature import CalcFeature
from lib.extraction_func import *

#load parameters
P = Parameters()
P.calc_feat()
para = P.para

#local the extraction function
try:
    extract_func = locals()[para.extract_func]
except:
    print("extraction function does not exist!")
    exit()

if para.feature_idx != []:
   para.feature_idx = np.asarray(para.feature_idx.split(","),dtype=int)

CF = CalcFeature(para.layer_dir,para.output_file,extract_func)
CF.main(para.feature_idx)

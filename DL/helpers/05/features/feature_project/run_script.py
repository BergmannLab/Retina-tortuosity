#set image transformation
from lib.inputs import Parameters
from lib.calc_feature import CalcFeature
from lib.extraction_func import *

#load parameters
P = Parameters()
P.calc_feature()
para = P.para

#local the extraction function
try:
    extract_func = locals()[para.extract_func]
except:
    print("extraction function does not exist!")
    exit()

CF = CalcFeature(para.layer_dir,para.output_file,extract_func)
CF.main()

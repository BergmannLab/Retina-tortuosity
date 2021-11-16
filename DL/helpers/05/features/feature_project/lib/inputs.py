import argparse
import os

class Parameters:
    def __init__(self):
        self.calc_feature_parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
        self.script2_parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    def calc_feat(self):
        self.calc_feature_parser.add_argument('--layer_dir', default='input.txt', help='input file')
        self.calc_feature_parser.add_argument("--output_file", default='',help='')
        self.calc_feature_parser.add_argument("--extract_func", default='',help='')
        #set parameters
        self.para = self.calc_feature_parser.parse_args()

    def Process2(self):
        self.script2_parser.add_argument('--dataroot', default='', help='path to the data folder')
        #set parameters
        self.para = self.script2_parser.parse_args()

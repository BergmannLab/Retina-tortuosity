# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 11:08:36 2022

@author: MolasG
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sb
import os
from os import listdir
from os.path import isfile, join

#%%%
### TO MODIFY BY USER
#path to the folder containing the .lo files
path = 'C:/Users/MolasG/Desktop/pascalOutput/bisided lsdc'

#list of phenotypes/traits t oinclude
traits = ["x2780000","x2780100","x2782200","x2782300","x2782600","x2782700",
          "x2850000","x2850100","x2850200","x2850300","x2850400","x2850500"]

# lsit the files contained in the folder
files = [f for f in listdir(path) if isfile(join(path, f))] 

#%%
# maps to store results
array1 = np.zeros((len(traits),len(traits)))
array2 = np.zeros((len(traits),len(traits)))

heritability = [ [ ] for i in range(len(traits))] #np.zeros( len(traits) )
#%%
# filter the files names containing 2 traits

for f in files:
    count = 0
    idx =  []
    for t in traits:
        if(t in f):
            count+=1
            idx.append(traits.index(t))
    if(count==2):
        h2 = []
        with open(path+'/'+f) as fp:
            Lines = fp.readlines()
            for line in Lines:
                split = line.split()
                if('h2:' in split):
                    h2.append( float(split[ split.index('h2:') +1 ]) )
                if('gencov:' in split):
                    array1[idx[0],idx[1]] = float(split[ split.index('gencov:') +1 ])
                    array1[idx[1],idx[0]] = float(split[ split.index('gencov:') +1 ])
                if('Correlation:' in split):
                    array2[idx[0],idx[1]] = float(split[ split.index('Correlation:') +1 ]) 
                    array2[idx[1],idx[0]] = float(split[ split.index('Correlation:') +1 ]) 
                
                    
        for i in range(len(h2)):
            heritability[idx[i]].append(h2[i])
            
    elif( (count==1) and (len( f.split(traits[idx[0]]) ) == 3)):
        with open(path+'/'+f) as fp:
            Lines = fp.readlines()
            for line in Lines:
                split = line.split()
                if('h2:' in split):
                    array2[idx[0],idx[0]] = float(split[ split.index('h2:') +1 ]) 
                    

#%%
'''
df1 = pd.DataFrame(array1,columns=traits,index=traits)
plt.figure(figsize=(12,10))
sb.heatmap(df1,vmin=0, vmax=1,cmap="Blues",annot=True)
plt.title( 'Total Observed Scale Gencov' )
'''
#%%
df2 = pd.DataFrame(array2,columns=traits,index=traits)
plt.figure(figsize=(12,10))
sb.heatmap(df2,vmin=0, vmax=1,cmap="Blues",annot=True)
plt.title( 'Genetic Correlation')


#%%
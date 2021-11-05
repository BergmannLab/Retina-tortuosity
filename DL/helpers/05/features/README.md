# Extracting features from retinal disease prediction

This folder contains the code to extract the deep-learning (DL) features from the trained disease prediction model. In the first step, the raw neuron activation values are extracted and stored externally as pickled numpy arrays. These arrays are then loaded by a separate script and used to generate the phenotypes (response variables) for each subject.

#Contents
1. [Getting started](#start)
2. [Requirements](#require)
3. [Extract Neurons](#extract)
    1. [Usage](#extract_usage)
    2. [Examples](#extract_example)
4. [Calculating Phenotype](#phenotype)
    1. [Usage](#pheno_usage)
    2. [Examples](#pheno_example)
5. [How to cite](#cite)
6. [License](#license)

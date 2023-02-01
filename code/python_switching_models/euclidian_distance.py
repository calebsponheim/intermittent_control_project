# -*- coding: utf-8 -*-
"""
Created on Tue Jan 24 08:43:02 2023

@author: caleb_work
"""

import os
import pandas as pd
import numpy as np
import math
from os import listdir
from os.path import isfile, join
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import seaborn as sns
import pandas as pd
import umap

# %% Parameter Setting
subject = 'rj'
task = 'RTP'
model = 'rslds'

if (subject == 'rs') & (task == 'RTP'):
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 40
    num_discrete_states_hmm = 28
elif (subject == 'rs') & (task == 'CO'):
    num_latent_dims_rslds = 14
    num_discrete_states_rslds = 8
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 80
    num_discrete_states_hmm = 16
elif (subject == 'rj') & (task == 'RTP'):
    num_latent_dims_rslds = 22
    num_discrete_states_rslds = 10
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 80
    num_discrete_states_hmm = 16

# %% Data Import


current_working_directory = os.getcwd()
if "calebsponheim" in current_working_directory:
    folderpath_base_base = "C:/Users/calebsponheim/Documents/git/intermittent_control_project/"
elif "dali" in current_working_directory:
    folderpath_base_base = "/dali/nicho/caleb/git/intermittent_control_project/"
elif "Caleb (Work)" in current_working_directory:
    folderpath_base_base = "C:/Users/Caleb (Work)/Documents/git/intermittent_control_project/"
folderpath_base = folderpath_base_base + "data/python_switching_models/"

if subject == "bx":
    if task == "CO":
        folderpath = folderpath_base + "Bxcenter_out1902280.05sBins/"
    elif task == "CO+RTP":
        folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
elif subject == "bx18":
    folderpath = folderpath_base + "Bxcenter_out1803230.05sBins/"
elif subject == "rs":
    if task == "CO":
        folderpath = folderpath_base + "RSCO_move_window0.05sBins/"
    elif task == "RTP":
        folderpath = folderpath_base + "RSRTP0.05sBins/"
elif subject == "rj":
    folderpath = folderpath_base + "RJRTP0.05sBins/"
else:
    print("BAD, NO")

temp_folderlist = os.listdir(folderpath)
temp = str(num_discrete_states_rslds) + "_states_" + str(num_latent_dims_rslds) + "_dims"
if temp not in temp_folderlist:
    os.mkdir(folderpath + str(num_discrete_states_rslds) +
             "_states_" + str(num_latent_dims_rslds) + "_dims/")

# %%

biases = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + str(num_discrete_states_rslds) + "_states_" +
    str(num_latent_dims_rslds) + "_dims/biases.csv", header=0))

sns.set(style='white', context='notebook', rc={'figure.figsize': (14, 10)})
reducer = umap.UMAP()

embedding = reducer.fit_transform(biases)
embedding.shape

# %% Plotting
color_names = ['red', 'brown', 'purple', 'blue', 'hot pink',
               'orange', 'lime green', 'green', 'teal', 'light blue']
colors = sns.xkcd_palette(color_names)
sns.set_style("white")
sns.set_context("talk")

plt.scatter(
    embedding[:, 0],
    embedding[:, 1],
    c=[colors[x] for x in np.arange(num_discrete_states_rslds)])
plt.gca().set_aspect('equal', 'datalim')
plt.title('UMAP projection of discrete state fixed points', fontsize=24)

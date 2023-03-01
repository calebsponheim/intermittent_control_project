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
subject = 'bx'
task = 'RTP'
model = 'rslds'
cutoff = .9

if (subject == 'rs') & (task == 'RTP'):
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_lds = 40
    num_discrete_states_hmm = 28
elif (subject == 'rj') & (task == 'RTP'):
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_lds = 43
    num_discrete_states_hmm = 67
elif (subject == 'bx') & (task == 'RTP'):
    num_latent_dims_rslds = 30
    num_discrete_states_rslds = 10
    num_latent_dims_lds = 49
    num_discrete_states_hmm = 43
elif (subject == 'rs') & (task == 'CO'):
    num_latent_dims_rslds = 14
    num_discrete_states_rslds = 8
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
figurepath_base = folderpath_base_base + "figures/"

if subject == "bx":
    if task == "CO":
        folderpath = folderpath_base + "Bxcenter_out1902280.05sBins/"
        # folderpath = (
        #     folderpath_base + "Bxcenter_out1902280.05_sBins_move_window_only/"
        # )
        figurepath = figurepath_base + "Bx/CO_CT0/rslds/"
    elif task == "CO+RTP":
        folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
        figurepath = figurepath_base + "Bx/CO+RTP_CT0/rslds/"
    elif task == "RTP":
        folderpath = folderpath_base + "BxRTP0.05sBins/"
        figurepath = figurepath_base + "Bx/RTP_CT0/rslds/"
elif subject == "bx18":
    folderpath = folderpath_base + "Bxcenter_out1803230.05sBins/"
elif subject == "rs":
    if task == "CO":
        folderpath = folderpath_base + "RSCO_move_window0.05sBins/"
    elif task == "RTP":
        folderpath = folderpath_base + "RSRTP0.05sBins/"
        figurepath = figurepath_base + "RS/RTP_CT0/rslds/"
elif subject == "rj":
    folderpath = folderpath_base + "RJRTP0.05sBins/"
    figurepath = figurepath_base + "RJ/RTP_CT0/rslds/"
else:
    print("BAD, NO")

temp_folderlist = os.listdir(folderpath)
temp = str(num_discrete_states_rslds) + "_states_" + str(num_latent_dims_rslds) + "_dims"
if temp not in temp_folderlist:
    os.mkdir(folderpath + str(num_discrete_states_rslds) +
             "_states_" + str(num_latent_dims_rslds) + "_dims/")

# %%
latent_states_full = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + str(num_discrete_states_rslds) + "_states_" +
    str(num_latent_dims_rslds) + "_dims/latent_states_full.csv", header=None))


biases = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + str(num_discrete_states_rslds) + "_states_" +
    str(num_latent_dims_rslds) + "_dims/biases.csv", header=0))

# %% PCA

pca = PCA()
latent_states_reduced = pca.fit_transform(latent_states_full)
fixed_point_reduced = pca.transform(biases)

fixed_point_reduced_out = pd.DataFrame(fixed_point_reduced)
fixed_point_reduced_out.to_csv(folderpath + str(num_discrete_states_rslds) +
                               "_states_" + str(num_latent_dims_rslds) + "_dims/" +
                               'fixed_points_PCA.csv', index=False, header=False)

# %%
# UMAP
# sns.set(style='white', context='notebook', rc={'figure.figsize': (14, 10)})
# reducer = umap.UMAP()

# reduced_data = reducer.fit_transform(biases)
# reduced_data.shape

# %% Plotting
color_names = ['black', 'grey', 'red', 'brown', 'purple', 'blue', 'hot pink', 'orange',
               'mustard', 'green', 'teal', 'light blue', 'olive green',
               'peach', 'periwinkle', 'magenta', 'salmon', 'lime green']
colors = sns.xkcd_palette(color_names)
sns.set_style("white")
sns.set_context("talk")

plt.scatter(
    fixed_point_reduced[:, 0],
    fixed_point_reduced[:, 1],
    c=[colors[x] for x in np.arange(num_discrete_states_rslds)])
plt.gca().set_aspect('equal', 'datalim')
plt.title('2D plot of Hi-D discrete state fixed points', fontsize=24)
plt.savefig(figurepath + str(num_discrete_states_rslds) +
            "_states_" + str(num_latent_dims_rslds) + "_dims/" + "PCA_fixed_points.png")

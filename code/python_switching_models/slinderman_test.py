# -*- coding: utf-8 -*-
"""
Created on Thu Jan 14 09:56:52 2021

@author: calebsponheim
"""
import csv
from os import listdir
from os.path import isfile, join
import numpy as np

folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05sBins/'
spikefiles = [f for f in listdir(folderpath) if isfile(join(folderpath, f)) if f.endswith('_spikes.csv')]


file_count = 0
for iFile in spikefiles:
    with open(folderpath + iFile) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        for row in csv_reader:
            if line_count == 0:
                data_ind_file = row
            trial_length = np.arange(0,len(row))
            data_ind_file = np.vstack((data_ind_file,row))
            line_count += 1
    if file_count == 0:
        data_by_trial = data_ind_file
        data_concatenated = data_ind_file
    data_by_trial = np.dstack((data_by_trial,data_ind_file))
    data_concatenated = np.hstack((data_concatenated,data_ind_file))
    file_count += 1
    print(f'Processed {file_count} trials.')
       
#%% Import Kinematics into the equation
kinfiles = [f for f in listdir(folderpath) if isfile(join(folderpath, f)) if f.endswith('_kinematics.csv')]
file_count = 0
for iFile in kinfiles:
    with open(folderpath + iFile) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        for row in csv_reader:
            if line_count == 0:
                x_ind_file = row
            elif line_count == 1:
                y_ind_file = row
            elif line_count == 2:
                speed_ind_file = row
            line_count += 1
    if file_count == 0:
        x_by_trial = x_ind_file
        x_concatenated = x_ind_file
        y_by_trial = y_ind_file
        y_concatenated = y_ind_file
        speed_by_trial = speed_ind_file
        speed_concatenated = speed_ind_file
    x_by_trial = np.dstack((x_by_trial,x_ind_file))
    x_concatenated = np.hstack((x_concatenated,x_ind_file))
    
    y_by_trial = np.dstack((y_by_trial,y_ind_file))
    y_concatenated = np.hstack((y_concatenated,y_ind_file))
    
    speed_by_trial = np.dstack((speed_by_trial,speed_ind_file))
    speed_concatenated = np.hstack((speed_concatenated,speed_ind_file))
    
    file_count += 1
    print(f'Processed {file_count} trials.')



#%%
import autograd.numpy as np
import autograd.numpy.random as npr
npr.seed(0)

import ssm
from ssm.util import find_permutation
from ssm.plots import gradient_cmap, white_to_color_cmap

import matplotlib.pyplot as plt

import seaborn as sns
sns.set_style("white")
sns.set_context("talk")

color_names = [
    "windows blue",
    "red",
    "amber",
    "faded green",
    "dusty purple",
    "orange",
    "light red",
    "slate blue"
    ]

colors = sns.xkcd_palette(color_names)
cmap = gradient_cmap(colors)

time_bins = data_concatenated.shape[1]
num_states = 8
observation_dimensions = data_concatenated.shape[0]

data = data_concatenated[:,np.arange(0,time_bins,50)]
data = data.astype(np.int64)
data = np.transpose(data)
N_iters = 50

## testing the constrained transitions class
hmm = ssm.HMM(num_states, observation_dimensions, observations="poisson")

hmm_lls = hmm.fit(data, method="em", num_iters=N_iters, init_method="kmeans")

plt.plot(hmm_lls, label="EM")
# plt.plot([0, N_iters], true_ll * np.ones(2), ':k', label="True")
plt.xlabel("EM Iteration")
plt.ylabel("Log Probability")
plt.legend(loc="lower right")
plt.show()

#%% finding most likely states, plotting

hmm_z = hmm.most_likely_states(data)
#%%

for iTrial in np.arange(0,10): #data_by_trial.shape[2]):
    plt.figure(figsize=(15, 6))
    plt.subplot(211)
    plt.imshow(hmm_z[None,np.arange((4500/50*iTrial),(4500/50*(iTrial+1))).astype(int)], aspect="auto", cmap=cmap, vmin=0, vmax=len(colors)-1)
    plt.xlim(0,(4500/50))
    plt.yticks([])
    plt.xlabel("time")

    plt.subplot(212)
    plt.plot(speed_concatenated.astype(np.float)[np.arange((4500*iTrial),(4500*(iTrial+1)))])
    plt.xlim(0,4500)
    plt.tight_layout()
    plt.savefig(str(iTrial) + '.png')

#%% transition matrices

learned_transition_mat = hmm.transitions.transition_matrix

fig = plt.figure(figsize=(8, 4))
im = plt.imshow(learned_transition_mat, cmap='gray')
plt.title("Learned Transition Matrix")

cbar_ax = fig.add_axes([0.95, 0.15, 0.05, 0.7])
fig.colorbar(im, cax=cbar_ax)
plt.show()

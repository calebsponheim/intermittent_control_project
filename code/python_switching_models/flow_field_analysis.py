# -*- coding: utf-8 -*-
"""
Created on Mon Feb 27 12:08:32 2023

@author: calebsponheim
"""

import numpy as np
import os
import pickle
# analyze flow fields to characterize dynamics

# parameters
lims = (-100, 100)
npts = 10
fold_number = 4
subject = "rs"
task = 'RTP'
number_of_discrete_states = 2
number_of_latent_dimensions = 2
# load dynamics and biases

current_working_directory = os.getcwd()
if "calebsponheim" in current_working_directory:
    folderpath_base_base = "C:/Users/calebsponheim/Documents/git/intermittent_control_project/"
elif "dali" in current_working_directory:
    folderpath_base_base = "/dali/nicho/caleb/git/intermittent_control_project/"
elif "project/nicho/caleb" in current_working_directory:
    folderpath_base_base = "/project/nicho/caleb/git/intermittent_control_project/"
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
        figurepath = figurepath_base + "Bx/RTP/rslds/"
elif subject == "bx18":
    folderpath = folderpath_base + "Bx18CO0.05sBins/"
    figurepath = figurepath_base + "Bx/CO18_CT0/rslds/"
elif subject == "rs":
    if task == "CO":
        # folderpath = folderpath_base + "RSCO0.05sBins/"
        folderpath = folderpath_base + "RSCO_move_window0.05sBins/"
        figurepath = figurepath_base + "RS/CO_CT0_move_only/rslds/"

    elif task == "RTP":
        folderpath = folderpath_base + "RSRTP0.05sBins/"
        figurepath = figurepath_base + "RS/RTP_CT0/rslds/"
elif subject == "rj":
    folderpath = folderpath_base + "RJRTP0.05sBins/"
    figurepath = figurepath_base + "RJ/RTP_CT0/rslds/"
else:
    print("BAD, NO")

temp_folderlist = os.listdir(folderpath)
temp_figurelist = os.listdir(figurepath)
if str(number_of_discrete_states) + "_states_" + str(number_of_latent_dimensions) + "_dims" not in temp_folderlist:
    os.mkdir(folderpath + str(number_of_discrete_states) +
             "_states_" + str(number_of_latent_dimensions) + "_dims/")
if str(number_of_discrete_states) + "_states_" + str(number_of_latent_dimensions) + "_dims" not in temp_figurelist:
    os.mkdir(figurepath + str(number_of_discrete_states) +
             "_states_" + str(number_of_latent_dimensions) + "_dims/")

folderpath_out = folderpath + str(number_of_discrete_states) + \
    "_states_" + str(number_of_latent_dimensions) + "_dims/"
figurepath = figurepath + str(number_of_discrete_states) + \
    "_states_" + str(number_of_latent_dimensions) + "_dims/"

infile = open(folderpath_out + 'fold_' + str(fold_number) + '_model', 'rb')
model = pickle.load(infile)
infile.close()

# calculate dxdy
dim_space = np.linspace(*lims, 10)
X, Y = np.meshgrid(dim_space, dim_space)
xy = np.column_stack((X.ravel(), Y.ravel()))


# Get the probability of each state at each xy location
log_Ps = model.transitions.log_transition_matrices(
    xy, np.zeros((nxpts * nypts, 0)), np.ones_like(xy, dtype=bool), None)
z = np.argmax(log_Ps[:, 0, :], axis=-1)
z = np.concatenate([[z[0]], z])

state_movement = []
# get the direction of dynamics
for k, (A, b) in enumerate(zip(model.dynamics.As, model.dynamics.bs)):
    dxydt_m = xy.dot(A.T) + b - xy

    zk = z == k
    if zk.sum(0) > 0:
        # xy[zk, 0]
        # xy[zk, 1],
        state_movement_position
        state_movement.append(dxydt_m[zk, :])

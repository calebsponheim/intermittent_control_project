# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 13:42:30 2022

@author: caleb_work
"""
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Plotting R^2 Values from Kalman Filter Decoders
subject = 'rs'
task = 'CO'

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


# Raw

raw_r2 = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + 'raw_kalman_test_R2_for_model_comparison.csv'))

# HMM

hmm_r2 = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + 'hmm_kalman_test_R2_for_model_comparison.csv'))

# LDS

lds_r2 = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + 'lds_kalman_test_R2_for_model_comparison.csv'))

# rSLDS

rslds_r2 = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + 'rslds_kalman_test_R2_for_model_comparison.csv'))

# %%
plt.figure(figsize=[8, 8], dpi=300, edgecolor='white', layout='tight')
plt.plot(np.asarray(np.arange(0, 2, .1)), np.asarray(np.arange(0, 2, .1)), color='black')
plt.title("R^2 Values for Kalman Decoder Performance")
plt.xlabel("rSLDS R^2")
plt.ylabel("comparison R^2")

plt.plot(rslds_r2[:, 2], raw_r2[:, 2], marker='o', linestyle='none', color='red', label='Raw Data')
plt.plot(rslds_r2[:, 3], raw_r2[:, 3], marker='o', linestyle='none', color='red')

plt.plot(rslds_r2[:, 2], hmm_r2[:, 2], marker='o', linestyle='none', color='blue', label='HMM')
plt.plot(rslds_r2[:, 3], hmm_r2[:, 3], marker='o', linestyle='none', color='blue')

plt.plot(rslds_r2[:, 2], lds_r2[:, 2], marker='o', linestyle='none', color='green', label='LDS')
plt.plot(rslds_r2[:, 3], lds_r2[:, 3], marker='o', linestyle='none', color='green')
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.legend()

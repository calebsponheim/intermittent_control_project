# -*- coding: utf-8 -*-
"""
Created on Thu Aug  5 11:23:49 2021.

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import ssm
import numpy as np
import seaborn as sns

# Plotting Latent continuous states

continuous_states = q_lem_x
decoded_data = slds.most_likely_states(
    continuous_states, np.transpose(bin_sums))

sns.set_style("white")
sns.set_context("talk")

color_names = ["windows blue",
               "red",
               "amber",
               "faded green",
               "dusty purple",
               "orange",
               "clay",
               "pink",
               "greyish",
               "mint",
               "light cyan",
               "steel blue",
               "forest green",
               "pastel purple",
               "salmon",
               "dark brown"]
colors = sns.xkcd_palette(color_names)

plt.figure(figsize=(16, 16))
for iBin in range(len(continuous_states)):
    plt.plot(continuous_states[iBin, 0], continuous_states[iBin,
             1], '.', color=colors[decoded_data[iBin]])

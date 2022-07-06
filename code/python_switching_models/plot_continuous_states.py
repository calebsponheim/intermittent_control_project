# -*- coding: utf-8 -*-
"""
Created on Wed Jun 29 14:41:22 2022.

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import numpy as np


def plot_continuous_states(xhat_lem, latent_dim_state_range, decoded_data_rslds):
    num_latent_dims = latent_dim_state_range

    # write for loop to make the string addition subplot combos that are needed.
    # so like, do like 1 across, that's standard. First digit is number of latent
    # dimensions, then second digit is 1, then the actuallt wait you can just do
    # (4,4,10) or whatever. just do that. lol.

    for iTrial in range(5):
        for iDim in range(num_latent_dims):
            plt.figure(iTrial)
            plt.subplot(num_latent_dims, 1, iDim+1)
            plt.plot(xhat_lem[iTrial][:, iDim])

    # Figure out a way to color the lines by most likely hidden state please?
    # save all the figures in an appropriate way, probably in their own folder if possible.

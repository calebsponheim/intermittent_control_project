# -*- coding: utf-8 -*-
"""
Created on Wed Dec 29 08:47:38 2021

@author: caleb_work
"""

import numpy as np
from sklearn.decomposition import PCA as PCA_sk
import matplotlib.pyplot as plt
import seaborn as sns


def analyze_params(model_params):
    "takes in the parameters from the rslds model, and attempts to plot/analyze the"
    "continuous state parameters to differentiate them?"

    dynamic_state_model_params = model_params[0][0]

    dynamic_state_model_params = np.column_stack((dynamic_state_model_params, model_params[1][1]))
    dynamic_state_model_params = np.column_stack((dynamic_state_model_params, model_params[1][2]))
    dynamic_state_model_params = np.column_stack((dynamic_state_model_params, model_params[2][1]))
    dynamic_state_model_params = np.column_stack((dynamic_state_model_params, model_params[2][3]))

    pca_params = PCA_sk()
    pca_for_params = pca_params.fit(dynamic_state_model_params)
    pca_components = pca_for_params.components_
    color_names = ["windows blue", "red", "amber", "faded green", "deep aqua", "fresh green",
                   "indian red", "orangeish", "old rose", "purple blue", "wine red",
                   "reddish orange"]
    colors = sns.xkcd_palette(color_names)
    sns.set_style("white")
    sns.set_context("talk")

    fig = plt.figure()
    ax = fig.add_subplot(projection='3d')
    for iState in range(len(pca_components)):
        ax.scatter(pca_components[iState, 0], pca_components[iState, 1], pca_components[iState, 2],
                   marker="o", color=colors[iState])

    plt.xlabel("PC 1")
    plt.ylabel("PC 2")
    plt.tight_layout()

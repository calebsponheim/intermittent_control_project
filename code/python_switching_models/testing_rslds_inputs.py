# -*- coding: utf-8 -*-
"""
Created on Mon Apr 11 11:00:35 2022

@author: calebsponheim
"""

# Testing rSLDS inputs

import ssm
import numpy as np
import autograd.numpy.random as npr
import seaborn as sns


def testing_rslds_inputs(data, trial_classification, meta, bin_size,
                         is_it_breaux, num_hidden_state_override, figurepath,
                         rslds_ll_analysis, latent_dim_state_range):
    """Train a Switching Linear Dynamical System."""
    # %%
    trind_train = [i for i, x in enumerate(
        trial_classification) if x == "train" or "model_select"]
    trainset = []
    # S = []
    # trial_count = 1
    for iTrial in range(len(trial_classification)):
        if iTrial in trind_train:
            trainset.append(np.transpose(np.array(data.spikes[iTrial])))

    # %%
    observation_dimensions = trainset[0].shape[1]
    number_of_states = num_hidden_state_override

    y = trainset
    num_latent_dims = 8

    K = number_of_states       # number of discrete states
    D_latent = num_latent_dims       # number of latent dimensions
    D_obs = observation_dimensions      # number of observed dimensions

    # % rSLDS
    # Fit with Laplace EM
    model = ssm.SLDS(D_obs, K, D_latent,
                     transitions="recurrent",
                     dynamics="diagonal_gaussian",
                     emissions="poisson",
                     single_subspace=True)
    model.initialize(y)
    q_elbos_lem, q_lem = model.fit(y, method="laplace_em",
                                   variational_posterior="structured_meanfield",
                                   initialize=False, num_iters=50)

    for iTrial in range(len(y)):
        xhat_lem_temp = q_lem.mean_continuous_states[iTrial]
        if iTrial == 0:
            xhat_lem = xhat_lem_temp
            zhat_lem = model.most_likely_states(xhat_lem_temp, y[iTrial])
        else:
            xhat_lem = np.vstack((xhat_lem, xhat_lem_temp))
            zhat_lem = np.hstack((zhat_lem, model.most_likely_states(xhat_lem_temp, y[iTrial])))
    model_params = model.params

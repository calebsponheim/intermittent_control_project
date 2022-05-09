# -*- coding: utf-8 -*-
"""
Created on Mon Apr 11 11:00:35 2022

@author: calebsponheim
"""

# Testing rSLDS inputs

import ssm
import numpy as np
# import autograd.numpy.random as npr
# import seaborn as sns
# import nlb_tools
from scipy.special import gammaln
import logging
logger = logging.getLogger(__name__)


def testing_rslds_inputs(data, trial_classification, meta, bin_size,
                         is_it_breaux, num_hidden_state_override, figurepath,
                         rslds_ll_analysis, latent_dim_state_range):
    """Train a Switching Linear Dynamical System."""
    # %%
    trind_train = [i for i, x in enumerate(
        trial_classification) if x == "train"]
    trind_test = [i for i, x in enumerate(
        trial_classification) if x == "test"]
    trainset = []
    testset = []
    # S = []a
    # trial_count = 1
    for iTrial in range(len(trial_classification)):
        if iTrial in trind_train:
            trainset.append(np.transpose(np.array(data.spikes[iTrial])))
        elif iTrial in trind_test:
            testset.append(np.transpose(np.array(data.spikes[iTrial])))

    # %%
    observation_dimensions = trainset[0].shape[1]
    number_of_states = num_hidden_state_override

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

    q_elbos_lem_train, q_lem_train = model.fit(trainset, method="laplace_em",
                                               variational_posterior="structured_meanfield",
                                               initialize=False, num_iters=25)

    # %% Generating Rates for Test Trials

    q_elbos_lem_test, q_lem_test = model.approximate_posterior(
        datas=testset,
        method="laplace_em",
        variational_posterior="structured_meanfield",
        num_iters=25)

    test_rates = [model.smooth(q_lem_test.mean_continuous_states[i],
                               testset[i]) for i in range(len(testset))]

    # %% Getting bits_per_spike
    test_bits = []
    for iTrial in range(len(testset)):
        nll_model = neg_log_likelihood(test_rates[iTrial], testset[iTrial])
        nll_null = neg_log_likelihood(
            np.tile(
                np.nanmean(testset[iTrial], axis=(0, 1), keepdims=True),
                (testset[iTrial].shape[0], testset[iTrial].shape[1])),
            testset[iTrial],
            zero_warning=False
        )
        test_bits.append((nll_null - nll_model) / np.nansum(testset[iTrial]) / np.log(2))

    test_bits_sum = sum(test_bits)
    # %%
    for iTrial in range(len(trainset)):
        xhat_lem_temp = q_lem_train.mean_continuous_states[iTrial]
        if iTrial == 0:
            xhat_lem = xhat_lem_temp
            zhat_lem = model.most_likely_states(xhat_lem_temp, trainset[iTrial])
        else:
            xhat_lem = np.vstack((xhat_lem, xhat_lem_temp))
            zhat_lem = np.hstack(
                (zhat_lem, model.most_likely_states(xhat_lem_temp, trainset[iTrial])))
    model_params = model.params

# %%


def neg_log_likelihood(rates, spikes, zero_warning=True):
    """Calculate Poisson negative log likelihood given rates and spikes.

    formula: -log(e^(-r) / n! * r^n)
           = r - n*log(r) + log(n!)


    Parameters
    ----------
    rates : np.ndarray
        numpy array containing rate predictions
    spikes : np.ndarray
        numpy array containing true spike counts
    zero_warning : bool, optional
        Whether to print out warning about 0 rate
        predictions or not

    Returns
    -------
    float
        Total negative log-likelihood of the data
    """
    assert spikes.shape == rates.shape, \
        f"neg_log_likelihood: Rates and spikes should be of the same shape. spikes: {spikes.shape}, rates: {rates.shape}"

    if np.any(np.isnan(spikes)):
        mask = np.isnan(spikes)
        rates = rates[~mask]
        spikes = spikes[~mask]

    assert not np.any(np.isnan(rates)), \
        "neg_log_likelihood: NaN rate predictions found"

    assert np.all(rates >= 0), \
        "neg_log_likelihood: Negative rate predictions found"
    if (np.any(rates == 0)):
        if zero_warning:
            logger.warning(
                "neg_log_likelihood: Zero rate predictions found. Replacing zeros with 1e-9")
        rates[rates == 0] = 1e-9

    result = rates - spikes * np.log(rates) + gammaln(spikes + 1.0)
    return np.sum(result)

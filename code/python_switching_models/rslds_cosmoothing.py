# -*- coding: utf-8 -*-
"""
Created on Mon May  9 14:07:15 2022

@author: calebsponheim
"""
import ssm
import numpy as np
from scipy.special import gammaln
import logging
logger = logging.getLogger(__name__)


def run_cosmoothing(model, ys, inputs=None, cs_frac=0.8):
    """
    Evaluate co-smoothing log likelihood on test trials. For each test trial,
    a random set of neurons are held-out. The latent states are estimated
    using the held-in neurons, and predictive performance is evaluated
    based on how well the latent state estimates the held-out neurons.

    Inputs:
    model   - SSM model
    ys      - list of observations on test trials
    inputs  - optional list of inputs
    cs_frac - fraction of held-out neurons during co-smoothing
    """

    if inputs is None:
        inputs = [np.zeros((y.shape[0],)) for y in ys]

    # get number of neurons
    N = ys[0].shape[0]
    shuff_indices = np.random.permutation(N)
    # leave out cs_frac fraction of neurons
    split_idx = int(cs_frac * N)

    train_neur, test_neur = shuff_indices[:split_idx], shuff_indices[split_idx:]

    # create masks that mask out test neurons
    masks = []
    for y in ys:
        mask = np.ones_like(y)
        mask[:, test_neur] *= 0
        mask = mask.astype(bool)
        masks.append(mask)

    # approximate posterior for
    # "held-in" or unmasked training neurons
    # number of iters is set to 25, but feel free to change these optimization params
    _elbos, _q_model = model.approximate_posterior(
        ys, inputs=inputs, masks=masks,
        method="laplace_em",
        variational_posterior="structured_meanfield",
        num_iters=25, alpha=0.5)

    # compute log likelihood of heldout neurons
    lls = 0.0
    for tr in range(len(ys)):
        ll = np.sum(model.emissions.log_likelihoods(ys[tr],
                                                    inputs[tr],
                                                    mask=np.invert(masks[tr]),
                                                    tag=None,
                                                    x=_q_model.mean_continuous_states[tr]))
        lls += ll
    return lls


def neg_log_likelihood(rates, spikes, zero_warning=True):
    # %%
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


def rslds_cosmoothing(data, trial_classification, meta, bin_size,
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

    # cosmoothing_input = trainset[0]

    # for iTrial in range(len(trainset)):
    #     cosmoothing_input = np.vstack([cosmoothing_input, trainset[iTrial]])

    # cosmoothing_input = cosmoothing_input[1:, :]

    # %%
    observation_dimensions = trainset[0].shape[1]
    number_of_states = num_hidden_state_override
    test_bits_sum = []

    # % rSLDS
    # Fit with Laplace EM

    model = ssm.SLDS(observation_dimensions, number_of_states, latent_dim_state_range,
                     transitions="recurrent",
                     dynamics="diagonal_gaussian",
                     emissions="poisson",
                     single_subspace=True)

    q_elbos_lem_train, q_lem_train = model.fit(trainset, method="laplace_em",
                                               variational_posterior="structured_meanfield",
                                               initialize=False, num_iters=25)
    # %%

    # lls = run_cosmoothing(model, cosmoothing_input, cs_frac=0.8)

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
    test_states = []
    for iTrial in range(len(testset)):
        test_states.append(model.most_likely_states(
            q_lem_test.mean_continuous_states[iTrial], testset[iTrial]))

        nll_model = neg_log_likelihood(test_rates[iTrial], testset[iTrial])
        nll_null = neg_log_likelihood(
            np.tile(
                np.nanmean(testset[iTrial], axis=(0, 1), keepdims=True),
                (testset[iTrial].shape[0], testset[iTrial].shape[1])),
            testset[iTrial],
            zero_warning=False
        )
        test_bits.append((nll_null - nll_model) / np.nansum(testset[iTrial]) / np.log(2))

    test_bits_sum.append(sum(test_bits))
    return test_bits_sum

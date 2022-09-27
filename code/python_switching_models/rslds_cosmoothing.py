# -*- coding: utf-8 -*-
"""
Created on Mon May  9 14:07:15 2022.

@author: calebsponheim
"""
import ssm
import numpy as np
import logging
logger = logging.getLogger(__name__)


def run_cosmoothing(model, ys, neuron_classification, inputs=None, cs_frac=0.8):
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
        inputs = inputs = [np.zeros((y.shape[0], model.M)) for y in ys]

    # create masks that mask out test neurons
    lls = [0] * len(np.unique(neuron_classification))
    for iFold in np.unique(neuron_classification):
        test_neur = [i for i, x in enumerate(neuron_classification) if x == iFold]
        masks = []
        for y in ys:
            mask = np.ones_like(y)
            mask[:, test_neur] *= 0
            mask = mask.astype(bool)
            masks.append(mask)

        _elbos, _q_model = model.approximate_posterior(
            ys, inputs=inputs, masks=masks,
            method="laplace_em",
            variational_posterior="structured_meanfield",
            num_iters=25, alpha=0.5)

        # compute log likelihood of heldout neurons

        for tr in range(len(ys)):
            ll = np.sum(model.emissions.log_likelihoods(ys[tr],
                                                        inputs[tr],
                                                        mask=np.invert(masks[tr]),
                                                        tag=None,
                                                        x=_q_model.mean_continuous_states[tr]))
            lls[iFold] = lls[iFold] + ll

    return np.mean(lls)


def rslds_cosmoothing(data, trial_classification, meta, bin_size,
                      num_hidden_state_override, figurepath,
                      rslds_ll_analysis, latent_dim_state_range, neuron_classification):
    """Train a Switching Linear Dynamical System."""
    # %%
    trind_train = [i for i, x in enumerate(
        trial_classification) if x == "train"]
    trind_test = [i for i, x in enumerate(
        trial_classification) if x == "test"]
    trainset = []
    testset = []

    for iTrial in range(len(trial_classification)):
        if iTrial in trind_train:
            trainset.append(np.transpose(np.array(data.spikes[iTrial])))
        elif iTrial in trind_test:
            testset.append(np.transpose(np.array(data.spikes[iTrial])))

    # %%
    observation_dimensions = trainset[0].shape[1]
    number_of_states = num_hidden_state_override

    # % rSLDS
    # Fit with Laplace EM

    model = ssm.SLDS(observation_dimensions, number_of_states, latent_dim_state_range,
                     transitions="recurrent",
                     dynamics="diagonal_gaussian",
                     emissions="poisson",
                     single_subspace=True)
    model.initialize(trainset)
    q_elbos_lem_train, q_lem_train = model.fit(trainset, method="laplace_em",
                                               variational_posterior="structured_meanfield",
                                               initialize=False, num_iters=100)
    # %%
    ys = testset

    # %%
    lls = run_cosmoothing(model, ys, neuron_classification, inputs=None, cs_frac=0.8)
    log_likelihood_emissions_sum = lls
    # %% Generating Rates for Test Trials

    return log_likelihood_emissions_sum

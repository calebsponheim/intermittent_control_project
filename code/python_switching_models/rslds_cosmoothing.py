# -*- coding: utf-8 -*-
"""
Created on Mon May  9 14:07:15 2022.

@author: calebsponheim
"""
import ssm
import numpy as np
import logging
import matplotlib.pyplot as plt
import pickle

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
            num_iters=50, alpha=0.5)

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
                      number_of_discrete_states, figurepath,
                      rslds_ll_analysis, number_of_latent_dimensions,
                      neuron_classification, folderpath_out,
                      fold_number, train_model):
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

    if train_model == 1:
        # %%
        observation_dimensions = trainset[0].shape[1]
        number_of_states = number_of_discrete_states

        # % rSLDS
        # Fit with Laplace EM

        model = ssm.SLDS(observation_dimensions, number_of_states, number_of_latent_dimensions,
                         transitions="recurrent",
                         dynamics="diagonal_gaussian",
                         emissions="poisson",
                         single_subspace=True)
        model.initialize(trainset)
        q_elbos_lem_train, q_lem_train = model.fit(trainset, method="laplace_em",
                                                   variational_posterior="structured_meanfield",
                                                   initialize=False, num_iters=50)

        # %% Pickle!
        filename = folderpath_out + 'fold_' + str(fold_number) + '_model'
        outfile = open(filename, 'wb')
        pickle.dump(model, outfile)
        outfile.close()
        # %%
        plt.figure()
        plt.plot(q_elbos_lem_train[1:], label="Laplace-EM")
        plt.legend()
        plt.xlabel("Iteration")
        plt.ylabel("ELBO")
        plt.tight_layout()
        plt.savefig(figurepath + "/training.png")

    elif train_model == 0:
        # %%

        ys = testset

        # %%
        infile = open(folderpath_out + 'fold_' + str(fold_number) + '_model', 'rb')
        model = pickle.load(infile)
        infile.close()

        lls = run_cosmoothing(model, ys, neuron_classification, inputs=None, cs_frac=0.8)
        log_likelihood_emissions_sum = lls

        return log_likelihood_emissions_sum

# -*- coding: utf-8 -*-
"""
Created on Mon July 26th 09:58:02 2021.

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import ssm
import numpy as np
import autograd.numpy.random as npr
import seaborn as sns

# import matplotlib.gridspec as gridspec
# from matplotlib.font_manager import FontProperties
# from sklearn.decomposition import PCA as PCA_sk

# npr.seed(100)


color_names = ["windows blue", "red", "amber", "faded green", "deep aqua", "fresh green",
               "indian red", "orangeish", "old rose", "azul", "barney", "blood orange",
               "cerise", "orange", "red", "salmon", "lilac"]
colors = sns.xkcd_palette(color_names)
sns.set_style("white")
sns.set_context("talk")

# %% functions from slinderman
# Helper functions for plotting results


def plot_trajectory(z, x, ax=None, ls=":"):
    zcps = np.concatenate(([0], np.where(np.diff(z))[0] + 1, [z.size]))
    if ax is None:
        fig = plt.figure(figsize=(10, 10))
        ax = fig.add_subplot(projection='3d')
        ax = fig.gca()
    for start, stop in zip(zcps[:-1], zcps[1:]):
        ax.scatter(x[start:stop + 1, 0],
                   x[start:stop + 1, 1],
                   x[start:stop + 1, 2],
                   lw=1, ls=ls,
                   color=colors[z[start] % len(colors)],
                   alpha=.6)

    return ax


def plot_trajectory_ind(z, x, figurepath):
    for iState in np.unique(z):
        fig = plt.figure(figsize=(10, 10))
        ax = plt.axes(projection='3d')
        ax = fig.gca()
        ax.plot3D(x[z == iState, 0],
                  x[z == iState, 1],
                  x[z == iState, 2],
                  lw=1, ls="-",
                  color=colors[iState % len(colors)],
                  alpha=.8)
        ax.set_xlim([-10, 10])
        ax.set_ylim([-10, 10])
        ax.set_zlim([-10, 10])
        ax.set_xlabel('$x_1$')
        ax.set_ylabel('$x_2$')
        ax.set_zlabel('$x_3$')

        plt.title("Trajectories, State " + str(iState+1))
        plt.savefig(figurepath + "/rslds/low-d_trajectories_" + str(iState+1) + ".png")
        plt.close()


def plot_most_likely_dynamics(model,
                              xlim=(-10, 10), ylim=(-10, 10), nxpts=30, nypts=30,
                              alpha=0.8, ax=None, figsize=(10, 10)):

    # K = model.K
    # assert model.D == 2
    x = np.linspace(*xlim, nxpts)
    y = np.linspace(*ylim, nypts)
    X, Y = np.meshgrid(x, y)
    xy = np.column_stack((X.ravel(), Y.ravel()))

    # Get the probability of each state at each xy location
    log_Ps = model.transitions.log_transition_matrices(
        xy, np.zeros((nxpts * nypts, 0)), np.ones_like(xy, dtype=bool), None)
    z = np.argmax(log_Ps[:, 0, :], axis=-1)
    z = np.concatenate([[z[0]], z])

    if ax is None:
        fig = plt.figure(figsize=figsize)
        ax = fig.add_subplot(111)

    for k, (A, b) in enumerate(zip(model.dynamics.As, model.dynamics.bs)):
        dxydt_m = xy.dot(A.T) + b - xy

        zk = z == k
        if zk.sum(0) > 0:
            ax.quiver(xy[zk, 0], xy[zk, 1],
                      dxydt_m[zk, 0], dxydt_m[zk, 1],
                      color=colors[k % len(colors)], alpha=alpha)

    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')

    plt.tight_layout()

    return ax


def plot_most_likely_dynamics_3(model,
                                xlim=(-10, 10), ylim=(-10, 10), zlim=(-10, 10), nxpts=15, nypts=15,
                                nzpts=15, alpha=0.3, ax=None, figsize=(20, 20)):

    # K = model.K
    # assert model.D == 2
    x = np.linspace(*xlim, nxpts)
    y = np.linspace(*ylim, nypts)
    z = np.linspace(*zlim, nzpts)
    X, Y, Z = np.meshgrid(x, y, z)
    xyz = np.column_stack((X.ravel(), Y.ravel(), Z.ravel()))

    # Get the probability of each state at each xy location
    log_Ps = model.transitions.log_transition_matrices(
        xyz, np.zeros((nxpts * nypts * nzpts, 0)), np.ones_like(xyz, dtype=bool), None)
    z_mod = np.argmax(log_Ps[:, 0, :], axis=-1)
    z_mod = np.concatenate([[z_mod[0]], z_mod])

    if ax is None:
        fig = plt.figure(figsize=figsize)
        ax = fig.add_subplot(111, projection='3d')

    for k, (A, b) in enumerate(zip(model.dynamics.As, model.dynamics.bs)):
        dxyzdt_m = xyz.dot(A.T) + b - xyz

        zk = z_mod == k
        if zk.sum(0) > 0:
            ax.quiver(xyz[zk, 0], xyz[zk, 1], xyz[zk, 2],
                      dxyzdt_m[zk, 0]*.2, dxyzdt_m[zk, 1]*.2,  dxyzdt_m[zk, 2]*.2,
                      color=colors[k % len(colors)], alpha=alpha)

    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_zlabel('$x_3$')

    plt.tight_layout()

    return ax


def plot_most_likely_dynamics_ind(model, figurepath, xlim=(-10, 10),
                                  ylim=(-10, 10), zlim=(-10, 10),
                                  nxpts=15, nypts=15, nzpts=15, alpha=0.7,
                                  ax=None, figsize=(20, 20)):

    # K = model.K
    # assert model.D == 2
    x = np.linspace(*xlim, nxpts)
    y = np.linspace(*ylim, nypts)
    z = np.linspace(*zlim, nzpts)
    X, Y, Z = np.meshgrid(x, y, z)
    xyz = np.column_stack((X.ravel(), Y.ravel(), Z.ravel()))

    # Get the probability of each state at each xy location
    log_Ps = model.transitions.log_transition_matrices(
        xyz, np.zeros((nxpts * nypts * nzpts, 0)), np.ones_like(xyz, dtype=bool), None)
    z_mod = np.argmax(log_Ps[:, 0, :], axis=-1)
    z_mod = np.concatenate([[z_mod[0]], z_mod])

    for k, (A, b) in enumerate(zip(model.dynamics.As, model.dynamics.bs)):
        dxyzdt_m = xyz.dot(A.T) + b - xyz

        zk = z_mod == k
        fig = plt.figure(figsize=figsize)
        ax = fig.add_subplot(111, projection='3d')
        ax.quiver(xyz[zk, 0], xyz[zk, 1], xyz[zk, 2],
                  dxyzdt_m[zk, 0]*.5, dxyzdt_m[zk, 1]*.5,  dxyzdt_m[zk, 2]*.5,
                  color=colors[k % len(colors)], alpha=alpha)
        ax.set_xlim([-10, 10])
        ax.set_ylim([-10, 10])
        ax.set_zlim([-10, 10])
        ax.set_xlabel('$x_1$')
        ax.set_ylabel('$x_2$')
        ax.set_zlabel('$x_3$')

        plt.title("Most Likely Dynamics, State " + str(k+1))
        plt.savefig(figurepath + "/rslds/3D_flowfield" + str(k+1) + ".png")
        plt.close()
# %%


def train_rslds(data, trial_classification, meta, bin_size, is_it_breaux,
                num_hidden_state_override, figurepath, rslds_ll_analysis, latent_dim_state_range):
    """Train a Switching Linear Dynamical System."""
    # %% Making a bin_sums that's all trials, because idk how to do cross
    # validation with this method yet
    # %%
    trind_train = [i for i, x in enumerate(
        trial_classification) if x == "train" or "model_select" or "test"]
    trainset = []

    for iTrial in range(len(trial_classification)):
        if iTrial in trind_train:
            trainset.append(np.transpose(np.array(data.spikes[iTrial])))

    bin_sums = trainset
    # %% Okay NOW we train

    # time_bins = bin_sums.shape[1]
    observation_dimensions = bin_sums[0].shape[1]
    number_of_states = num_hidden_state_override

    y = bin_sums

    sns.set_style("white")
    sns.set_context("talk")
    # %% Define number of latent dimensions using PCA

    # pca_latent = PCA_sk()
    # pca_for_latent_state = pca_latent.fit(y)
    # explained_variance = pca_for_latent_state.explained_variance_ratio_

    # cumulative_variance = np.cumsum(explained_variance)
    # num_latent_dims = sum(cumulative_variance < .5)

    if rslds_ll_analysis == 1:
        num_latent_dims = latent_dim_state_range
    elif rslds_ll_analysis == 0:
        num_latent_dims = 8

    # %% Train
        # Set the parameters of the HMM
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
                                       initialize=False, num_iters=25)
        xhat_lem = []
        zhat_lem = []
        for iTrial in range(len(y)):
            xhat_lem_temp = q_lem.mean_continuous_states[iTrial]
            xhat_lem.append(xhat_lem_temp)
            zhat_lem.append(model.most_likely_states(xhat_lem_temp, y[iTrial]))
        model_params = model.params
    # %% lds
    # model = LDS(D_obs, D_latent, emissions="poisson")
    # model.initialize(y)
    # q_elbos_lem, q_lem = model.fit(
    #     y, method="laplace_em", variational_posterior="structured_meanfield",
    #     num_iters=100, initialize=False)

    # xhat_lem = q_lem.mean_continuous_states[0]
    # # zhat_lem = model.most_likely_states(xhat_lem, y)
    # model_params = model.params

    # %% slds

    # model = ssm.SLDS(D_obs, K, D_latent, emissions="poisson")
    # model.initialize(y)
    # q_elbos_lem, q_lem = model.fit(y, method="laplace_em",
    #                                variational_posterior="structured_meanfield",
    #                                initialize=False, num_iters=50)

    # xhat_lem = q_lem.mean_continuous_states[0]
    # zhat_lem = model.most_likely_states(xhat_lem, y)
    # model_params = model.params

    # %% Plot some results
    plt.figure()
    plt.plot(q_elbos_lem[1:], label="Laplace-EM")
    plt.legend()
    plt.xlabel("Iteration")
    plt.ylabel("ELBO")
    plt.tight_layout()
    plt.savefig(figurepath + "/rslds/training.png")

    # if rslds_ll_analysis == 0:
    #     plt.figure()
    #     plot_trajectory(zhat_lem[0], xhat_lem[0], ls=":")
    #     plt.title("Inferred, Laplace-EM")
    #     plt.tight_layout()
    #     plt.savefig(figurepath + "/rslds/three_PCs.png")

    # if num_latent_dims == 3:
    #     plot_most_likely_dynamics_ind(model, figurepath)

    #     plot_trajectory_ind(zhat_lem, xhat_lem, figurepath)

    # %%
    return model, xhat_lem, y, model_params

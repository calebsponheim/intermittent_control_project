# import os
# import pickle

# from matplotlib.font_manager import FontProperties
# import matplotlib.gridspec as gridspec
import matplotlib.pyplot as plt
from ssm.util import random_rotation
import ssm
import seaborn as sns
import autograd.numpy as np
import autograd.numpy.random as npr
npr.seed(12345)

color_names = ["windows blue", "red", "amber", "faded green"]
colors = sns.xkcd_palette(color_names)
sns.set_style("white")
sns.set_context("talk")


# Global parameters
T = 10000
K = 4
D_obs = 10
D_latent = 2

# Helper functions for plotting results


def plot_trajectory(z, x, ax=None, ls="-"):
    zcps = np.concatenate(([0], np.where(np.diff(z))[0] + 1, [z.size]))
    if ax is None:
        fig = plt.figure(figsize=(4, 4))
        ax = fig.gca()
    for start, stop in zip(zcps[:-1], zcps[1:]):
        ax.plot(x[start:stop + 1, 0],
                x[start:stop + 1, 1],
                lw=1, ls=ls,
                color=colors[z[start] % len(colors)],
                alpha=1.0)

    return ax


def plot_most_likely_dynamics(model,
                              xlim=(-4, 4), ylim=(-3, 3), nxpts=30, nypts=30,
                              alpha=0.8, ax=None, figsize=(3, 3)):

    K = model.K
    assert model.D == 2
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

# Simulate the nascar data


def make_nascar_model():
    As = [random_rotation(D_latent, np.pi/24.),
          random_rotation(D_latent, np.pi/48.)]

    # Set the center points for each system
    centers = [np.array([+2.0, 0.]),
               np.array([-2.0, 0.])]
    bs = [-(A - np.eye(D_latent)).dot(center) for A, center in zip(As, centers)]

    # Add a "right" state
    As.append(np.eye(D_latent))
    bs.append(np.array([+0.1, 0.]))

    # Add a "right" state
    As.append(np.eye(D_latent))
    bs.append(np.array([-0.25, 0.]))

    # Construct multinomial regression to divvy up the space
    w1, b1 = np.array([+1.0, 0.0]), np.array([-2.0])   # x + b > 0 -> x > -b
    w2, b2 = np.array([-1.0, 0.0]), np.array([-2.0])   # -x + b > 0 -> x < b
    w3, b3 = np.array([0.0, +1.0]), np.array([0.0])    # y > 0
    w4, b4 = np.array([0.0, -1.0]), np.array([0.0])    # y < 0
    Rs = np.row_stack((100*w1, 100*w2, 10*w3, 10*w4))
    r = np.concatenate((100*b1, 100*b2, 10*b3, 10*b4))

    true_rslds = ssm.SLDS(D_obs, K, D_latent,
                          transitions="recurrent_only",
                          dynamics="diagonal_gaussian",
                          emissions="gaussian_orthog",
                          single_subspace=True)
    true_rslds.dynamics.mu_init = np.tile(np.array([[0, 1]]), (K, 1))
    true_rslds.dynamics.sigmasq_init = 1e-4 * np.ones((K, D_latent))
    true_rslds.dynamics.As = np.array(As)
    true_rslds.dynamics.bs = np.array(bs)
    true_rslds.dynamics.sigmasq = 1e-4 * np.ones((K, D_latent))

    true_rslds.transitions.Rs = Rs
    true_rslds.transitions.r = r

    true_rslds.emissions.inv_etas = np.log(1e-2) * np.ones((1, D_obs))
    return true_rslds


# Sample from the model
true_rslds = make_nascar_model()
z, x, y_train = true_rslds.sample(T=T)
z_test, x_test, y_test = true_rslds.sample(T=int((T/2)))

# Fit a robust rSLDS with its default initialization
# Fit with Laplace EM
dim_range = range(1, 10)
state_range = range(1, 5)

log_likes_emissions_sum = np.zeros([len(dim_range), len(state_range)], dtype=float)
log_likes_dynamics_sum = np.zeros([len(dim_range), len(state_range)], dtype=float)

for iDim in dim_range:
    iState = 4
    # for iState in state_range:
    rslds_lem = ssm.SLDS(D_obs, iState, iDim,
                         transitions="recurrent",
                         dynamics="diagonal_gaussian",
                         emissions="gaussian_orthog",
                         single_subspace=True)
    rslds_lem.initialize(y_train)
    q_elbos_lem_train, q_lem_train = rslds_lem.fit(y_train, method="laplace_em",
                                                   variational_posterior="structured_meanfield",
                                                   initialize=False, num_iters=100, alpha=0.0)
    xhat_lem_train = q_lem_train.mean_continuous_states[0]
    zhat_lem_train = rslds_lem.most_likely_states(xhat_lem_train, y_train)

    # Cross Validation ######
    q_elbos_lem_test, q_lem_test = rslds_lem.approximate_posterior(
        datas=y_test,
        method="laplace_em",
        variational_posterior="structured_meanfield",
        num_iters=100,
    )

    test_states = rslds_lem.most_likely_states(
        q_lem_test.mean_continuous_states[0], y_test)
    variational_mean = q_lem_test.mean_continuous_states[0]
    log_likes_emissions = rslds_lem.emissions.log_likelihoods(
        data=y_test,
        input=np.empty((np.shape(y_test)[0], 0), dtype=float),
        mask=np.ones_like(y_test, dtype=bool),
        tag=None,
        x=variational_mean
    )
    log_likes_dynamics = rslds_lem.dynamics.log_likelihoods(
        data=variational_mean,
        input=np.empty((np.shape(variational_mean)[0], 0), dtype=float),
        mask=np.ones_like(variational_mean, dtype=bool),
        tag=None
    )

    log_likes_emissions_sum[iDim-1, iState-1] = sum(log_likes_emissions)
    log_likes_dynamics_sum[iDim-1, iState-1] = sum(log_likes_dynamics)

#########################
#########################


# Plot some results
plt.figure()
plt.plot(q_elbos_lem_train[1:], label="Laplace-EM")
plt.legend()
plt.xlabel("Iteration")
plt.ylabel("ELBO")
plt.tight_layout()

plt.figure(figsize=[10, 4])
ax1 = plt.subplot(131)
plot_trajectory(z, x, ax=ax1)
plt.title("True")
ax2 = plt.subplot(132)
plot_trajectory(zhat_lem_train, xhat_lem_train, ax=ax2)
plt.title("Inferred, Laplace-EM")
plt.tight_layout()

# plt.figure(figsize=(6, 6))
# ax = plt.subplot(111)
# lim = abs(xhat_lem_train).max(axis=0) + 1
# plot_most_likely_dynamics(rslds_lem, xlim=(-lim[0], lim[0]), ylim=(-lim[1], lim[1]), ax=ax)
# plt.title("Most Likely Dynamics, Laplace-EM")

plt.show()

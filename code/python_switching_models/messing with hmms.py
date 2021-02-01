# -*- coding: utf-8 -*-
"""
Created on Thu Jan 14 16:12:03 2021

@author: calebsponheim
"""
import autograd.numpy as np
import autograd.numpy.random as npr
npr.seed(0)

import ssm
from ssm.util import find_permutation
from ssm.plots import gradient_cmap, white_to_color_cmap

import matplotlib.pyplot as plt

import seaborn as sns
sns.set_style("white")
sns.set_context("talk")

color_names = [
    "windows blue",
    "red",
    "amber",
    "faded green",
    "dusty purple",
    "orange",
    "light red",
    "slate blue"
    ]

colors = sns.xkcd_palette(color_names)
cmap = gradient_cmap(colors)

time_bins = 2000
num_states = 8
observation_dimensions = 100

# making a poisson-based model

true_hmm = ssm.HMM(num_states, observation_dimensions, observations = "poisson")

# sampling from this hmm

true_states, observations_from_sample = true_hmm.sample(time_bins)
# true_ll = true_hmm.log_probability(observations_from_sample)

# trying to plot
lim = .85 * abs(observations_from_sample).max()
XX, YY, ZZ = np.meshgrid(np.linspace(-lim, lim, 100), np.linspace(-lim, lim, 100), np.linspace(-lim, lim, 100))

data = np.column_stack((XX.ravel(), YY.ravel(), ZZ.ravel()))
input = np.zeros((data.shape[0], 0))
mask = np.ones_like(data, dtype=bool)
tag = None
# lls = true_hmm.observations.log_likelihoods(data, input, mask, tag)

#%% trying to plot observations. not helpful
fig = plt.figure(figsize=(6, 6))
ax = fig.add_subplot(111, projection='3d')

for k in range(num_states):
    # plt.contour(XX, YY, np.exp(lls[:,k]).reshape(XX.shape), cmap=white_to_color_cmap(colors[k]))
    ax.scatter(observations_from_sample[true_states==k, 0], observations_from_sample[true_states==k, 1], observations_from_sample[true_states==k, 2])
    
ax.scatter(observations_from_sample[:,0], observations_from_sample[:,1], observations_from_sample[:,2],alpha=.25)
ax.set_xlabel("$x_1$")
ax.set_ylabel("$x_2$")
ax.set_zlabel("$x_3$")



#%% Plotting states against observed states

# Plot the data and the smoothed data
lim = 1.05 * abs(observations_from_sample).max()
plt.figure(figsize=(20, 6))
plt.imshow(true_states[None,:],
           aspect="auto",
           cmap=cmap,
           vmin=0,
           vmax=len(colors)-1,
           extent=(0, time_bins, -lim, (observation_dimensions)*lim))

# Ey = true_hmm.observations.mus[true_states]
for d in range(observation_dimensions):
    plt.plot(observations_from_sample[:,d] + lim * d, '-k')
#     plt.plot(Ey[:,d] + lim * d, ':k')

plt.xlim(0, time_bins)
plt.xlabel("time")
plt.yticks(lim * np.arange(observation_dimensions), ["$x_{}$".format(d+1) for d in range(observation_dimensions)])

plt.title("Simulated data from an HMM")

plt.tight_layout()
#%% Trying to fit an HMM to this generated simulated data
data = observations_from_sample # Treat observations generated above as synthetic data.
N_iters = 50

## testing the constrained transitions class
hmm = ssm.HMM(num_states, observation_dimensions, observations="poisson")

hmm_lls = hmm.fit(observations_from_sample, method="em", num_iters=N_iters, init_method="kmeans")

plt.plot(hmm_lls, label="EM")
# plt.plot([0, N_iters], true_ll * np.ones(2), ':k', label="True")
plt.xlabel("EM Iteration")
plt.ylabel("Log Probability")
plt.legend(loc="lower right")
plt.show()

#%% find "most likely states"

most_likely_states = hmm.most_likely_states(observations_from_sample)
hmm.permute(find_permutation(true_states, most_likely_states))

#%% plotting true states versus decoded states

hmm_z = hmm.most_likely_states(data)

plt.figure(figsize=(15, 6))
plt.subplot(211)
plt.imshow(true_states[None,:], aspect="auto", cmap=cmap, vmin=0, vmax=len(colors)-1)
plt.xlim(0, time_bins)
plt.ylabel("$z_{\\mathrm{true}}$")
plt.yticks([])

plt.subplot(212)
plt.imshow(hmm_z[None,:], aspect="auto", cmap=cmap, vmin=0, vmax=len(colors)-1)
plt.xlim(0, time_bins)
plt.ylabel("$z_{\\mathrm{inferred}}$")
plt.yticks([])
plt.xlabel("time")

plt.tight_layout()

#%% transition matrices

true_transition_mat = true_hmm.transitions.transition_matrix
learned_transition_mat = hmm.transitions.transition_matrix

fig = plt.figure(figsize=(8, 4))
plt.subplot(121)
im = plt.imshow(true_transition_mat, cmap='gray')
plt.title("True Transition Matrix")

plt.subplot(122)
im = plt.imshow(learned_transition_mat, cmap='gray')
plt.title("Learned Transition Matrix")

cbar_ax = fig.add_axes([0.95, 0.15, 0.05, 0.7])
fig.colorbar(im, cax=cbar_ax)
plt.show()
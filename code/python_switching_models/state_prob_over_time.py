# -*- coding: utf-8 -*-
"""
Created on Tue Nov 16 15:02:56 2021.

@author: calebsponheim
"""
import numpy as np
import matplotlib.pyplot as plt


def state_prob_over_time(hmm_storage, bin_sums, num_states):
    """ Look I dont know if this is okay.

    Parameters.
    ----------
    hmm_storage : TYPE
        DESCRIPTION.
    bin_sums : TYPE
        DESCRIPTION.
    num_states : TYPE
        DESCRIPTION.
    Returns.
    -------
    None.

    """

    for iState in range(len(hmm_storage)):
        state_probs = hmm_storage[iState].expected_states(np.transpose(bin_sums))
        state_probs = state_probs[0]
        plt.plot((state_probs[0:200, :]))
        plt.xlabel("time (bins)")
        plt.title("State Probability")
        plt.ylabel("Probability")
        plt.show()

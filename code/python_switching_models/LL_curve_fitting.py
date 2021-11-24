# -*- coding: utf-8 -*-8
"""
Created on Wed Oct 20 14:45:00 2021.

@author: calebsponheim
"""

from scipy.optimize import curve_fit
import numpy as np
import matplotlib.pyplot as plt


def func(x, a, b, c, d):
    """Just a sigmoid."""
    output = a / (1.0 + np.exp(-c * (x - d))) + b
    return output


def LL_curve_fitting(select_ll, state_range):
    """It's just fitting a function to LL values."""
    initial_params = np.array([10000, -101900, 0.2, 1])
    select_ll = np.float64(np.array(select_ll))
    popt, pcov = curve_fit(
        func, state_range, np.transpose(select_ll), p0=initial_params
    )

    plt.plot(state_range, np.transpose(select_ll), linestyle=" ", marker="o")

    # plt.plot(
    #     state_range,
    #     func(state_range, *popt),
    #     linestyle="--",
    #     linewidth=2,
    #     color="black",
    # )

    plt.plot(
        state_range,
        func(state_range, *[10000, -101900, 0.2, 1]),
        linestyle="--",
        linewidth=2,
        color="blue",
    )

    # plt.axhline(y=-popt[2], color="r", linestyle="-")
    # plt.axhline(y=ninety_percent_threshold, color="b", linestyle="-")
    plt.xlabel("state number")
    plt.title("Model-Select Log Likelihood over state number")
    plt.ylabel("Log Probability")
    plt.show()

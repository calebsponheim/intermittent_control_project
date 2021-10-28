# -*- coding: utf-8 -*-
"""
Created on Wed Oct 20 14:45:00 2021

@author: calebsponheim
"""

from scipy.optimize import curve_fit


def f_tanh(x, a, b, c, d):
    "tanh function"
    return (a / (b + np.exp(-c * x))) - d


pars = curve_fit(f=f_tanh, xdata=state_range, ydata=select_ll)

plt.plot(state_range, np.transpose(select_ll), linestyle="-", marker="o")
plt.plot(
    state_range,
    f_tanh(state_range, *pars[0]),
    linestyle="--",
    linewidth=2,
    color="black",
)
# plt.axhline(y=max_log_likelihood_possible, color="r", linestyle="-")
# plt.axhline(y=ninety_percent_threshold, color="b", linestyle="-")
plt.xlabel("state number")
plt.title("Model-Select Log Likelihood over state number")
plt.ylabel("Log Probability")
plt.show()

# Caleb Sponheim Dissertation Documentation

**This document is meant to be presented largely in chronological format, to document my analysis efforts and share them with other interested parties.**

---
## Summary of the work so far:

### Replication Efforts

*Matlab Replication*

Using the same algorithmic "core" as Naama Kadmon Harpaz, I wrote my own code to process, format, and input the data into the non-parametric Hidden Markov Model. I also wrote code to export, format, and analyze the hidden state decoding results to decompose kinematic variables.

My initial goal was to replicate the results published in Kadmon Harpas et al (2019), using the exact data and methods and described in the paper. I also gathered my own data and attempted to replicate those results as well.

Results to add in this section:
1. AIC and Log-Likelihood results from RS / RJ
2. Center out and RTP results (respectively) with optimal states for RS and RJ, from Caleb Analysis.
3. Add same figures for 1 and 2 from the 2019 paper for comparison.
4. Breaux RTP and CO results (separate, obviously)
5. Breaux Log Likelihood and AIC results

*Python Replication*

Due to feedback from my thesis committee AND Naama, I was encouraged to explore more realistic switching models of neural activity. I spoke with Ken Latimer of the Freedman lab about this, and he recommended [Scott Linderman's models and toolbox. ](https://github.com/lindermanlab/ssm)
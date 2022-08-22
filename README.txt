This is a library for simulating SPDE evolutions and evaluating how norms of interest evolve.
It is intended to reduce initial testing time of implementations of numerical schemes for SPDE's.

The file "Manakov_Example_Converge.m" is a demo file demonstrating the implementation of two numerical schemes,
Lie-Trotter splitting
Explicit Exponential
as found in the article "Lie–Trotter Splitting for the Nonlinear Stochastic Manakov System", see:
https://link.springer.com/article/10.1007/s10915-021-01514-y
This script illustrate the mean-square convergence of these numerical schemes (in L2 and H1) as well as whether they preserve the L2 norm.
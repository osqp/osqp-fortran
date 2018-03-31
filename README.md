# Fortran interface for OSQP

[![Build Status](https://travis-ci.org/oxfordcontrol/osqp-fortran.svg?branch=master)](https://travis-ci.org/oxfordcontrol/osqp-fortran)
[![Build status](https://ci.appveyor.com/api/projects/status/ns1b88w39kute6br?svg=true)](https://ci.appveyor.com/project/bstellato/osqp-fortran)

Fortran wrapper for [OSQP](http://osqp.readthedocs.io/): the Operator Splitting QP Solver.

The OSQP (Operator Splitting Quadratic Program) solver is a numerical optimization package for solving problems in the form
```
minimize        0.5 x' P x + q' x

subject to      l <= A x <= u
```

where `x in R^n` is the optimization variable. The objective function is defined by a positive semidefinite matrix `P in S^n_+` and vector `q in R^n`. The linear constraints are defined by matrix `A in R^{m x n}` and vectors `l in R^m U {-inf}^m`, `u in R^m U {+inf}^m`.


## Documentation
The interface is documented [here](http://osqp.readthedocs.io/).

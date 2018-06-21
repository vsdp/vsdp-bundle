# VSDP <small>Verified SemiDefinite-quadratic-linear Programming</small>

VSDP is a software package that is designed for the computation of verified
results in conic programming.  It supports the constraint cone consisting of the
product of semidefinite cones, second-order cones and the nonnegative orthant.
It provides functions for computing rigorous error bounds of the true optimal
value, verified enclosures of epsilon-optimal  solutions, and verified
certificates of infeasibility.  All rounding errors due to floating-point
arithmetic are taken into account.

The software is completely written in [MATLAB](https://www.mathworks.com) /
[GNU Octave](https://www.gnu.org/software/octave) and requires the interval
toolbox [INTLAB](http://www.ti3.tuhh.de/rump/intlab).  Thus interval input is
supported as well.

The latest version of VSDP provides easy access to the conic solvers:
- [CSDP](https://projects.coin-or.org/Csdp),
- [GLPK](https://www.gnu.org/software/glpk/),
- [LINPROG](https://www.mathworks.com/help/optim/ug/linprog.html),
- [lp_solve](https://lpsolve.sourceforge.io),
- [SeDuMi](https://github.com/sqlp/sedumi),
- [SDPA](https://sdpa.sourceforge.io), and
- [SDPT3](https://github.com/sqlp/sdpt3).


## Getting Started

- Read the published version of [demovsdp.m](/demovsdp).


## Available versions

- The VSDP versions numbers reflect the release date:
  - [VSDP 2018](https://github.com/vsdp/vsdp-2018)
    - Improvements: Solver suppport, code simplification by using classdef.
  - [VSDP 2012](https://github.com/vsdp/vsdp-2012)
    - Improvements: Support of second-order cones, nonnegative orthant, and
      free variables.
  - [VSDP 2006](https://github.com/vsdp/vsdp-2006)
    - Supports the semidefinite cones only, focus on education.

## Contributors

- Christian Jansson (<jansson@tuhh.de>)
- Marko Lange (<m.lange@tuhh.de>)
- Viktor Härter
- Kai Torben Ohlhus (<kai.ohlhus@tuhh.de>)


## References

- See the [comprehensive list of references](/references).

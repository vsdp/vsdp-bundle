# VSDP &mdash; <small>Verified SemiDefinite-quadratic-linear Programming</small>

VSDP is a software package that is designed for the computation of verified
results in conic programming.  The current version of VSDP supports the
constraint cone consisting of the product of semidefinite cones, second-order
cones and the nonnegative orthant.  It provides functions for computing
rigorous error bounds of the true optimal value, verified enclosures of
ε-optimal  solutions, and verified certificates of infeasibility.  All rounding
errors due to floating point arithmetic are taken into account.

VSDP is completely written in [MATLAB](https://www.mathworks.com) /
[GNU Octave](https://www.gnu.org/software/octave).  Therefore it runs on any
system that runs  It uses
[INTLAB](http://www.ti3.tuhh.de/rump/intlab), and thus interval input data are
supported as well.



## Supported conic solvers

- [CSDP](https://projects.coin-or.org/Csdp)
- [LINPROG](https://www.mathworks.com/help/optim/ug/linprog.html)
- [GLPK](https://www.gnu.org/software/glpk/)
- [lp_solve](https://lpsolve.sourceforge.io)
- [SDPA](https://sdpa.sourceforge.io)
- [SDPT3](https://github.com/sqlp/sdpt3)
- [SeDuMi](https://github.com/sqlp/sedumi)



## Contributors

- Christian Jansson (<jansson@tuhh.de>)
- Marko Lange (<m.lange@tuhh.de>)
- Viktor Härter
- Kai Torben Ohlhus (<kai.ohlhus@tuhh.de>)


## References

See the [comprehensive list of references](https://vsdp.github.io/references).

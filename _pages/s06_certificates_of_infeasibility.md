---
title: Rigorous Certificates of Infeasibility
permalink: s06_certificates_of_infeasibility.html
---

# Rigorous Certificates of Infeasibility

The functions `vsdp.rigorous_lower_bound` and `vsdp.rigorous_upper_bound`
prove strict feasibility and compute rigorous error bounds.
For the verification of infeasibility the functions
`vsdp.check_primal_infeasible` and `vsdp.check_dual_infeasible` can be applied.
In this section we show how to use these functions.

* TOC
{:toc}

## Theorems of alternatives

Both functions are based upon a theorem of alternatives
[[Jansson2007]](s10_references.html#Jansson2007).
Such a theorem states that for two systems of equations or inequalities,
one or the other system has a solution,
but not both.
A solution of one of the systems is called a certificate of infeasibility for the other
which has no solution.

For a conic program those two theorems of alternatives are as follows:

1. Suppose that some $\tilde{y}$ satisfies
   $-A^{T}y \in \mathcal{K}^{*}$ and $b^{T}\tilde{y} > 0$.
   Then the system of primal constraints
   $Ax = b$ with $x \in \mathcal{K}$ has no solution.

2. Suppose that some $\tilde{x} \in \mathcal{K}$ satisfies
   $A\tilde{x} = 0$ and $c^{T}\tilde{x} < 0$.
   Then the system of dual constraints
   $c - A^{T}y \in \mathcal{K}^{*}$ has no solution.

The first theorem is the foundation of `vsdp.check_primal_infeasible`
and the second of `vsdp.check_dual_infeasible`.
For a proof, see [[Jansson2007]](s10_references.html#Jansson2007).

## Example: primal infeasible SOCP

We consider a slightly modified second-order cone problem
([[Ben-Tal2001]](s10_references.html#Ben-Tal2001), Example 2.4.2)

$$
\begin{array}{ll}
\text{minimize} & \begin{pmatrix} 0 & 0 & 0 \end{pmatrix} x, \\
\text{subject to}
& \begin{pmatrix} 1 & 0 & 0.5 \\ 0 & 1 & 0 \end{pmatrix}
  x = \begin{pmatrix} 0 \\ 1 \end{pmatrix}, \\
& x \in \mathbb{L}^{3},
\end{array}
$$

with its dual problem

$$
\begin{array}{ll}
\text{maximize} & \begin{pmatrix} 0 & 1 \end{pmatrix} y, \\
\text{subject to}
& \begin{pmatrix} 0 \\ 0 \\ 0 \end{pmatrix} -
  \begin{pmatrix} 1 & 0 \\ 0 & 1 \\ 0.5 & 0 \end{pmatrix}
  y \in \mathbb{L}^{3}.
\end{array}
$$

The primal problem is infeasible, while the dual problem is unbounded.
One can easily prove this fact by assuming that there exists a primal feasible point $x$.
This point has to satisfy $x_{3} = -2x_{1}$
and therefore $x_{1} \geq \sqrt{x_{2}^{2} + (-2x_{1})^{2}}$.
From the second equality constraint we get $x_{2} = 1$
yielding the contradiction $x_{1} \geq \sqrt{1 + 4x_{1}^{2}}$.
Thus, the primal problem has no feasible solution.

The set of dual feasible points is given by $y_{1} \leq 0$ and $y_{2} = -\frac{\sqrt{3}}{2}y_{1}$.
Thus the maximation of the dual problem yields $\hat{f}_{p} = +\infty$ for
$y = \alpha\begin{pmatrix} -1 & \sqrt{3}/2 \end{pmatrix}^{T}$ with $\alpha \to +\infty$.

To solve this problem using VSDP, one first has to specify the input data:


```matlab
A = [1, 0, 0.5;
     0, 1, 0];
b = [0; 1];
c = [0; 0; 0];
K.q = 3;
```

Using the approximate solver SDPT3,
we obtain a rigorous certificate of infeasibility with the routine
`vsdp.check_primal_infeasible`:


```matlab
obj = vsdp(A,b,c,K).solve ('sdpt3') ...
                   .check_primal_infeasible () ...
                   .check_dual_infeasible ();
```


     num. of constraints =  2
     dim. of socp   var  =  3,   num. of socp blk  =  1
    *******************************************************************
       SDPT3: Infeasible path-following algorithms
    *******************************************************************
     version  predcorr  gam  expon  scale_data
        NT      1      0.000   1        0
    it pstep dstep pinfeas dinfeas  gap      prim-obj      dual-obj    cputime
    -------------------------------------------------------------------
     0|0.000|0.000|1.0e+00|2.1e+00|3.7e+00| 0.000000e+00  0.000000e+00| 0:0:00| chol  1  1
     1|0.640|1.000|3.6e-01|1.0e-01|3.0e-01| 0.000000e+00  1.979648e+00| 0:0:00| chol  1  1
     2|0.066|0.638|3.4e-01|4.3e-02|2.4e+00| 0.000000e+00  2.346369e+02| 0:0:00| chol  1  1
     3|0.004|1.000|3.4e-01|1.0e-03|2.9e+04| 0.000000e+00  2.170266e+06| 0:0:00| chol  2  2
     4|0.005|1.000|3.4e-01|9.9e-05|2.1e+08| 0.000000e+00  1.165746e+10| 0:0:00| chol  2  2
     5|0.004|1.000|3.4e-01|0.0e+00|5.3e+11| 0.000000e+00  3.618635e+13| 0:0:00| chol  1  1
     6|0.002|1.000|3.4e-01|0.0e+00|2.2e+15| 0.000000e+00  1.736991e+17| 0:0:00|
      sqlp stop: primal or dual is diverging, 9.1e+16
    -------------------------------------------------------------------
     number of iterations   =  6
     Total CPU time (secs)  = 0.31
     CPU time per iteration = 0.05
     termination code       =  3
     DIMACS: 3.4e-01  0.0e+00  0.0e+00  0.0e+00  -1.0e+00  1.3e-02
    -------------------------------------------------------------------


The output of the solver is quite verbose and can be suppressed by
setting `obj.options.VERBOSE_OUTPUT` to `false`.
Important is the message of the SDPT3 solver:

> sqlp stop: primal or dual is diverging

which supports the theoretical consideration about the unboundedness of the dual problem.
As expected,
`vsdp.check_primal_infeasible` proves the infeasiblity of the primal problem


```matlab
obj.solutions.certificate_primal_infeasibility
```

    ans =
          Normal termination, 0.0 seconds.

          A certificate of primal infeasibility 'y' was found.
          The conic problem is primal infeasible.




while dual infeasibility cannot be shown:


```matlab
obj.solutions.certificate_dual_infeasibility
```

    ans =
          Normal termination, 0.0 seconds.

          NO certificate of dual infeasibility was found.




The rigorous certificate of primal infeasiblity `y` matches the theoretical considerations.
It diverges to infinite values:


```matlab
y = obj.solutions.certificate_primal_infeasibility.y
```

    intval y =
      1.0e+017 *
       -2.0060
        1.7369


and the first entry of `y` multiplied $-\sqrt{3}/2$ is almost the second entry of `y`:


```matlab
y(1) * -sqrt(3)/2
```

    intval ans =
      1.0e+017 *
        1.7372


The following check is already done by `vsdp.check_primal_infeasible`,
but for illustration we evaluate the conditions to prove primal infeasibility
from the first theorem of alternatives $-A^{T}y \in \mathcal{K}^{*}$ and $b^{T}\tilde{y} > 0$:


```matlab
z = -A' * y;
z(1) >= norm (z(2:end))  % Check z to be in the Lorentz-cone.
```

    ans = 1



```matlab
b' * y > 0
```

    ans = 1


Note that the rigorous certificate of infeasiblity is not necessarily unique.
Thus VSDP might proof a different `y`,
when used with another approximate solver.
Compare for example the certificate computed by SeDuMi:


```matlab
obj = vsdp(A,b,c,K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve ('sedumi') ...
   .check_primal_infeasible ();
y = obj.solutions.certificate_primal_infeasibility.y
```

    intval y =
       -2.3924
        1.0000



```matlab
z = -A' * y;
z(1) >= norm (z(2:end))  % Check z to be in the Lorentz-cone.
```

    ans = 1



```matlab
b' * y > 0
```

    ans = 1


which is also perfectly valid.

## Example: primal infeasible SDP

In the following we consider another conic optimization problem from
[[Jansson2006]](s10_references.html#Jansson2006).
The two SDP constraints of that problem
depend on two arbitrary fixed chosen parameters
$\delta = 0.1$ and $\varepsilon = -0.01$.

<div>
\begin{equation}
\begin{array}{ll}
\text{minimize} &
\left\langle \begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix}, X \right\rangle \\
\text{subject to}
& \left\langle \begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}, X \right\rangle
= \varepsilon, \\
& \left\langle \begin{pmatrix} 0 & 1 \\ 1 & \delta \end{pmatrix},
X \right\rangle = 1, \\
& X \in \mathbb{S}_{+}^{2}.
\end{array}
\end{equation}
</div>

The problem data is entered in the VSDP 2006 format:


```matlab
clear all;
EPSILON = -0.01;
DELTA = 0.1;
blk(1,:) = {'s'; 2};
C{1,1} = [0 0; 0 0];
A{1,1} = [1 0; 0 0];
A{2,1} = [0 1; 1 DELTA];
b = [EPSILON; 1];

obj = vsdp (blk, A, C, b);
obj.options.VERBOSE_OUTPUT = false;
```

The first constraint yields $x_1 = \varepsilon < 0$.
This is a contradiction to $X \in \mathbb{S}_{+}^{2}$,
thus the problem is primal infeasible.
The dual problem is

$$
\begin{array}{ll}
\text{maximize} & \varepsilon y_{1} + y_{2} \\
\text{subject to}
& \begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix}
-y_{1} \begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}
-y_{2} \begin{pmatrix} 0 & 1 \\ 1 & \delta \end{pmatrix}
= \begin{pmatrix} -y_{1} & -y_{2} \\ -y_{2} & -\delta y_{2} \end{pmatrix}
\in \mathbb{S}_{+}^{2}, \\
& y_{1}, y_{2} \in \mathbb{R}.
\end{array}
$$

For dual feasibility
the first principal minor of the dual constraint
must fulfill $-y_{1} \geq 0$
and the entire matrix $y_{2}(\delta y_{1} - y_{2}) \geq 0$.
The objective function goes to $+\infty$
for $y_{1} \to -\infty$ and $y_{2} = 0$.
Thus the dual problem is unbounded
and each point $\hat{y} = (y_{1}, 0)$ with $y_{1} \leq 0$
is a certificate of primal infeasibility.

To compute a rigorous certificate of primal infeasiblity using VSDP,
one can make of of the `vsdp.check_primal_infeasible`-function:


```matlab
obj = obj.solve ('sdpt3') ...
         .rigorous_upper_bound () ...
         .check_primal_infeasible () ...
         .check_dual_infeasible ()
```

    warning: rigorous_upper_bound: Conic solver could not find a solution for perturbed problem
    warning: called from
        rigorous_upper_bound>rigorous_upper_bound_infinite_bounds at line 191 column 5
        rigorous_upper_bound at line 58 column 7
    obj =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 3 variables
           m  = 2 constraints

      and cones:

         K.s = [ 2 ]

      obj.solutions.approximate:

          Solver 'sdpt3': Primal infeasible, 0.6 seconds.

            c'*x = 0.000000000000000e+00
            b'*y = 1.000000000000000e+00


      Compute a rigorous lower bound:

        'obj = obj.rigorous_lower_bound()'
      obj.solutions.rigorous_upper_bound:

          Solver 'sdpt3': Unknown, 0.7 seconds, 1 iterations.

              fU = Inf


      obj.solutions.certificate_primal_infeasibility:

          Normal termination, 0.0 seconds.

          A certificate of primal infeasibility 'y' was found.
          The conic problem is primal infeasible.


      obj.solutions.certificate_dual_infeasibility:

          Normal termination, 0.0 seconds.

          NO certificate of dual infeasibility was found.



      Detailed information:  'obj.info()'




While computing the approximate solution to this problem,
SDPT3 already detects potential primal infeasibility.
Trying to compute a rigorous upper error bound by `vsdp.rigorous_upper_bound` fails.
This emphasizes the warning at the beginning of the output
and the upper error bound is set to infinity (`fU = Inf`).

Using the approximate dual solution


```matlab
yt = obj.solutions.approximate.y
```

    yt =
      -100.007983163
        -0.000079832



the VSDP-function `vsdp.check_primal_infeasible` tries to prove
a rigorous certificate of primal infeasibility.
This is done by a rigorous evaluation of the theorem of alternatives
using interval arithmetic:


```matlab
format infsup
[~,id] = lastwarn
yy = obj.solutions.certificate_primal_infeasibility.y
```

    id = VSDP:rigorous_upper_bound:unsolveablePerturbation
    intval yy =
    [ -100.0080, -100.0079]
    [   -0.0001,   -0.0000]


According to the [theorem of alternatives](#Theorems-of-alternatives)
$\langle \tilde{y}, b \rangle$ is positive


```matlab
obj.b' * yy
```

    intval ans =
    [    0.9999,    1.0001]


and $-A^{*}\tilde{y}$ lies in the cone
of symmetric positive semidefinite matrices $\mathbb{S}_{+}^{2}$:


```matlab
-yy(1) * A{1,1} - yy(2) * A{2,1}
```

    intval ans =
    [  100.0079,  100.0080] [    0.0000,    0.0001]
    [    0.0000,    0.0001] [    0.0000,    0.0001]


It was shown,
that the problem is unbounded,
but not infeasible.
Therefore it is clear,
that VSDP cannot prove a rigorous certificate of dual infeasiblity
by `vsdp.check_dual_infeasible`:


```matlab
obj.solutions.certificate_dual_infeasibility
```

    ans =
          Normal termination, 0.0 seconds.

          NO certificate of dual infeasibility was found.




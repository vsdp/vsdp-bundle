---
title: Linear Programming
permalink: s02_linear_programming.html
---

# Linear Programming

In this section we describe how linear programming problems can be solved with VSDP.
In particular, two linear programs are considered in detail.

* TOC
{:toc}

## First example

Consider the linear program in primal standard form
$$
\begin{array}{ll}
\text{minimize}   & 2x_{2} + 3x_{4} + 5x_{5}, \\
\text{subject to} &
\begin{pmatrix}
-1 & 2 &  0 & 1 & 1 \\
 0 & 0 & -1 & 0 & 2
\end{pmatrix} x = \begin{pmatrix} 2 \\ 3 \end{pmatrix}, \\
& x \in \mathbb{R}^{5}_{+},
\end{array}
$$
with its corresponding dual problem
$$
\begin{array}{ll}
\text{maximize}   & 2 y_{1} + 3 y_{2}, \\
\text{subject to} &
z = \begin{pmatrix} 0 \\ 2 \\ 0 \\ 3 \\ 5 \end{pmatrix} -
\begin{pmatrix}
-1 &  0 \\
 2 &  0 \\
 0 & -1 \\
 1 &  0 \\
 1 &  2
\end{pmatrix} y \in \mathbb{R}^{5}_{+}.
\end{array}
$$

The unique exact optimal solution is given by
$x^{*} = (0, 0.25, 0, 0, 1.5)^{T}$,
$y^{*} = (1, 2)^{T}$
with $\hat{f}_{p} = \hat{f}_{d} = 8$.

The input data of the problem in VSDP are:


```matlab
A = [-1, 2,  0, 1, 1;
      0, 0, -1, 0, 2];
b = [2; 3];
c = [0; 2; 0; 3; 5];
K.l = 5;
```

To create a VSDP object of the linear program data above,
we call the VSDP class constructor
and do not suppress the output by a semicolon `;`.


```matlab
obj = vsdp (A, b, c, K)
```

    obj =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 5 variables
           m  = 2 constraints

      and cones:

         K.l = 5

      Compute an approximate solution:

        'obj = obj.solve()'


      Detailed information:  'obj.info()'




The output contains all relevant information about the conic problem
and includes the command `obj.solve` to proceed.

By calling the `obj.solve` method on the VSDP object `obj`,
we can compute an approximate solution `x`, `y`, and `z`,
for example by using SDPT3.
When calling `obj.solve` without any arguments,
the user is asked to choose one of the supported solvers.


```matlab
obj.solve ('sdpt3');
```


     num. of constraints =  2
     dim. of linear var  =  5
    *******************************************************************
       SDPT3: Infeasible path-following algorithms
    *******************************************************************
     version  predcorr  gam  expon  scale_data
        NT      1      0.000   1        0
    it pstep dstep pinfeas dinfeas  gap      prim-obj      dual-obj    cputime
    -------------------------------------------------------------------
     0|0.000|0.000|6.3e+00|2.6e+00|5.0e+02| 1.000000e+02  0.000000e+00| 0:0:00| chol  1  1
     1|1.000|0.867|9.5e-07|3.7e-01|8.7e+01| 4.535853e+01  2.191628e+00| 0:0:00| chol  1  1
     2|1.000|1.000|1.9e-06|3.1e-03|1.1e+01| 1.670044e+01  5.453562e+00| 0:0:00| chol  1  1
     3|0.928|1.000|1.6e-07|3.1e-04|1.1e+00| 8.503754e+00  7.407909e+00| 0:0:00| chol  1  1
     4|1.000|0.591|1.0e-07|1.5e-04|7.9e-01| 8.626424e+00  7.841794e+00| 0:0:00| chol  1  1
     5|0.971|0.984|3.0e-09|5.4e-06|2.2e-02| 8.015560e+00  7.993623e+00| 0:0:00| chol  1  1
     6|0.988|0.988|7.1e-10|3.7e-07|2.6e-04| 8.000185e+00  7.999926e+00| 0:0:00| chol  1  1
     7|0.989|0.989|1.1e-10|4.3e-09|2.9e-06| 8.000002e+00  7.999999e+00| 0:0:00| chol  1  1
     8|0.997|1.000|9.4e-13|2.2e-11|3.9e-08| 8.000000e+00  8.000000e+00| 0:0:00|
      stop: max(relative gap, infeasibilities) < 1.00e-08
    -------------------------------------------------------------------
     number of iterations   =  8
     primal objective value =  8.00000003e+00
     dual   objective value =  7.99999999e+00
     gap := trace(XZ)       = 3.88e-08
     relative gap           = 2.28e-09
     actual relative gap    = 2.27e-09
     rel. primal infeas (scaled problem)   = 9.39e-13
     rel. dual     "        "       "      = 2.19e-11
     rel. primal infeas (unscaled problem) = 0.00e+00
     rel. dual     "        "       "      = 0.00e+00
     norm(X), norm(y), norm(Z) = 1.5e+00, 2.2e+00, 3.0e+00
     norm(A), norm(b), norm(C) = 4.5e+00, 4.6e+00, 7.2e+00
     Total CPU time (secs)  = 0.49
     CPU time per iteration = 0.06
     termination code       =  0
     DIMACS: 1.1e-12  0.0e+00  2.6e-11  0.0e+00  2.3e-09  2.3e-09
    -------------------------------------------------------------------


The solver output is often quite verbose.
Especially for large problem instances it is recommended to display the solver progress.
To suppress solver messages,
the following option can be set:


```matlab
obj.options.VERBOSE_OUTPUT = false;
```

To permanently assign an approximate solver to a VSDP object,
use the following option:


```matlab
obj.options.SOLVER = 'sdpt3';
```

By simply typing the VSDP object's name, the user gets a short summary of the solution state.


```matlab
obj
```

    obj =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 5 variables
           m  = 2 constraints

      and cones:

         K.l = 5

      obj.solutions.approximate:

          Solver 'sdpt3': Normal termination, 0.8 seconds.

            c'*x = 8.000000025993693e+00
            b'*y = 7.999999987362061e+00


      Compute a rigorous lower bound:

        'obj = obj.rigorous_lower_bound()'

      Compute a rigorous upper bound:

        'obj = obj.rigorous_upper_bound()'


      Detailed information:  'obj.info()'




On success,
one can obtain the approximate `x` and `y` solutions for further processing.


```matlab
format short
x = obj.solutions.approximate.x
y = obj.solutions.approximate.y
```

    x =
       0.0000000092324
       0.2500000014452
       0.0000000040905
       0.0000000042923
       1.5000000020453

    y =
       1.00000
       2.00000



The approximate solution is close to the optimal solution
$x^{*} = (0, 0.25, 0, 0, 1.5)^{T}$, $y^{*} = (1, 2)^{T}$.

With this approximate solution, a rigorous lower bound `fL`
of the primal optimal value $\hat{f}_{p} = 8$ can be computed by calling:


```matlab
format long
obj.rigorous_lower_bound ();
fL = obj.solutions.rigorous_lower_bound.f_objective(1)
```

    fL =  7.999999987362061


Similarly,
a rigorous upper bound `fU` of the dual optimal value $\hat{f_{d}}$ can be computed by calling:


```matlab
obj.rigorous_upper_bound ();
fU = obj.solutions.rigorous_upper_bound.f_objective(2)
```

    fU =  8.000000025997929


All this information is available in the summary of the VSDP object
and must only be extracted if necessary.


```matlab
obj
```

    obj =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 5 variables
           m  = 2 constraints

      and cones:

         K.l = 5

      obj.solutions.approximate:

          Solver 'sdpt3': Normal termination, 0.8 seconds.

            c'*x = 8.000000025993693e+00
            b'*y = 7.999999987362061e+00


      obj.solutions.rigorous_lower_bound:

          Normal termination, 0.1 seconds, 0 iterations.

              fL = 7.999999987362061e+00

      obj.solutions.rigorous_upper_bound:

          Normal termination, 0.1 seconds, 0 iterations.

              fU = 8.000000025997929e+00



      Detailed information:  'obj.info()'




Despite the rigorous lower bound `fL`,
the solution object `obj.solutions.rigorous_lower_bound`
contains more information:

1. `Y` is a rigorous interval enclosure of a dual feasible near optimal solution and
2. `Zl` a lower bound of of each cone in $z = c - A^{*} y$.
   For a linear program this is a lower bound on each component of `z`.


```matlab
format short
format infsup
 Y = obj.solutions.rigorous_lower_bound.y
Zl = obj.solutions.rigorous_lower_bound.z
```

    intval Y =
    [    0.9999,    1.0000]
    [    2.0000,    2.0001]
    Zl =
       0.9999999873621
       0.0000000252759
       2.0000000042126
       2.0000000126379
       0.0000000042126



Since `Zl` is positive, the dual problem is strictly feasible,
and the rigorous interval vector `Y` contains a dual interior solution.
Here only some significant digits of this interval vector are displayed.
The upper and lower bounds of the interval `Y`
can be obtained by using the `sup` and `inf` routines of INTLAB.
For more information about the `intval` data type see
[[Rump1999]](s10_references.html#Rump1999).

The information returned by `vsdp.rigorous_upper_bound` is similar:

1. `X` is a rigorous interval enclosure of a primal feasible near optimal solution and
2. `Xl` a lower bound of of each cone in `X`.
   Again, for a linear program this is a lower bound on each component of `X`.


```matlab
X  = obj.solutions.rigorous_upper_bound.x
Xl = obj.solutions.rigorous_upper_bound.z
```

    intval X =
    [    0.0000,    0.0001]
    [    0.2500,    0.2501]
    [    0.0000,    0.0001]
    [    0.0000,    0.0001]
    [    1.5000,    1.5001]
    Xl =
       0.0000000092324
       0.2500000014474
       0.0000000040905
       0.0000000042923
       1.5000000020452



Since `Xl` is a positive vector,
`X` is contained in the positive orthant and
the primal problem is strictly feasible.

Summarizing,
we have obtained a primal dual interval solution pair with an accuracy measured by
$$
\mu(a, b) = \dfrac{a-b}{\max\{1.0, (|a| + |b|)/2\}},
$$
see [[Jansson2006]](s10_references.html#Jansson2006).


```matlab
format shorte
mu = (fU - fL) / max (1, (abs (fU) + abs(fL)) / 2)
```

    mu =    4.8295e-09


This means,
that the computed rigorous upper and lower error bounds have an accuracy
of eight to nine decimal digits.

## Second example with free variables

How a linear program with free variables can be solved with VSDP
is demonstrated by the following example with one free variable $x_{3}$:
$$
\begin{array}{ll}
\text{minimize}   & \begin{pmatrix} 1 & 1 & -0.5 \end{pmatrix} x, \\
\text{subject to}
& \begin{pmatrix} 1 & -1 & 2 \\ 1 & 1 & -1 \end{pmatrix} x
= \begin{pmatrix} 0.5 \\ 1 \end{pmatrix} \\
& x_{1}, x_{2} \in \mathbb{R}_{+}^{2}, \\
& x_{3} \in \mathbb{R}.
\end{array}
$$

The optimal solution pair of this problem is
$x^{*} = (\frac{5}{6}, 0, -\frac{1}{6})^{T}$,
$y^{*} = (\frac{1}{6}, \frac{5}{6})^{T}$
with $\hat{f}_{p} = \hat{f}_{d} = \frac{11}{12} \approx 9.166\ldots$.

When entering a conic problem the order of the variables is important:

1. free variables,
2. nonnegative variables,
3. second-order cone variables,
4. semidefinite variables.

All involved VSDP quantities,
the constraint matrix `A`,
the primal objective `c`,
the primal solution `x`,
as well as `z`,
follow this order.
In the second linear programming example,
the free variable is $x_{3}$ and the nonnegative variables are $x_{1}$ and $x_{2}$,
respectively.
Second-order cone variables and semidefinite variables are not present.

Therefore, the problem data are:


```matlab
K.f = 1;  % number of free variables
K.l = 2;  % number of nonnegative variables
A = [ 2, 1, -1;   % first column corresponds to free variable x3
     -1, 1,  1];  % second and third to bounded x1, x2
c = [-0.5; 1; 1]; % the same applies to c
b = [0.5; 1];
```

The whole VSDP computation can be done in a few lines of code:


```matlab
obj = vsdp (A, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve ('sdpt3') ...
   .rigorous_lower_bound () ...
   .rigorous_upper_bound ();
```

Yielding


```matlab
obj
```

    obj =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 3 variables
           m  = 2 constraints

      and cones:

         K.f = 1
         K.l = 2

      obj.solutions.approximate:

          Solver 'sdpt3': Normal termination, 0.7 seconds.

            c'*x = 9.166666669227741e-01
            b'*y = 9.166666662221519e-01


      obj.solutions.rigorous_lower_bound:

          Normal termination, 0.1 seconds, 0 iterations.

              fL = 9.166666662221494e-01

      obj.solutions.rigorous_upper_bound:

          Normal termination, 0.0 seconds, 0 iterations.

              fU = 9.166666669227849e-01



      Detailed information:  'obj.info()'




---
title: Semidefinite Programming
permalink: s04_semidefinite_programming.html
---

# Semidefinite Programming

* TOC
{:toc}

The primal standard form of a conic program with $n_{s}$ symmetric positive semidefinite cones
$$
\mathbb{S}^{s_{j}}_{+} := \left\{ X \in \mathbb{R}^{s_{j} \times s_{j}}
\colon\; X = X^{T},\; v^{T} X v \geq 0,\; \forall v \in \mathbb{R}^{s_{j}}
\right\},\quad j = 1,\ldots,n_{s}.
$$
is

$$
\begin{array}{lll}
\text{minimize}
& \sum_{j=1}^{n_{s}} \langle C_{j}, X_{j} \rangle & \\
\text{subject to}
& \sum_{j=1}^{n_{s}} \langle A_{ij}, X_{j} \rangle = b_{i},
& i = 1,\ldots,m, \\
& X_{j} \in \mathbb{S}^{s_{j}}_{+},
& j = 1,\ldots,n_{s},
\end{array}
$$

with symmetric $s_{j} \times s_{j}$ matrices $A_{ij}$ and $C_{j}$.
The dual problem form is

$$
\begin{array}{ll}
\text{maximize} & b^{T} y \\
\text{subject to}
& Z_{j} := C_{j} - \sum_{i=1}^{m} y_{i} A_{ij}
  \in \mathbb{S}^{s_{j}}_{+},\quad j = 1, \ldots, n_{s}.
\end{array}
$$

## First SDP-Example

We consider an example from the CSDP User's Guide
[[Borchers2017]](s10_references.html#Borchers2017):

$$
\begin{array}{lll}
\text{minimize}
& \sum_{j=1}^{3} \langle C_{j}, X_{j} \rangle & \\
\text{subject to}
& \sum_{j=1}^{3} \langle A_{ij}, X_{j} \rangle = b_{i},\quad
     i = 1,2, \\
& X_{1} \in \mathbb{S}^{2}_{+}, \\
& X_{2} \in \mathbb{S}^{3}_{+}, \\
& X_{3} \in \mathbb{S}^{2}_{+},
\end{array}
$$

where $b = \begin{pmatrix} 1 \\ 2 \end{pmatrix}$,

$$
\begin{array}{ccc}
  C^{s_{1}}_{1} = \begin{pmatrix} -2 & -1 \\ -1 & -2 \end{pmatrix},
& C^{s_{2}}_{2} =
  \begin{pmatrix} -3 & 0 & -1 \\ 0 & -2 & 0 \\ -1 & 0 & -3 \end{pmatrix},
& C^{s_{3}}_{3} = \begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix}, \\
  A^{s_{1}}_{1,1} = \begin{pmatrix} 3 & 1 \\ 1 & 3 \end{pmatrix},
& A^{s_{2}}_{1,2} =
  \begin{pmatrix} 0 & 0 & 0 \\ 0 & 0 & 0 \\ 0 & 0 & 0 \end{pmatrix},
& A^{s_{3}}_{1,3} = \begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}, \\
  A^{s_{1}}_{2,1} = \begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix},
& A^{s_{2}}_{2,2} =
  \begin{pmatrix} 3 & 0 & 1 \\ 0 & 4 & 0 \\ 1 & 0 & 5 \end{pmatrix},
& A^{s_{3}}_{2,3} = \begin{pmatrix} 0 & 0 \\ 0 & 1 \end{pmatrix}.
\end{array}
$$

In the vectorized format the corresponding coefficient matrix `At`
and the primal objective vector `c` are


```matlab
At{1} = [ 3; 1;
          1; 3;
          0; 0; 0;
          0; 0; 0;
          0; 0; 0;
          1; 0;
          0; 0 ];
At{2} = [ 0; 0;
          0; 0;
          3; 0; 1;
          0; 4; 0;
          1; 0; 5;
          0; 0;
          0; 1 ];
At = [At{:}];

b = [ 1;
      2 ];

c = [ -2; -1;
      -1; -2;
      -3;  0; -1;
       0; -2;  0;
      -1;  0; -3;
       0;  0;
       0;  0];
```

And the cone structure `K` for this problem is


```matlab
K.s = [2 3 2];
obj = vsdp (At, b, c, K);
```

Before one starts with approximately solving the SDP,
one can check for diagonal only SDP cones and convert them
to linear cones.
This is beneficial for two reasons:
Firstly,
storing linear cones requires less memory,
and secondly,
VSDP does not have to compute eigenvalues for the cone verification.


```matlab
obj = obj.analyze (true);
```

    warning: analyze: K.s(3) seems to only have diagonal elements.
    warning: called from
        analyze>pattern1 at line 72 column 7
        analyze at line 50 column 5
     --> Convert it to LP block.


When calling `vsdp.analyze` with `true`,
all possible optimization are applied.
Note that in the original example by Borchers
[[Borchers2017]](s10_references.html#Borchers2017)
the last cone was already marked as diagonal only.
This has only be changed here for the sake of demonstration.

Now we compute approximate solutions by using `vsdp.solve`
and then verified error bounds by using `vsdp.rigorous_lower_bound`
and `vsdp.rigorous_upper_bound`:


```matlab
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3') ...
   .rigorous_lower_bound() ...
   .rigorous_upper_bound()
```

    ans =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 11 variables
           m  =  2 constraints

      and cones:

         K.l = 2
         K.s = [ 2, 3 ]

      obj.solutions.approximate:

          Solver 'sdpt3': Normal termination, 0.8 seconds.

            c'*x = -2.749999966056186e+00
            b'*y = -2.750000014595577e+00


      obj.solutions.rigorous_lower_bound:

          Normal termination, 0.1 seconds, 0 iterations.

              fL = -2.750000014595577e+00

      obj.solutions.rigorous_upper_bound:

          Normal termination, 0.1 seconds, 0 iterations.

              fU = -2.749999966061940e+00



      Detailed information:  'obj.info()'




Those approximations match the true primal and dual optimal objective function value
$\hat{f}_{d} = \hat{f}_{d} = -2.75$.

To compare the approximate solution `X`, `y`, and `Z`
with the unique solution $\hat{X}$, $\hat{y}$, and $\hat{Z}$ from
[[Borchers2017]](s10_references.html#Borchers2017),
the vectorized solution quantities `x` and `z`
have to be transformed back to matrices by using `vsdp.smat`
and the appropriate scaling factor `alpha`:

$$
\hat{X} = \begin{pmatrix}
0.125 & 0.125 & & & & & \\
0.125 & 0.125 & & & & & \\
& & 2/3 & 0 & 0 & \\
& & 0 & 0 & 0 & \\
& & 0 & 0 & 0 & \\
& & & & & 0 & \\
& & & & & & 0 \\
\end{pmatrix}
$$


```matlab
format short
alpha = 1/2;  % Invert scaling by "vdsp.svec"

x  = vsdp_indexable (full (obj.solutions.approximate.x), obj);
X1 = vsdp.smat ([], x.s(1), alpha) % SDP Block 1
X2 = vsdp.smat ([], x.s(2), alpha) % SDP Block 2
X3 = x.l                           % LP  Block
```

    X1 =
       0.12500   0.12500
       0.12500   0.12500

    X2 =
       0.66668   0.00000  -0.00002
       0.00000   0.00000   0.00000
      -0.00002   0.00000   0.00000

    X3 =
       0.0000000090495
       0.0000000067871



$$
\hat{y} = \begin{pmatrix} -0.75 \\ -1 \end{pmatrix},
$$


```matlab
y = obj.solutions.approximate.y
```

    y =
      -0.75000
      -1.00000



$$
\hat{Z} = \begin{pmatrix}
0.25 & -0.25 & & & & & \\
-0.25 & 0.25 & & & & & \\
& & 0 & 0 & 0 & \\
& & 0 & 2 & 0 & \\
& & 0 & 0 & 2 & \\
& & & & & 0.75 & \\
& & & & & & 1 \\
\end{pmatrix}
$$


```matlab
alpha = 1;  % Invert scaling by "vdsp.svec"

z  = vsdp_indexable (full (obj.solutions.approximate.z), obj);
Z1 = vsdp.smat ([], z.s(1), alpha) % SDP Block 1
Z2 = vsdp.smat ([], z.s(2), alpha) % SDP Block 2
Z3 = x.l                           % LP  Block
```

    Z1 =
       0.25000  -0.25000
      -0.25000   0.25000

    Z2 =
       0.00000   0.00000   0.00000
       0.00000   2.00000   0.00000
       0.00000   0.00000   2.00000

    Z3 =
       0.0000000090495
       0.0000000067871



The computation of the rigorous lower bounds
involves the computation of the smallest eigenvalues
`Zl(j)` $= \lambda_{\min}([Z_{j}])$ for $j = 1,2,3$.


```matlab
Zl = obj.solutions.rigorous_lower_bound.z'
```

    Zl =
       0.75000   1.00000   0.00000   0.00000




```matlab
Y  = obj.solutions.rigorous_lower_bound.y
```

    intval Y =
       -0.7500
       -1.0000


Since all `Zl >= 0`
it is proven that all matrices $Z_{j}$ are in the interior of the cone $\mathcal{K}$
and `Y` is a rigorous enclosure of a dual strict feasible (near optimal) solution.

Analogous computations are performed for the rigorous upper bound.
Here lower bounds on the smallest eigenvalue of the primal solution are computed
`Xl(j)` $= \lambda_{\min}([X_{j}])$ for $j = 1,2,3$.


```matlab
Xl = obj.solutions.rigorous_upper_bound.z'
```

    Xl =
       0.0000000090495   0.0000000067871   0.0000000135747   0.0000000029910



The matrix `X` is a rigorous enclosure of a primal strict feasible (near optimal) solution
and can be restored from the vectorized quantity
`obj.solutions.rigorous_upper_bound.x` as shown for the approximate solution.
We omit the display of the interval matrix `X` for brevity.

Since all `Xl` are non-negative,
strict feasibility for the primal problem is proved.
Thus strong duality holds for this example.


```matlab
clear all
```

## Second SDP-Example

Now we consider the following example
(see [[Jansson2007a]](s10_references.html#Jansson2007a)):

$$
\begin{array}{ll}
\text{minimize} & \langle C(\delta), X \rangle \\
\text{subject to}
& \langle A_{1}, X \rangle = 1, \\
& \langle A_{2}, X \rangle = \varepsilon, \\
& \langle A_{3}, X \rangle = 0, \\
& \langle A_{4}, X \rangle = 0, \\
& X \in \mathbb{S}^{3}_{+},
\end{array}
$$

with Lagrangian dual

$$
\begin{array}{ll}
\text{maximize} & y_{1} + \varepsilon y_{2} \\
\text{subject to}
& Z(\delta) := C(\delta) - \sum_{i = 1}^{4} A_{i} y_{i}
  \in \mathbb{S}^{3}_{+}, \\
& y \in \mathbb{R}^{4},
\end{array}
$$

where


```matlab
c = @(DELTA) ...
    [  0;   1/2;    0;
      1/2; DELTA;   0;
       0;    0;   DELTA ];

At = {};
At{1} = [ 0; -1/2; 0;
        -1/2;  0;  0;
          0;   0;  0 ];
At{2} = [ 1; 0; 0;
          0; 0; 0;
          0; 0; 0 ];
At{3} = [ 0; 0; 1;
          0; 0; 0;
          1; 0; 0 ];
At{4} = [ 0; 0; 0;
          0; 0; 1;
          0; 1; 0 ];
At = [At{:}];

b = @(EPSILON) [1; EPSILON; 0; 0];

K.s = 3;
```

The linear constraints of the primal problem form imply

$$
X(\varepsilon) = \begin{pmatrix}
\varepsilon & -1 & 0 \\ -1 & X_{22} & 0 \\ 0 & 0 & X_{33}
\end{pmatrix} \in \mathbb{S}^{3}_{+}
$$

iff $X_{22} \geq 0$, $X_{33} \geq 0$, and $\varepsilon X_{22} - 1 \geq 0$.
The conic constraint of the dual form is

$$
Z(\delta) = \begin{pmatrix}
-y_{2} & \frac{1+y_{1}}{2} & -y_{3} \\
\frac{1+y_{1}}{2} & \delta & -y_{4} \\
-y_{3} & -y_{4} & \delta \end{pmatrix} \in \mathbb{S}^{3}_{+}.
$$

Hence, for
- $\varepsilon \leq 0$: the problem is **primal infeasible** $\hat{f}_{p} = +\infty$.
- $\delta < 0$: the problem is **dual infeasible** $\hat{f}_{d} = -\infty$.
- $\varepsilon = \delta = 0$: the problem is **ill-posed**
  and there is a duality gap with $\hat{f}_{p} = +\infty$ and $\hat{f}_{d} = -1$.
- $\varepsilon > 0$ and $\delta > 0$: the problem is **feasible** with
  $\hat{f}_{p} = \hat{f}_{d} = -1 + \delta / \varepsilon$.

To obtain a feasible solution,
we set $\delta = 10^{-2}$ and $\varepsilon = 2\delta$.
Thus the primal and dual optimal objective function value is
$\hat{f}_{p} = \hat{f}_{d} = -0.5$
and one can start the computations with VSDP:


```matlab
DELTA   = 1e-4;
EPSILON = 2 * DELTA;

obj = vsdp (At, b(EPSILON), c(DELTA), K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3') ...
   .rigorous_lower_bound() ...
   .rigorous_upper_bound()
```

    ans =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 6 variables
           m  = 4 constraints

      and cones:

         K.s = [ 3 ]

      obj.solutions.approximate:

          Solver 'sdpt3': Normal termination, 1.4 seconds.

            c'*x = -4.999999947476755e-01
            b'*y = -5.000000065021177e-01


      obj.solutions.rigorous_lower_bound:

          Solver 'sdpt3': Normal termination, 1.5 seconds, 1 iterations.

              fL = -5.000000146303779e-01

      obj.solutions.rigorous_upper_bound:

          Solver 'sdpt3': Normal termination, 1.9 seconds, 1 iterations.

              fU = -4.999999865227940e-01



      Detailed information:  'obj.info()'




Everything works as expected.
VSDP computes finite rigorous lower and upper bounds `fU` and `fL`.
Weak duality,
e.g. $\hat{f}_{p} \geq \hat{f}_{d}$ and `fU >= fL`,
holds for the approximate and rigorous solutions.
The accuracy of rigorous the error bounds can again be measured by


```matlab
format shorte
fL = obj.solutions.rigorous_lower_bound.f_objective(1);
fU = obj.solutions.rigorous_upper_bound.f_objective(2);
mu = (fU - fL) / max (1, (abs (fU) + abs(fL)) / 2)
```

    warning: strmatch is obsolete; use strncmp or strcmp instead
    mu =    2.8108e-08


Nevertheless,
successful termination reported by an approximate solver gives no guarantee
on the quality of the computed solution.
Only `fU` and `fL` are reliable results,
which are computed by the functions `vsdp.rigorous_lower_bound`
and `vsdp.rigorous_upper_bound`,
respectively.

To emphasize this,
one can apply SeDuMi to the same problem:


```matlab
obj.options.SOLVER = 'sedumi';
obj.solve() ...
   .rigorous_lower_bound () ...
   .rigorous_upper_bound ()
```

    ans =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 6 variables
           m  = 4 constraints

      and cones:

         K.s = [ 3 ]

      obj.solutions.approximate:

          Solver 'sedumi': Normal termination, 0.9 seconds.

            c'*x = -4.999990761443555e-01
            b'*y = -4.999968121457571e-01


      obj.solutions.rigorous_lower_bound:

          Solver 'sedumi': Normal termination, 0.7 seconds, 1 iterations.

              fL = -5.000035826169670e-01

      obj.solutions.rigorous_upper_bound:

          Solver 'sedumi': Normal termination, 0.8 seconds, 1 iterations.

              fU = -4.999953346395458e-01



      Detailed information:  'obj.info()'




SeDuMi terminates without any warning, but the approximate results are poor.
Since the approximate primal optimal objective function value is smaller than the dual one.
Weak duality is not satisfied.


```matlab
f_obj = obj.solutions.approximate.f_objective;

f_obj(1) >= f_obj(2)
```

    ans = 0


As already mentioned, weak duality holds for the rigorous error bounds by VSDP:


```matlab
fL = obj.solutions.rigorous_lower_bound.f_objective(1);
fU = obj.solutions.rigorous_upper_bound.f_objective(2);

fU >= fL
```

    ans = 1


In general the quality of the rigorous error bounds strongly depends on the computed approximate solution
and therefore on the used approximate conic solver.
For example compare the accuracy of SeDuMi below with SDPT3 above:


```matlab
format short e
acc_mu = (fU - fL) / max(1.0, (abs(fU) + abs(fL)) / 2)
```

    acc_mu =    8.2480e-06


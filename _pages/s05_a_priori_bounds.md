---
title: A Priori Bounds
permalink: s05_a_priori_bounds.html
---

# A Priori Bounds

In many practical applications the order of the magnitude of a primal or dual
optimal solution is known a priori.  This is the case in many combinatorial
optimization problems, or, for instance, in truss topology design where the
design variables such as bar volumes can be roughly bounded.  If such bounds
are available they can speed up the computation of guaranteed error bounds
for the optimal value substantially, see
[[Jansson2006]](s10_references.html#Jansson2006).

For linear programming problems the upper bound for the variable $x^{l}$
is a vector $\bar{x}$ such that $x^{l} \leq \bar{x}$.
For second-order cone programming the upper bounds for block variables
$x_{i}^{q}$ with $i = 1,\ldots,n_{q}$
can be entered as a vector of upper bounds $$\overline{\lambda}_{i}$$
of the largest eigenvalues
$$
\lambda_{\max}(x_{i}^{q}) = (x_{i}^{q})_{1} + ||(x_{i}^{q})_{:}||_{2}.
$$
Similarly, in semidefinite programs upper bounds for the primal variables
$X_{j}^{s}$ can be entered as a vector of upper bounds of the largest
eigenvalues $\lambda_{\max}(X_{j}^{s})$, $j = 1,\ldots,n_{s}$.
An upper bound $\bar{y}$ for the dual optimal solution $y$ is a vector
which is componentwise larger then $y$.
Analogously, for conic programs with free variables the upper bound
can be entered as a vector $\bar{x}$ such that $|x^{f}| \leq \bar{x}$.

As an example, we consider the
[previous SDP problem](s04_semidefinite_programming.html#Second-SDP-Example)
with an upper bound $xu = 10^{5}$ for $\lambda_{\max}(X)$.


```matlab
DELTA   = 1e-4;
EPSILON = 2 * DELTA;

c = [  0;   1/2;    0;
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

b = [1; EPSILON; 0; 0];

K.s = 3;

obj = vsdp (At, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
```

Now we compute approximate solutions by using `vsdp.solve` and then verified
error bounds by using `vsdp.rigorous_lower_bound` and `vsdp.rigorous_upper_bound`:


```matlab
xu = 1e5;
yu = 1e5 * [1 1 1 1]';

obj.solve('sedumi') ...
   .rigorous_lower_bound(xu) ...
   .rigorous_upper_bound(yu)
```

    ans =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 6 variables
           m  = 4 constraints

      and cones:

         K.s = [ 3 ]

      obj.solutions.approximate:

          Solver 'sedumi': Normal termination, 0.3 seconds.

            c'*x = -4.999990761443296e-01
            b'*y = -4.999968121450896e-01


      obj.solutions.rigorous_lower_bound:

          Normal termination, 0.0 seconds, 0 iterations.

              fL = -5.000872454579481e-01

      obj.solutions.rigorous_upper_bound:

          Normal termination, 0.0 seconds, 0 iterations.

              fU = -4.997496468063052e-01



      Detailed information:  'obj.info()'




yielding rigorous error bounds with reasonable accuracy:


```matlab
format shorte
fL = obj.solutions.rigorous_lower_bound.f_objective(1);
fU = obj.solutions.rigorous_upper_bound.f_objective(2);
mu = (fU - fL) / max (1, (abs (fU) + abs(fL)) / 2)
```

    mu =    3.3760e-04


The advantage of rigorous error bounds
computed with a priori bounds on the solution is,
that the computational effort can be neglected.

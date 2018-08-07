---
title: Linear Programming
permalink: linear_programming.html
---

# Linear Programming


In this section we describe how linear programming problems can be solved
with VSDP.  In particular, two linear programs are considered in detail.

* TOC
{:toc}


## First example

Consider the linear program in primal standard form
<div>$$\begin{array}{ll}
\text{minimize}   & 2x_{2} + 3x_{4} + 5x_{5}, \\
\text{subject to} &
\begin{pmatrix}
-1 & 2 &  0 & 1 & 1 \\
 0 & 0 & -1 & 0 & 2
\end{pmatrix} x = \begin{pmatrix} 2 \\ 3 \end{pmatrix}, \\
& x \in \mathbb{R}^{5}_{+},
\end{array}$$</div>
with its corresponding dual problem
<div>$$\begin{array}{ll}
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
\end{array}$$</div>

The unique exact optimal solution is given by
<span>$x^{*} = (0, 0.25, 0, 0, 1.5)^{T}$</span>, <span>$y^{*} = (1, 2)^{T}$</span> with
<span>$\hat{f_{p}} = \hat{f_{d}} = 8$</span>.

The input data of the problem in VSDP are

{% highlight matlab %}
A = [-1, 2,  0, 1, 1;
      0, 0, -1, 0, 2];
b = [2; 3];
c = [0; 2; 0; 3; 5];
K.l = 5;
{% endhighlight %}

To create a VSDP object of the linear program data above, we call the VSDP
class constructor and do not suppress the output.

{% highlight matlab %}
obj = vsdp (A, b, c, K)
{% endhighlight %}

{% highlight text %}
obj =
  VSDP conic programming problem in primal (P) dual (D) form:
 
       (P)  min   c'*x          (D)  max  b'*y
            s.t. At'*x = b           s.t. z := c - At*y
                     x in K               z in K^*
 
  with dimensions  [n,m] = size(At)
                    n    = 5 variables
                      m  = 2 constraints
 
        K.l = 5
 
  obj.solutions.approximate  for (P) and (D):
 
      None.  Compute with 'obj = obj.solve()'
 
  obj.solutions.rigorous_lower_bound  fL <= c'*x   for (P):
 
      None.  Compute with 'obj = obj.rigorous_lower_bound()'
 
  obj.solutions.rigorous_upper_bound  b'*y <= fU   for (D):
 
      None.  Compute with 'obj = obj.rigorous_upper_bound()'
 
  obj.solutions.certificate_primal_infeasibility:
 
      None.  Check with 'obj = obj.check_primal_infeasible()'
 
  obj.solutions.certificate_dual_infeasibility:
 
      None.  Check with 'obj = obj.check_dual_infeasible()'
 
 For more information type:  obj.info()
 
 

{% endhighlight %}

The output seems quite verbose in the beginning, but it contains all relevant
information about the possibilities of VSDP, including the commands, that
can be run to compute rigorous bounds or certificates for infeasibility.
After these computations, the results are displayed as short summary in the
same context.

By calling the `solve` method on the VSDP object `obj`, we can compute an
approximate solution `x`, `y`, `z`, for example by using SDPT3.  When calling
`solve` without any arguments, the user is asked to choose one of the
supported solvers.

{% highlight matlab %}
obj.solve ('sdpt3');
{% endhighlight %}

{% highlight text %}

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
 Total CPU time (secs)  = 0.24  
 CPU time per iteration = 0.03  
 termination code       =  0
 DIMACS: 1.1e-12  0.0e+00  2.6e-11  0.0e+00  2.3e-09  2.3e-09
-------------------------------------------------------------------

{% endhighlight %}

The solver output is often quite verbose.  Especially for large problem
instances it is recommended to display the solver progress.  To suppress
solver messages, the following option can be set:

{% highlight matlab %}
obj.options.VERBOSE_OUTPUT = false;
{% endhighlight %}

To permanently assign an approximate solver to a VSDP object, use the
following option:

{% highlight matlab %}
obj.options.SOLVER = 'sdpt3';
{% endhighlight %}

By simply typing the VSDP object's name, the user gets a short summary of
the solution state.

{% highlight matlab %}
obj
{% endhighlight %}

{% highlight text %}
obj =
  VSDP conic programming problem in primal (P) dual (D) form:
 
       (P)  min   c'*x          (D)  max  b'*y
            s.t. At'*x = b           s.t. z := c - At*y
                     x in K               z in K^*
 
  with dimensions  [n,m] = size(At)
                    n    = 5 variables
                      m  = 2 constraints
 
        K.l = 5
 
  obj.solutions.approximate  for (P) and (D):
      Solver 'sdpt3': Normal termination, 0.4 seconds.
 
        c'*x = 8.000000025993693e+00
        b'*y = 7.999999987362061e+00
 
  obj.solutions.rigorous_lower_bound  fL <= c'*x   for (P):
 
      None.  Compute with 'obj = obj.rigorous_lower_bound()'
 
  obj.solutions.rigorous_upper_bound  b'*y <= fU   for (D):
 
      None.  Compute with 'obj = obj.rigorous_upper_bound()'
 
  obj.solutions.certificate_primal_infeasibility:
 
      None.  Check with 'obj = obj.check_primal_infeasible()'
 
  obj.solutions.certificate_dual_infeasibility:
 
      None.  Check with 'obj = obj.check_dual_infeasible()'
 
 For more information type:  obj.info()
 
 

{% endhighlight %}

On success, one can obtain the approximate `x` and `y` solutions.

{% highlight matlab %}
format short
x = obj.solutions.approximate.x
y = obj.solutions.approximate.y
{% endhighlight %}

{% highlight text %}
x =
   0.0000000092324
   0.2500000014452
   0.0000000040905
   0.0000000042923
   1.5000000020453
 
y =
   1.00000
   2.00000
 

{% endhighlight %}

The approximate solution is close to the optimal solution
<span>$x^{*} = (0, 0.25, 0, 0, 1.5)^{T}$</span>, <span>$y^{*} = (1, 2)^{T}$</span>.

With this approximate solution, a rigorous lower bound `fL` of the primal
optimal value <span>$\hat{f_{p}}$</span> can be computed by calling:

{% highlight matlab %}
obj.rigorous_lower_bound ();

format long
fL = obj.solutions.rigorous_lower_bound.f_objective(1)
{% endhighlight %}

{% highlight text %}
fL =  7.999999987362061

{% endhighlight %}

Similarly, a rigorous upper bound `fU` of the dual optimal value <span>$\hat{f_{d}}$</span>
can be computed by calling:

{% highlight matlab %}
obj.rigorous_upper_bound ();

fU = obj.solutions.rigorous_upper_bound.f_objective(2)
{% endhighlight %}

{% highlight text %}
fU =  8.000000025997929

{% endhighlight %}

All this information is available in the summary of the VSDP object and must
only be extracted if necessary.

{% highlight matlab %}
obj
{% endhighlight %}

{% highlight text %}
obj =
  VSDP conic programming problem in primal (P) dual (D) form:
 
       (P)  min   c'*x          (D)  max  b'*y
            s.t. At'*x = b           s.t. z := c - At*y
                     x in K               z in K^*
 
  with dimensions  [n,m] = size(At)
                    n    = 5 variables
                      m  = 2 constraints
 
        K.l = 5
 
  obj.solutions.approximate  for (P) and (D):
      Solver 'sdpt3': Normal termination, 0.4 seconds.
 
        c'*x = 8.000000025993693e+00
        b'*y = 7.999999987362061e+00
 
  obj.solutions.rigorous_lower_bound  fL <= c'*x   for (P):
      Normal termination, 0.0 seconds, 0 iterations.
 
          fL = 7.999999987362061e+00
 
  obj.solutions.rigorous_upper_bound  b'*y <= fU   for (D):
      Normal termination, 0.0 seconds, 0 iterations.
 
          fU = 8.000000025997929e+00
 
  obj.solutions.certificate_primal_infeasibility:
 
      None.  Check with 'obj = obj.check_primal_infeasible()'
 
  obj.solutions.certificate_dual_infeasibility:
 
      None.  Check with 'obj = obj.check_dual_infeasible()'
 
 For more information type:  obj.info()
 
 

{% endhighlight %}

Despite the rigorous lower bound `fL`, the solution object
`obj.solutions.rigorous_lower_bound` contain more information:

{% highlight matlab %}
format short
format infsup
Y = obj.solutions.rigorous_lower_bound.y
{% endhighlight %}

{% highlight text %}
intval Y = 
[    0.9999,    1.0000] 
[    2.0000,    2.0001] 

{% endhighlight %}

{% highlight matlab %}
Dl = obj.solutions.rigorous_lower_bound.z
{% endhighlight %}

{% highlight text %}
Dl =
   0.9999999873621
   0.0000000252759
   2.0000000042126
   2.0000000126379
   0.0000000042126
 

{% endhighlight %}

1. `Y` is a rigorous interval enclosure of a dual feasible near optimal
  solution and
2. `Dl` a lower bound of of each cone in <span>$z = c - A^{*} y$</span>.  For a linear
  program this is a lower bound on each component of `z`.


Since `Dl` is positive, the dual problem is strictly feasible, and the
rigorous interval vector `Y` contains a dual interior solution.  Here only
some significant digits of this interval vector are displayed.  The upper
and lower bounds of the interval `Y` can be obtained by using the `sup` and
`inf` routines of INTLAB.  For more information about the `intval` data type
see [[Rump1999]](https://vsdp.github.io/references.html#Rump1999).

The information returned by `rigorous_upper_bound()` is similar:

{% highlight matlab %}
X = obj.solutions.rigorous_upper_bound.x
{% endhighlight %}

{% highlight text %}
intval X = 
[    0.0000,    0.0001] 
[    0.2500,    0.2501] 
[    0.0000,    0.0001] 
[    0.0000,    0.0001] 
[    1.5000,    1.5001] 

{% endhighlight %}

{% highlight matlab %}
Xl = obj.solutions.rigorous_upper_bound.z
{% endhighlight %}

{% highlight text %}
Xl =
   0.0000000092324
   0.2500000014474
   0.0000000040905
   0.0000000042923
   1.5000000020452
 

{% endhighlight %}

1. `X` is a rigorous interval enclosure of a primal feasible near optimal
  solution and
2. `Xl` a lower bound of of each cone in `X`.  Again, for a linear program
  this is a lower bound on each component of `X`.


Since `Xl` is a positive vector, `X` is contained in the positive orthant and
the primal problem is strictly feasible.

Summarizing, we have obtained a primal dual interval solution pair with an
accuracy measured by
<div>$$\mu(a, b) = \dfrac{a-b}{\max\{1.0, (|a| + |b|)/2\}},$$</div>
see [[Jansson2006]](https://vsdp.github.io/references.html#Jansson2006).

{% highlight matlab %}
format shorte
mu = (fU - fL) / max (1, (abs (fU) + abs(fL)) / 2)
{% endhighlight %}

{% highlight text %}
mu =    4.8295e-09

{% endhighlight %}

## Second example with free variables

How a linear program with free variables can be solved with VSDP is
demonstrated by the following example with one free variable <span>$x_{3}$</span>:
<div>$$\begin{array}{ll}
\text{minimize}   & x_{1} + x_{2} - 0.5 x_{3}, \\
\text{subject to}
& x_{1} - x_{2} + 2 x_{3} = 0.5, \\
& x_{1} + x_{2} -   x_{3} = 1, \\
& x_{1} \geq 0, \\
& x_{2} \geq 0.
\end{array}$$</div>

The optimal solution pair of this problem is
<span>$x^{*} = (\frac{5}{6}, 0, -\frac{1}{6})^{T}$</span>,
<span>$y^{*} = (\frac{1}{6}, \frac{5}{6})^{T}$</span> with
<span>$\hat{f_{p}} = \hat{f_{d}} = \frac{11}{12} \approx 9.166\ldots$</span>.

When entering a problem the order of the variables is important: Firstly free
variables, secondly nonnegative variables, thirdly second order cone
variables, and last semidefinite variables.  This order must be maintained
in the matrix `A` as well as in the primal objective `c`.  In the given
example, the free variable is <span>$x_{3}$</span>, the nonnegative variables are <span>$x_{1}$</span>,
<span>$x_{2}$</span>.  Second order cone variables and semidefinite variables are not
present.  Therefore, the problem data are

{% highlight matlab %}
K.f = 1;  % number of free variables
K.l = 2;  % number of nonnegative variables
A = [ 2, 1, -1;   % first column corresponds to free variable x3
     -1, 1,  1];  % second and third to bounded x1, x2
c = [-0.5; 1; 1]; % the same applies to c
b = [0.5; 1];
{% endhighlight %}

The whole VSDP computation can be done in a few lines of code:

{% highlight matlab %}
obj = vsdp (A, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve ('sdpt3').rigorous_lower_bound ().rigorous_upper_bound ();
{% endhighlight %}

Yielding

{% highlight matlab %}
obj
{% endhighlight %}

{% highlight text %}
obj =
  VSDP conic programming problem in primal (P) dual (D) form:
 
       (P)  min   c'*x          (D)  max  b'*y
            s.t. At'*x = b           s.t. z := c - At*y
                     x in K               z in K^*
 
  with dimensions  [n,m] = size(At)
                    n    = 3 variables
                      m  = 2 constraints
 
        K.f = 1
        K.l = 2
 
  obj.solutions.approximate  for (P) and (D):
      Solver 'sdpt3': Normal termination, 0.5 seconds.
 
        c'*x = 9.166666669227741e-01
        b'*y = 9.166666662221519e-01
 
  obj.solutions.rigorous_lower_bound  fL <= c'*x   for (P):
      Normal termination, 0.0 seconds, 0 iterations.
 
          fL = 9.166666662221494e-01
 
  obj.solutions.rigorous_upper_bound  b'*y <= fU   for (D):
      Normal termination, 0.0 seconds, 0 iterations.
 
          fU = 9.166666669227849e-01
 
  obj.solutions.certificate_primal_infeasibility:
 
      None.  Check with 'obj = obj.check_primal_infeasible()'
 
  obj.solutions.certificate_dual_infeasibility:
 
      None.  Check with 'obj = obj.check_dual_infeasible()'
 
 For more information type:  obj.info()
 
 

{% endhighlight %}


Published with GNU Octave 4.4.0

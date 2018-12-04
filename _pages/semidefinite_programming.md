---
title: Semidefinite Programming
permalink: semidefinite_programming.html
---

# Semidefinite Programming


The primal standard form of a conic program with <span>$n_{s}$</span> symmetric positive
semidefinite cones

<div>$$\mathbb{S}^{s_{j}}_{+} := \left\{ X \in \mathbb{R}^{s_{j} \times s_{j}}
\colon\; X = X^{T},\; v^{T} X v \geq 0,\; \forall v \in \mathbb{R}^{s_{j}}
\right\},\quad j = 1,\ldots,n_{s}.$$</div>

is

<div>$$\begin{array}{lll}
\text{minimize}
& \sum_{j=1}^{n_{s}} \langle C_{j}, X_{j} \rangle & \\
\text{subject to}
& \sum_{j=1}^{n_{s}} \langle A_{ij}, X_{j} \rangle = b_{i},
& i = 1,\ldots,m, \\
& X_{j} \in \mathbb{S}^{s_{j}}_{+},
& j = 1,\ldots,n_{s},
\end{array}$$</div>

with symmetric <span>$s_{j} \times s_{j}$</span> matrices <span>$A_{ij}$</span> and <span>$C_{j}$</span>.
The dual problem form is

<div>$$\begin{array}{ll}
\text{maximize} & b^{T} y \\
\text{subject to}
& Z_{j} := C_{j} - \sum_{i=1}^{m} y_{i} A_{ij}
  \in \mathbb{S}^{s_{j}}_{+},\quad j = 1, \ldots, n_{s}.
\end{array}$$</div>

* TOC
{:toc}


## A feasible SDP

We consider an example from the CSDP User's Guide
[[Borchers2017]](https://vsdp.github.io/references.html#Borchers2017):

<div>$$\begin{array}{lll}
\text{minimize}
& \sum_{j=1}^{3} \langle C_{j}, X_{j} \rangle & \\
\text{subject to}
& \sum_{j=1}^{3} \langle A_{ij}, X_{j} \rangle = b_{i},\quad
     i = 1,2, \\
& X_{1} \in \mathbb{S}^{2}_{+}, \\
& X_{2} \in \mathbb{S}^{3}_{+}, \\
& X_{3} \in \mathbb{S}^{2}_{+},
\end{array}$$</div>

where <span>$b = \begin{pmatrix} 1 \\ 2 \end{pmatrix}$</span>,

<div>$$\begin{array}{ccc}
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
\end{array}$$</div>

In the vectorized format the corresponding coefficient matrix `At` and the
primal objective vector `c` are

{% highlight matlab %}
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
{% endhighlight %}

And the cone structure `K` for this problem is

{% highlight matlab %}
K.s = [2 3 2];
{% endhighlight %}

Now we compute approximate solutions by using `solve` and then verified
error bounds by using `rigorous_lower_bound` and `rigorous_upper_bound`:

{% highlight matlab %}
obj = vsdp (At, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3') ...
   .rigorous_lower_bound() ...
   .rigorous_upper_bound();
{% endhighlight %}

Finally, we get an overview about all the performed computations:

{% highlight matlab %}
disp (obj)
{% endhighlight %}

{% highlight text %}
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 12 variables
       m  =  2 constraints
 
  and cones:
 
     K.s = [ 2, 3, 2 ]
 
  obj.solutions.approximate:
 
      Solver 'sdpt3': Normal termination, 0.9 seconds.
 
        c'*x = -2.749999966056186e+00
        b'*y = -2.750000014595577e+00
 
 
  obj.solutions.rigorous_lower_bound:
 
      Normal termination, 0.1 seconds, 0 iterations.
 
          fL = -2.750000014595577e+00
 
  obj.solutions.rigorous_upper_bound:
 
      Normal termination, 0.1 seconds, 0 iterations.
 
          fU = -2.749999966061940e+00
 
 
 
  Detailed information:  'obj.info()'
 

{% endhighlight %}

To compare the approximate solution `X`, `y`, and `Z` with
[[Borchers2017]](https://vsdp.github.io/references.html#Borchers2017) the
vectorized solution quantities `x` and `z` have to be transformed back to
matrices by using `vsdp.smat` and the appropriate scaling factor:

{% highlight matlab %}
x = full(obj.solutions.approximate.x);
X = {vsdp.smat([], x(1:3),   1/2),
     vsdp.smat([], x(4:9),   1/2),
     vsdp.smat([], x(10:12), 1/2)}
y = obj.solutions.approximate.y
z = full(obj.solutions.approximate.z);
Z = {vsdp.smat([], z(1:3),   1),
     vsdp.smat([], z(4:9),   1),
     vsdp.smat([], z(10:12), 1)}
{% endhighlight %}

{% highlight text %}
X =
{
  [1,1] =
     1.2500e-01   1.2500e-01
     1.2500e-01   1.2500e-01
  [2,1] =
     6.6668e-01   0.0000e+00  -1.6405e-05
     0.0000e+00   3.3936e-09   0.0000e+00
    -1.6405e-05   0.0000e+00   3.3936e-09
  [3,1] =
     9.0495e-09   0.0000e+00
     0.0000e+00   6.7871e-09
}
 
y =
  -7.5000e-01
  -1.0000e+00
 
Z =
{
  [1,1] =
     2.5000e-01  -2.5000e-01
    -2.5000e-01   2.5000e-01
  [2,1] =
     1.1073e-08   0.0000e+00   3.6806e-09
     0.0000e+00   2.0000e+00   0.0000e+00
     3.6806e-09   0.0000e+00   2.0000e+00
  [3,1] =
     7.5000e-01   0.0000e+00
     0.0000e+00   1.0000e+00
}
 

{% endhighlight %}

The compuation of the rigorous lower bounds involves the computation of the
smallest eigenvalues `Zl(j)=` <span>$\lambda_{\min}([Z_{j}])$</span> for <span>$j = 1,2,3$</span>.

{% highlight matlab %}
Zl = obj.solutions.rigorous_lower_bound.z'
Y  = obj.solutions.rigorous_lower_bound.y
{% endhighlight %}

{% highlight text %}
Zl =
   0.0000e+00   0.0000e+00   0.0000e+00
 
intval Y = 
[ -7.5001e-001, -7.5000e-001] 
[ -1.0001e+000, -1.0000e+000] 

{% endhighlight %}

Since all `Zl >= 0` it is proven that all matrices <span>$Z_{j}$</span> are in the
interior of the cone <span>$\mathcal{K}$</span> and `Y` is a rigorous enclosure of a dual
strict feasible (near optimal) solution.

Analogous computations are performed for the rigorous upper bound.  Here
lower bounds on the smallest eigenvalue of the primal solution are computed
`Xl(j)=` <span>$\lambda_{\min}([X_{j}])$</span> for <span>$j = 1,2,3$</span>.

{% highlight matlab %}
Xl = obj.solutions.rigorous_upper_bound.z'
{% endhighlight %}

{% highlight text %}
Xl =
   1.3575e-08   2.9910e-09   6.7871e-09
 

{% endhighlight %}

The matrix `X` is a rigorous enclosure of a primal strict feasible (near
optimal) solution and can be restored from the vectorized quantity
`obj.solutions.rigorous_upper_bound.x` as shown for the approximate solution.
We omit the dispay of the interval matrix `X` for brevity.

Since all `Xl` are positive, strict feasibility for the primal problem is
proved.  Thus strong duality holds for this example.

## An infeasible SDP

Now we consider the following example
(see [[Jansson2007a]](https://vsdp.github.io/references.html#Jansson2007a)):

<div>$$\begin{array}{ll}
\text{minimize} & \langle C(\delta), X \rangle \\
\text{subject to}
& \langle A_{1}, X \rangle = 1, \\
& \langle A_{2}, X \rangle = \varepsilon, \\
& \langle A_{3}, X \rangle = 0, \\
& \langle A_{4}, X \rangle = 0, \\
& X \in \mathbb{S}^{3}_{+},
\end{array}$$</div>

with Lagragian dual

<div>$$\begin{array}{ll}
\text{maximize} & y_{1} + \varepsilon y_{2} \\
\text{subject to}
& Z(\delta) := C(\delta) - \sum_{i = 1}^{4} A_{i} y_{i}
  \in \mathbb{S}^{3}_{+}, \\
& y \in \mathbb{R}^{4},
\end{array}$$</div>

where

{% highlight matlab %}
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
{% endhighlight %}

The linear constraints of the primal problem form imply

<div>$$X(\varepsilon) = \begin{pmatrix}
\varepsilon & -1 & 0 \\ -1 & X_{22} & 0 \\ 0 & 0 & X_{33}
\end{pmatrix} \in \mathbb{S}^{3}_{+}$$</div>

iff <span>$X_{22} \geq 0$</span>, <span>$X_{33} \geq 0$</span>, and <span>$\varepsilon X_{22} - 1 \geq 0$</span>.
The conic constraint of the dual form is

<div>$$Z(\delta) = \begin{pmatrix}
-y_{2} & \frac{1+y_{1}}{2} & -y_{3} \\
\frac{1+y_{1}}{2} & \delta & -y_{4} \\
-y_{3} & -y_{4} & \delta \end{pmatrix} \in \mathbb{S}^{3}_{+}.$$</div>

Hence, for

* <span>$\varepsilon \leq 0$</span>: the problem is primal infeasible
  <span>$\hat{f_{p}} = +\infty$</span>.
* <span>$\delta      \leq 0$</span>: the problem is dual   infeasible
  <span>$\hat{f_{d}} = -\infty$</span>.
* <span>$\varepsilon = \delta = 0$</span>: the problem is ill-posed and there is a duality
  gap with <span>$\hat{f_{p}} = +\infty$</span> and <span>$\hat{f_{d}} = -1$</span>.
* <span>$\varepsilon > 0$</span> and <span>$\delta > 0$</span>: the problem is feasible with
  <span>$\hat{f_{p}} = \hat{f_{d}} = -1 + \delta / \varepsilon$</span>.


We start with the last feasible case and expect
<span>$\hat{f_{p}} = \hat{f_{d}} = -1 + 10$</span> with.

{% highlight matlab %}
DELTA   = 10^(-3);
EPSILON = 10^(-4);
{% endhighlight %}

{% highlight matlab %}
obj = vsdp (At, b(EPSILON), c(DELTA), K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3') ...
   .rigorous_lower_bound() ...
   .rigorous_upper_bound();
{% endhighlight %}

{% highlight matlab %}
disp (obj)
{% endhighlight %}

{% highlight text %}
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 6 variables
       m  = 4 constraints
 
  and cones:
 
     K.s = [ 3 ]
 
  obj.solutions.approximate:
 
      Solver 'sdpt3': Normal termination, 1.5 seconds.
 
        c'*x = 9.000000066540730e+00
        b'*y = 8.999999966558313e+00
 
 
  obj.solutions.rigorous_lower_bound:
 
      Solver 'sdpt3': Normal termination, 1.6 seconds, 1 iterations.
 
          fL = 8.999996901810034e+00
 
  obj.solutions.rigorous_upper_bound:
 
      Solver 'sdpt3': Normal termination, 1.6 seconds, 1 iterations.
 
          fU = 9.000001108216551e+00
 
 
 
  Detailed information:  'obj.info()'
 

{% endhighlight %}

Everything as expected, we obtain finite rigorous lower and upper bounds
`fL` and `fU`.

Now we change the setting for primal infeasiblilty, what SDPT3 detects as
well:

{% highlight matlab %}
DELTA   =  10^(-3);
EPSILON = -10^(-4);
obj = vsdp (At, b(EPSILON), c(DELTA), K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3');
obj.solutions.approximate
{% endhighlight %}

{% highlight text %}
ans =
      Solver 'sdpt3': Primal infeasible, 1.6 seconds.
 
        c'*x = 1.680543452802656e+08
        b'*y = 1.000000000000000e+00
 
 

{% endhighlight %}

We can make sure by computing a rigorous lower bound

{% highlight matlab %}
obj.rigorous_lower_bound();
obj.solutions.rigorous_lower_bound
{% endhighlight %}

{% highlight text %}
ans =
      Normal termination, 0.0 seconds, 0 iterations.
 
          fL = 1.000000000000000e+00
 
 

{% endhighlight %}

The value of the return parameter `info` confirms successful termination of
the solver.  The first eight decimal digits of the primal and dual optimal
values are correct, since <span>$\hat{f}_{p} = \hat{f}_{d} = -0.5$</span>, all components
of the approximate solutions `xt` and `yt` have at least five correct decimal
digits.  Nevertheless, successful termination reported by a solver gives no
guarantee on the quality of the computed solution.

For instance, if we apply SeDuMi to the same problem we obtain:

{% highlight matlab %}
obj.solve('sedumi');
obj.solutions.approximate
{% endhighlight %}

{% highlight text %}
ans =
      Solver 'sedumi': Primal infeasible, 0.6 seconds.
 
        c'*x = 0.000000000000000e+00
        b'*y = 1.000000000000000e+00
 
 

{% endhighlight %}

SeDuMi terminates without any warning, but some results are poor.  Since the
approximate primal optimal value is smaller than the dual one, weak duality
is not satisfied. In other words, the algorithm is not backward stable for
this example.  The CSDP-solver gives similar results:

{% highlight matlab %}
obj.solve('csdp');
obj.solutions.approximate
{% endhighlight %}

{% highlight text %}
ans =
      Solver 'csdp': Primal infeasible, 0.0 seconds.
 
        c'*x = 1.150983674058844e+05
        b'*y = 9.999999999999999e-01
 
 

{% endhighlight %}

A good deal worse are the results that can be derived with older versions of
these solvers, including SDPT3 and SDPA
[[Jansson2006]](/references#Jansson2006).

Reliable results can be obtained by the functions `rigorous_lower_bound` and
`rigorous_upper_bound`.  Firstly, we consider `vsdplow` and the approximate
solver SDPT3.

{% highlight matlab %}
obj.solve('sdpt3').rigorous_lower_bound();
y = obj.solutions.rigorous_lower_bound.y
{% endhighlight %}

{% highlight text %}
intval y = 
[  1.1949e-007,  1.1950e-007] 
[ -1.0000e+004, -9.9999e+003] 
[  5.6780e-015,  5.6781e-015] 
[  3.3915e-026,  3.3916e-026] 

{% endhighlight %}

{% highlight matlab %}
dl = obj.solutions.rigorous_lower_bound.z
{% endhighlight %}

{% highlight text %}
dl =    0.0000e+00

{% endhighlight %}

the vector `y` is a rigorous interior dual <span>$\varepsilon$</span>-optimal solution
where we shall see that <span>$\varepsilon \approx 2.27 \times 10^{-8}$</span>.
The positivity of `dl` verifies that `y` contains a dual strictly feasible
solution.  In particular, strong duality holds.  By using SeDuMi similar
rigorous results are obtained.  But for the SDPA-solver we get

{% highlight matlab %}
obj.solve('sdpa').rigorous_lower_bound();
disp (obj.solutions.rigorous_lower_bound)
{% endhighlight %}

{% highlight text %}
Transposing A to match b 
Number of constraints: 4 
Number of SDP blocks: 1 
Number of LP vars: 0 
warning: rigorous_lower_bound: Conic solver could not find a solution for perturbed problem
      Solver 'sdpt3': Unknown, 1.6 seconds, 1 iterations.
 
          fL = -Inf
 

{% endhighlight %}

Thus, an infinite lower bound for the primal optimal value is obtained and
dual feasibility is not verified.  The rigorous lower bound strongly depends
on the computed approximate solution and therefore on the used approximate
conic solver.

Similarly, a verified upper bound and a rigorous enclosure of a primal
<span>$varepsilon$</span>-optimal solution can be computed by using the
`rigorous_upper_bound` function together with SDPT3:

{% highlight matlab %}
obj.solve('sdpt3').rigorous_upper_bound();
disp (obj.solutions.rigorous_upper_bound)
{% endhighlight %}

{% highlight text %}
warning: rigorous_upper_bound: Conic solver could not find a solution for perturbed problem
      Solver 'sdpt3': Unknown, 1.5 seconds, 1 iterations.
 
          fU = Inf
 

{% endhighlight %}

The output `fU` is close to the dual optimal value <span>$\hat{f}_{d} = -0.5$</span>.
The interval vector `x` contains a primal strictly feasible solution and
the variable `lb` is a lower bound for the smallest eigenvalue of `x`.
Because `lb` is positive, Slater's condition is fulfilled and strong duality
is verified once more.

Summarizing, by using SDPT3 for the considered example with parameter
<span>$\varepsilon = 10^{-4}$</span>, VSDP verified strong duality with rigorous bounds
for the optimal value
<div>$$-0.500000007 \leq \hat{f}_{p} = \hat{f}_{d} \leq -0.499999994.$$</div>

The rigorous upper and lower error bounds of the optimal value show only
modest overestimation.  Strictly primal and dual feasible solutions are
obtained.  Strong duality is verified.  Moreover, we have seen that the
quality of the rigorous results depends strongly on the quality of the
computed approximations.


Published with GNU Octave 4.4.1

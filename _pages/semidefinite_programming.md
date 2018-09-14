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
obj.solve('sdpt3');
obj.rigorous_lower_bound();
obj.rigorous_upper_bound();
{% endhighlight %}

Finally, we get an overview about all the performed computations:

{% highlight matlab %}
disp (obj)
{% endhighlight %}

{% highlight text %}
  VSDP conic programming problem in primal (P) dual (D) form:
 
       (P)  min   c'*x          (D)  max  b'*y
            s.t. At'*x = b           s.t. z := c - At*y
                     x in K               z in K^*
 
  with dimensions  [n,m] = size(At)
                    n    = 12 variables
                      m  =  2 constraints
 
        K.s = [ 2, 3, 2 ]
 
  obj.solutions.approximate  for (P) and (D):
      Solver 'sdpt3': Normal termination, 0.4 seconds.
 
        c'*x = -2.749999966056186e+00
        b'*y = -2.750000014595577e+00
 
  obj.solutions.rigorous_lower_bound  fL <= c'*x   for (P):
      Normal termination, 0.0 seconds, 0 iterations.
 
          fL = -2.750000014595577e+00
 
  obj.solutions.rigorous_upper_bound  b'*y <= fU   for (D):
      Normal termination, 0.0 seconds, 0 iterations.
 
          fU = -2.749999966061940e+00
 
  obj.solutions.certificate_primal_infeasibility:
 
      None.  Check with 'obj = obj.check_primal_infeasible()'
 
  obj.solutions.certificate_dual_infeasibility:
 
      None.  Check with 'obj = obj.check_dual_infeasible()'
 
 For more information type:  obj.info()
 

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
interior of the cone
<span>$\mathbb{S}^{2}_{+} \times \mathbb{S}^{3}_{+} \times \mathbb{S}^{2}_{+}$</span>
and `Y` is a rigorous enclosure of a dual strict feasible (near optimal)
solution.

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
& \langle A_{2}, X \rangle = \epsilon, \\
& \langle A_{3}, X \rangle = 0, \\
& \langle A_{4}, X \rangle = 0, \\
& X \in \mathbb{S}^{3}_{+},
\end{array}$$</div>

with Lagragian dual

<div>$$\begin{array}{ll}
\text{maximize} & y_{1} + \epsilon y_{2} \\
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

<div>$$X(\epsilon) = \begin{pmatrix}
\epsilon & -1 & 0 \\ -1 & X_{22} & 0 \\ 0 & 0 & X_{33}
\end{pmatrix} \in \mathbb{S}^{3}_{+}$$</div>

iff <span>$X_{22} \geq 0$</span>, <span>$X_{33} \geq 0$</span>, and <span>$\epsilon X_{22} - 1 \geq 0$</span>.
The conic constraint of the dual form is

<div>$$Z(\delta) = \begin{pmatrix}
-y_{2} & \frac{1+y_{1}}{2} & -y_{3} \\
\frac{1+y_{1}}{2} & \delta & -y_{4} \\
-y_{3} & -y_{4} & \delta \end{pmatrix} \in \mathbb{S}^{3}_{+}.$$</div>

Hence, for

* <span>$\epsilon \leq 0$</span>: the problem is primal infeasible <span>$\hat{f_{p}} = +\infty$</span>.
* <span>$\delta   \leq 0$</span>: the problem is dual   infeasible <span>$\hat{f_{d}} = -\infty$</span>.
* <span>$\epsilon = \delta = 0$</span>: the problem is ill-posed and there is a duality
  gap with <span>$\hat{f_{p}} = +\infty$</span> and <span>$\hat{f_{d}} = -1$</span>.
* <span>$\epsilon > 0$</span> and <span>$\delta > 0$</span>: the problem is feasible with
  <span>$\hat{f_{p}} = \hat{f_{d}} = -1 + \delta / \epsilon$</span>.


We start with the last feasible case and expect
<span>$\hat{f_{p}} = \hat{f_{d}} = -1 + 10$</span> with.

{% highlight matlab %}
DELTA   = 10^(-3);
EPSILON = 10^(-4);
{% endhighlight %}

{% highlight matlab %}
obj = vsdp (At, b(EPSILON), c(DELTA), K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3');
obj.rigorous_lower_bound();
obj.rigorous_upper_bound();
{% endhighlight %}

{% highlight matlab %}
disp (obj)
{% endhighlight %}

{% highlight text %}
  VSDP conic programming problem in primal (P) dual (D) form:
 
       (P)  min   c'*x          (D)  max  b'*y
            s.t. At'*x = b           s.t. z := c - At*y
                     x in K               z in K^*
 
  with dimensions  [n,m] = size(At)
                    n    = 6 variables
                      m  = 4 constraints
 
        K.s = [ 3 ]
 
  obj.solutions.approximate  for (P) and (D):
      Solver 'sdpt3': Normal termination, 0.6 seconds.
 
        c'*x = 9.000000066540730e+00
        b'*y = 8.999999966558313e+00
 
  obj.solutions.rigorous_lower_bound  fL <= c'*x   for (P):
      Solver 'sdpt3': Normal termination, 0.6 seconds, 1 iterations.
 
          fL = 8.999996901810034e+00
 
  obj.solutions.rigorous_upper_bound  b'*y <= fU   for (D):
      Solver 'sdpt3': Normal termination, 0.7 seconds, 1 iterations.
 
          fU = 9.000001108216551e+00
 
  obj.solutions.certificate_primal_infeasibility:
 
      None.  Check with 'obj = obj.check_primal_infeasible()'
 
  obj.solutions.certificate_dual_infeasibility:
 
      None.  Check with 'obj = obj.check_dual_infeasible()'
 
 For more information type:  obj.info()
 

{% endhighlight %}

Nothing bad happened, as expected.

Now we change the setting for primal infeasiblilty, what SDPT3 detects as
well:

{% highlight matlab %}
DELTA   = -10^(-3);
EPSILON = -10^(-4);
obj = vsdp (At, b(EPSILON), c(DELTA), K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3');
obj.check_primal_infeasible();
disp (obj)
{% endhighlight %}

{% highlight text %}
  VSDP conic programming problem in primal (P) dual (D) form:
 
       (P)  min   c'*x          (D)  max  b'*y
            s.t. At'*x = b           s.t. z := c - At*y
                     x in K               z in K^*
 
  with dimensions  [n,m] = size(At)
                    n    = 6 variables
                      m  = 4 constraints
 
        K.s = [ 3 ]
 
  obj.solutions.approximate  for (P) and (D):
      Solver 'sdpt3': Primal infeasible, 0.6 seconds.
 
        c'*x = -1.148631841490051e+10
        b'*y = 9.999999999999999e-01
 
  obj.solutions.rigorous_lower_bound  fL <= c'*x   for (P):
 
      None.  Compute with 'obj = obj.rigorous_lower_bound()'
 
  obj.solutions.rigorous_upper_bound  b'*y <= fU   for (D):
 
      None.  Compute with 'obj = obj.rigorous_upper_bound()'
 
  obj.solutions.certificate_primal_infeasibility:
      Normal termination, 0.0 seconds.
 
      NO certificate of primal infeasibility was found.
 
  obj.solutions.certificate_dual_infeasibility:
 
      None.  Check with 'obj = obj.check_dual_infeasible()'
 
 For more information type:  obj.info()
 

{% endhighlight %}

The value of the return parameter `info` confirms successful termination of
the solver.  The first eight decimal digits of the primal and dual optimal
values are correct, since <span>$\hat{f}_{p} = \hat{f}_{d} = -0.5$</span>, all components
of the approximate solutions `xt` and `yt` have at least five correct decimal
digits.  Nevertheless, successful termination reported by a solver gives no
guarantee on the quality of the computed solution.

For instance, if we apply SeDuMi to the same problem we obtain:

{% highlight matlab %}
vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity
{% endhighlight %}

{% highlight text %}
error: 'vsdpinit' undefined near line 1 column 1
	in:


vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity

{% endhighlight %}

SeDuMi terminates without any warning, but some results are poor.  Since the
approximate primal optimal value is smaller than the dual one, weak duality
is not satisfied. In other words, the algorithm is not backward stable for
this example.  The CSDP-solver gives similar results:

{% highlight matlab %}
vsdpinit('sdpt3'); %TODO: csdp
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity
{% endhighlight %}

{% highlight text %}
error: 'vsdpinit' undefined near line 1 column 1
	in:


vsdpinit('sdpt3'); %TODO: csdp
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity

{% endhighlight %}

A good deal worse are the results that can be derived with older versions of
these solvers, including SDPT3 and SDPA
[[Jansson2006]](/references#Jansson2006).

Reliable results can be obtained by the functions `vsdplow` and `vsdpup`.
Firstly, we consider `vsdplow` and the approximate solver SDPT3.

{% highlight matlab %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'vsdpinit' undefined near line 1 column 1
	in:


vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)

{% endhighlight %}

the vector `y` is a rigorous interior dual <span>$??$</span>-optimal solution where we shall
see that <span>$?? \approx 2.27 \times 10^{-8}$</span>.  The positivity of `dl` verifies
that `y` contains a dual strictly feasible solution.  In particular, strong
duality holds.  By using SeDuMi similar rigorous results are obtained.  But
for the SDPA-solver we get

{% highlight matlab %}
vsdpinit('sdpa');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'vsdpinit' undefined near line 1 column 1
	in:


vsdpinit('sdpa');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)

{% endhighlight %}

Thus, an infinite lower bound for the primal optimal value is obtained and
dual feasibility is not verified.  The rigorous lower bound strongly depends
on the computed approximate solution and therefore on the used approximate
conic solver.

Similarly, a verified upper bound and a rigorous enclosure of a primal
<span>$??$</span>-optimal solution can be computed by using the `vsdpup` function
together with SDPT3:

{% highlight matlab %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'vsdpinit' undefined near line 1 column 1
	in:


vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)

{% endhighlight %}

The output `fU` is close to the dual optimal value <span>$\hat{f}_{d} = -0.5$</span>.
The interval vector `x` contains a primal strictly feasible solution, see
\eqref{OptSolSDPExp}, and the variable `lb` is a lower bound for the smallest
eigenvalue of `x`.  Because `lb` is positive, Slater's condition is fulfilled
and strong duality is verified once more.

Summarizing, by using SDPT3 for the considered example with parameter
<span>$?? = 10^{-4}$</span>, VSDP verified strong duality with rigorous bounds for the
optimal value
<span>$$</span>
-0.500000007 \leq \hat{f}_{p} = \hat{f}_{d} \leq -0.499999994.
<span>$$</span>

The rigorous upper and lower error bounds of the optimal value show only
modest overestimation.  Strictly primal and dual feasible solutions are
obtained.  Strong duality is verified.  Moreover, we have seen that the
quality of the rigorous results depends strongly on the quality of the
computed approximations.


Published with GNU Octave 4.4.1

---
title: VSDP -- Verified SemiDefinite-quadratic-linear Programming
permalink: vsdpdemo.html
---

VSDP is a software package that is designed for the computation of verified
results in conic programming.  The current version of VSDP supports the
constraint cone consisting of the product of semidefinite cones, second-order
cones and the nonnegative orthant.  It provides functions for computing
rigorous error bounds of the true optimal value, verified enclosures of
ε-optimal solutions, and verified certificates of infeasibility.  All rounding
errors due to floating point arithmetic are taken into account.

* TOC
{:toc}


# Introduction

The extraordinary success and extensive growth of conic programming,
especially of semidefinite programming, is due to the polynomial time
solvability by interior point methods and the large amount of practical
applications.  Sometimes conic programming solvers fail to find a satisfactory
approximation.  Occasionally, they state that the problem is infeasible
although it contains feasible solutions, or vice versa, see
[[Jansson2007a]](/references#Jansson2007a).  Verified error bounds, also called
rigorous error bounds, means that, in the presence of rounding errors due to
floating point arithmetic, the computed bounds are claimed to be valid with
mathematical certainty.  In other words, all rounding errors are taken into
consideration.  The major task of VSDP is to obtain a guaranteed accuracy by
postprocessing the approximations produced by conic solvers.  In our tests on
255 problems from different test libraries it turned out that the computed
error bounds and enclosures depend heavily on the quality of the approximate
solutions produced by the conic solvers.  In particular, if the conic solver
provides poor approximations, VSDP cannot compute satisfactory bounds.
However, in this case the user is warned that possibly something went wrong,
or needs further attention.

Computational errors fall into three classes:

1. Intentional errors, like idealized models or discretization,
2. Unavoidable errors like uncertainties in parameters, and
3. Unintentional bugs and blunders in software and hardware.


VSDP controls rounding errors rigorously.  Please contact us, if you discover
any unintentional bugs [jansson@tuhh.de](mailto:jansson@tuhh.de).  In the
latter case the version numbers of the used software together with an
appropriate M-file should be provided.  Any suggestions, comments, and
criticisms are welcome.  Many thanks in advance.

For theoretical details of the implemented algorithms in VSDP we refer to
[[Jansson2004]](/references#Jansson2004),
[[Jansson2007]](/references#Jansson2007),
[[Jansson2009]](/references#Jansson2009), and
[[Jansson2007a]](/references#Jansson2007a).
See [[Rump2010]](/references#Rump2010) for verified results for
other problems, such as nonlinear systems, eigenvalue problems or differential
equations.  The main differences to the first version of VSDP
([[Jansson2006]](/references#Jansson2006)) are

1. the possibility to solve additional linear and second order cone
  programming problems,
2. the extra robustness due to the ability to handle free variables, and
3. the easy access to several conic solvers.


# Installation

To run VSDP, the following requirements have to be fulfilled:

* A recent version of [http://www.mathworks.com/products/matlab/](http://www.mathworks.com/products/matlab/) MATLAB or
  [GNU Octave](http://www.octave.org/) must be installed.
* The interval toolbox [INTLAB](http://www.ti3.tu-harburg.de/rump/intlab/) is
  required.
* At least one of the following approximate solvers has to be installed:
  [SDPT3](http://www.math.nus.edu.sg/~mattohkc/sdpt3.html),
  [SeDuMi](http://sedumi.ie.lehigh.edu/),
  [CSDP](https://projects.coin-or.org/Csdp/),
  [SDPA](http://sdpa.sf.net/),
  (LP only) [LPSOLVE](http://lpsolve.sf.net/), or
  (LP only) [LINPROG](https://www.mathworks.com/help/optim/ug/linprog.html).


The most recent version of VSDP 2012 and this manual are available on
[GitHub](https://github.com/siko1056/vsdp-2012-ng/).  Legacy versions of VSDP
are available from [http://www.ti3.tu-harburg.de/jansson/vsdp/](http://www.ti3.tu-harburg.de/jansson/vsdp/).

Once you downloaded the zip file, extract its contents to the directory where
you want to install VSDP.

After the files have been extracted, call the initialization function
`vsdpinit` to add the necessary search paths.  If all requirements are
fulfilled and the necessary search paths are set, VSDP is fully functional.

# The Conic Programming Problem

Let $\mathbb{R}^{n}_{+}$ denote the nonnegative orthant, and let
$
\mathbb{L}^{n} := \{x \in \mathbb{R}^{n} \colon x_{1} \geq |`x_{2:n}`|_{2}\},
$
be the Lorentz cone.  We denote by $\langle c, x \rangle := c^{T} x$ the
usual Euclidean inner product of vectors in $\mathbb{R}^{n}$.

The set
$$
\label{sdpCone}
\mathbb{S}^{n}_{+} := \left\{ X \in \mathbb{R}^{n \times n} \colon
X = X^{T}, v^{T} X v \geq 0, \forall v \in \mathbb{R}^{n} \right\},
$$
denotes the cone of symmetric positive semidefinite $n \times n$ matrices.
For symmetric matrices $X$, $Y$ the inner product is given by
$$
\label{innerProdMatr}
\langle X,Y \rangle := \text{trace}(XY).
$$

Let $A^{f}$ and $A^{l}$ be a $m \times n_{f}$ and a $m \times n_{l}$ matrix,
respectively, and let $A_{i}^{q}$ be $m \times q_{i}$ matrices for
$i = 1,\ldots,n_{q}$.  Let $x^{f} \in \mathbb{R}^{n_{f}}$,
$x^{l} \in \mathbb{R}^{n_{l}}$, $x_{i}^{q} \in \mathbb{R}^{q_i}$, and
$b \in \mathbb{R}^{m}$.  Moreover, let $A_{1,j}^{s}, \ldots, A_{m,j}^{s}$,
$C_{j}^{s}$, $X_{j}^{s}$ be symmetric $(s_{j} \times s_{j})$ matrices for
$j = 1, \ldots, n_{s}$.

Now we can define the conic semidefinite-quadratic-linear programming
problem in primal standard form:
$$
\begin{equation}
\begin{aligned}
\hat{f}_{p} := \min\quad
&amp; \langle c^{f}, x^{f} \rangle + \langle c^{l}, x^{l} \rangle +
  \sum_{i=1}^{n_{q}} \langle c_{i}^{q}, x_{i}^{q} \rangle +
  \sum_{j=1}^{n_{s}} \langle C_{j}^{s}, X_{j}^{s} \rangle \\
\text{s.t.}\quad
&amp; A^{f} x^{f} + A^{l} x^{l} + \sum_{i=1}^{n_{q}} A_{i}^{q} x_{i}^{q} +
  \sum_{j=1}^{n_{s}}\mathcal{A}_{j}^{s}(X_{j}^{s}) = b \\
&amp; \begin{aligned}
  x^{f}     &amp;\in \mathbb{R}^{n_{f}},
            &amp; &amp;\text{"free variables"} \\
  x^{l}     &amp;\in \mathbb{R}^{n_{l}}_{+},
            &amp; &amp;\text{"nonnegative variables"} \\
  x_{i}^{q} &amp;\in \mathbb{L}^{q_i},\; i = 1, \ldots, n_{q},
            &amp; &amp;\text{"SOCP variables"} \\
  X_{j}^{s} &amp;\in \mathbb{S}^{s_{j}}_{+},\; j = 1, \ldots, n_{s},
            &amp; &amp;\text{"SDP variables"}.
  \end{aligned} \\
\end{aligned}
\label{stdPrim}
\end{equation}
$$

Here, the linear operator
$$
\label{linOpAij}
\mathcal{A}_{j}^{s}(X_{j}^{s}) := (\langle A_{1,j}^{s}, X_{j}^{s} \rangle,
\ldots, \langle A_{m,j}^{s}, X_{j}^{s} \rangle)^{T},
$$
maps the symmetric matrices $X_{j}^{s}$ to $\mathbb{R}^{m}$.

By definition the vector $x^{f}$ contains all unconstrained or free
variables, whereas all other variables are bounded by conic constraints.
In several applications some solvers (for example SDPA or CSDP) require that
free variables are converted into the difference of nonnegative variables.
Besides the major disadvantage that this transformation is numerical
unstable, it also increases the number of variables of the particular
problems.  In VSDP free variables can be handled in a numerical stable
manner, as described in a later section.

The objective function is a linear function and all equality constraints are
linear, and thus conic programming is an extension of linear programming with
additional conic constraints.

The adjoint operator $(\mathcal{A}_{j}^{s})^{*}$ of the linear operator
$\mathcal{A}_{j}^{s}$ is
$$(\mathcal{A}_{j}^{s})^{*} y := \sum_{k=1}^{n_{s}} A_{k,j}^{s} y_{k}.$$

The dual problem associated with the primal problem \eqref{stdPrim} is
$$
\begin{equation}
\begin{aligned}
\hat{f}_{d} := \max\quad
&amp; b^{T} y \\
\text{s.t.}\quad
&amp; (A^{f})^{T} y + z^{f} = c^{f},
&amp; &amp; z^{f} \in \mathbb{R}^{n_{f}}, \quad z^{f} = 0, \\
&amp; (A^{l})^{T} y + z^{l} = c^{l},
&amp; &amp; z^{l} \in \mathbb{R}^{n_{l}}_{+}, \\
&amp; (A_{i}^{q})^{T} y + z_{i}^{q} = c_{i}^{q},
&amp; &amp; z_{i}^{q} \in \mathbb{L}^{q_i}, \quad i = 1, \ldots, n_{q}, \\
&amp; (\mathcal{A}_{j}^{s})^{*} y + Z_{j}^{s} = C_{j}^{s},
&amp; &amp; Z_{j}^{s} \in \mathbb{S}^{s_{j}}_{+}, \quad j = 1, \ldots, n_{s}.
\end{aligned}
\label{StdDual}
\end{equation}
$$

Occasionally, it is useful to represent the conic programming problem in a
more compact form by using the vectorization operator \eqref{vec}.  For any
quadratic matrix $X$ this operator is defined by
$$
\label{vec}
x = \operatorname{vec}(X) = (X_{11}, \ldots, X_{n1},
                             X_{12}, \ldots, X_{n2}, \ldots,
                             X_{1n}, \ldots, X_{nn})^{T}.
$$

The inverse operation is denoted by $\operatorname{mat}(x)$ such that
$\operatorname{mat}(\operatorname{vec}(X)) = X$.

We condense the above quantities as follows:
$$
\begin{equation}
\begin{aligned}
x^{s} &amp;:= (\operatorname{vec}(X_{1}^{s}); \ldots;
           \operatorname{vec}(X_{n_{s}}^{s})), &amp;
c^{s} &amp;:= (\operatorname{vec}(C_{1}^{s}); \ldots;
           \operatorname{vec}(C_{n_{s}}^{s})), \\
x^{q} &amp;:= (x_{1}^{q}; \ldots; x_{n_{q}}^{q}), &amp;
c^{q} &amp;:= (c_{1}^{q}; \ldots; c_{n_{q}}^{q}), \\
x     &amp;:= (x^{f}; x^{l}; x^{q}; x^{s}), &amp;
c     &amp;:= (c^{f}; c^{l}; c^{q}; c^{s}).
\end{aligned}
\label{condensedX}
\end{equation}
$$

Here $c^{q}$ and $x^{q}$ consist of $\bar{q} = \sum_{i=1}^{n_{q}} q_i$
components, and $c^{s}$, $x^{s}$ are vectors of length
$\bar{s} = \sum_{j=1}^{n_{s}} s_{j}^{2}$.  The total length of $x$ and $c$
is equal to $n = n_{f} + n_{l} + \bar{q} + \bar{s}$.  As in the syntax of
Matlab the separating column denotes the vertical concatenation of the
corresponding vectors.

The matrices describing the linear equations are condensed as follows:
$$
\begin{equation}
\begin{aligned}
A^{s} &amp;= (A_{1}^{s}, \ldots, A_{n_{s}}^{s}),
         \text{ where } A_{j}^{s} =
         (\text{vec}(A_{1,j}^{s}), \ldots, \text{vec}(A_{m,j}^{s}))^{T}, \\
A^{q} &amp;= (A_{1}^{q}, \ldots, A_{n_{q}}^{q}), \\
A     &amp;= (A^{f}, A^{l}, A^{q}, A^{s}).
\end{aligned}
\label{condensedA}
\end{equation}
$$

Let the constraint cone $K$ and its dual cone $K^{*}$ be
$$
\begin{equation}
\begin{aligned}
K &amp;:=&amp;
\mathbb{R}^{n_{f}} &amp;\times
\mathbb{R}^{n_{l}}_{+} \times
\mathbb{L}^{q_{1}} \times \ldots \times \mathbb{L}^{q_{n_{q}}} \times
\mathbb{S}^{s_{1}}_{+} \times \ldots \times \mathbb{S}^{s_{n_{s}}}_{+}, \\
K^{*} &amp;:=&amp;
\{0\}^{n_{f}} &amp;\times
\mathbb{R}^{n_{l}}_{+} \times
\mathbb{L}^{q_{1}} \times \ldots \times \mathbb{L}^{q_{n_{q}}} \times
\mathbb{S}^{s_{1}}_{+} \times \ldots \times \mathbb{S}^{s_{n_{s}}}_{+}.
\end{aligned}
\label{primalDualCone}
\end{equation}
$$

With these abbreviations we obtain the following block form of the conic
problem \eqref{stdPrim}:
$$
\label{cpPrim}
\begin{array}{ll}
\text{minimize}   &amp; c^{T} x, \\
\text{subject to} &amp; Ax = b, \\
                  &amp; x \in K,
\end{array}
$$
with optimal value $\hat{f}_{p}$ and the corresponding dual problem
$$
\label{cpDual}
\begin{array}{ll}
\text{maximize}   &amp; b^{T} y, \\
\text{subject to} &amp; z = c - (A)^{T} y \in K^{*},
\end{array}
$$
with optimal value $\hat{f}_{d}$.

For a linear programming problem a vector $x \in \mathbb{R}^{n_{l}}$ is in
the interior of the cone $K = \mathbb{R}^{n_{l}}_{+}$, if $x_{i} > 0$ for
$i = 1,\ldots,n_{l}$.  For a vector $x \in \mathbb{R}^{n}$ let
$\lambda_{\min}(x) := x_{1} - ||x_{:}||_{2}$ denote the smallest eigenvalue
of $x$ (see [[Alizadeh2003]](/references#Alizadeh2003)).  Then
for second order cone programming problems a vector
$x \in \mathbb{R}^{\bar{q}}$ is in the interior of the cone
$K = \mathbb{L}^{q_{1}} \times, \ldots, \times \mathbb{L}^{q_{n_{q}}}$,
if $\lambda_{\min}(x_{i}) > 0$ for $i = 1,\ldots,n_{q}$.  Furthermore, for
a symmetric matrix $X \in \mathbb{S}^{n}$ let $\lambda_{\min}(X)$ denote the
smallest eigenvalue of $X$.  Then for semidefinite programming problems a
symmetric block matrix
$$
X = \begin{pmatrix}
X_{1} &amp; 0 &amp; 0 \\
0 &amp; \ddots &amp; 0 \\
0 &amp; 0 &amp; X_{n_{s}}
\end{pmatrix},
$$
is in the interior of the cone
$K = \mathbb{S}^{s_{1}}_{+} \times,\ldots,\times \mathbb{S}^{s_{n_{s}}}_{+}$,
if $\lambda_{\min}(X_{j}) > 0$ for $j = 1,\ldots,n_{s}$.

It is well known that for linear programming problems strong duality
$\hat{f}_{p} = \hat{f}_{d}$ holds without any constraint qualifications.
General conic programs satisfy only the weak duality condition
$\hat{f}_{d} \leq \hat{f}_{p}$.  Strong duality requires additional
constraint qualifications, such as *Slater's constraint qualifications* (see
[[Boyd1996]](/references#Boyd1996),
[[NestNem]](/references#NestNem)).

**Strong Duality Theorem**

* If the primal problem is strictly feasible (i.e. there exists a primal
  feasible point $x$ in the interior of $K$) and $\hat{f}_{p}$ is finite,
  then $\hat{f}_{p} = \hat{f}_{d}$ and the dual supremum is attained.
* If the dual problem is strictly feasible (i.e. there exists some $y$ such
  that $z = c - (A)^{T} y$ is in the interior of $K^{*}$) and $\hat{f}_{d}$
  is finite, then $\hat{f}_{d} = \hat{f}_{p}$, and the primal infimum is
  attained.


In general, one of the problems \eqref{cpPrim} or \eqref{cpDual} may have
optimal solutions and its dual problem is infeasible, or the duality gap may
be positive at optimality.

Duality theory is central to the study of optimization.  Firstly, algorithms
are frequently based on duality (like primal-dual interior point methods),
secondly, they enable one to check whether or not a given feasible point is
optimal, and thirdly, it allows one to compute verified results efficiently.

For the usage of VSDP a knowledge of interval arithmetic is not required.
Intervals are only used to specify error bounds.  An interval vector or an
interval matrix is defined as a set of vectors or matrices that vary between
a lower and an upper vector or matrix, respectively.  In other words, these
are quantities with interval components.  In
[INTLAB](http://www.ti3.tu-harburg.de/rump/intlab/) these interval quantities
can be initialized with the routine `infsup`.  Equivalently, these quantities
can be defined by a midpoint-radius representation, using the routine
`midrad`.

# Getting started with VSDP

{% highlight text %}
"[...] the routine can produce a computed result that is nonsensical and
the application proceeds as if the results were correct. [...] What should
you do? [...] The first defense is to adopt a skeptical attitude toward
numerical results until you can verify them by independent methods."
{% endhighlight %}

-- [[Meyer2001]](/references#Meyer2001)

This section provides a step-by-step introduction to VSDP.  Basically, VSDP
consists of four main functions: `mysdps`, `vsdplow`, `vsdpup`, and
`vsdpinfeas`.  The function `mysdps` represents a simple interface to the
conic solvers mentioned in the first chapter.  The functions `vsdplow` and
`vsdpup` compute rigorous enclosures of $ε$-optimal solutions as well as
lower and upper bounds of the primal and dual optimal value, respectively.
The function `vsdpinfeas` establishes a rigorous certificate of primal or
dual infeasibility.

The VSDP data format coincides with the SeDuMi format.  Semidefinite
programs that are defined in the format of one of the supported solvers
can be imported into VSDP.

# Linear Programming

In this section we describe how linear programming problems can be solved
with VSDP.  In particular, two linear programming examples are considered
in detail.  Each conic problem is fully described by the four variables
$(A,b,c,K)$.  The first two quantities represent the affine constraints
$Ax = b$.  The third is the primal objective vector `c`, and the last
describes the underlying cone.  The cone `K` is a structure with four fields:
`K.f`, `K.l`, `K.q`, and `K.s`.  The field `K.f` stores the number of free
variables $n_{f}$, the field `K.l` stores the number of nonnegative variables
$n_{l}$, the field `K.q` stores the dimensions $q_{1}, \ldots, q_{n_{q}}$ of
the second order cones, and similarly `K.s` stores the dimensions $s_{1},
\ldots, s_{n_{s}}$ of the semidefinite cones.  If a component of `K` is
empty, then it is assumed that the corresponding cone do not occur.

Consider the linear programming problem
$$
\label{LP1}
\begin{array}{ll}
\text{minimize}   &amp; 2x_{2} + 3x_{4} + 5x_{5}, \\
\text{subject to} &amp;
\begin{pmatrix}
-1 &amp; 2 &amp;  0 &amp; 1 &amp; 1 \\
 0 &amp; 0 &amp; -1 &amp; 0 &amp; 2
\end{pmatrix} x = \begin{pmatrix} 2 \\ 3 \end{pmatrix}, \\
&amp; x \in \mathbb{R}^{5}_{+},
\end{array}
$$
with its corresponding dual problem
$$
\label{LP1Dual}
\begin{array}{ll}
\text{maximize}   &amp; 2 y_{1} + 3 y_{2}, \\
\text{subject to} &amp;
z = \begin{pmatrix} 0 \\ 2 \\ 0 \\ 3 \\ 5 \end{pmatrix} -
\begin{pmatrix}
-1 &amp;  0 \\
2 &amp;  0 \\
0 &amp; -1 \\
1 &amp;  0 \\
1 &amp;  2
\end{pmatrix} y \in \mathbb{R}^{5}_{+},
\end{array}
$$

The unique exact optimal solution is given by
$x^{*} = \begin{pmatrix} 0 & 0.25 & 0 & 0 & 1.5 \end{pmatrix}^{T}$,
$y^{*} = \begin{pmatrix} 1 &2 \end{pmatrix}^{T}$ with
$\hat{f}_{p} = \hat{f}_{d} = 8$.

The input data of the problem in VSDP are

{% highlight octave %}
A = [-1, 2,  0, 1, 1;
      0, 0, -1, 0, 2];
b = [2; 3];
c = [0; 2; 0; 3; 5];
K.l = 5;
{% endhighlight %}

By using `vsdpinit` the approximate conic solver can be set globally for all
VSDP functions. Here we choose the solver SDPT3:

{% highlight octave %}
vsdpinit('sdpt3');
{% endhighlight %}

If we call the `mysdps` for problem \eqref{LP1} this problem will be solved
approximately, yielding the output

{% highlight octave %}
format infsup long
[objt,xt,yt,zt,info] = mysdps(A,b,c,K)
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


format infsup long
[objt,xt,yt,zt,info] = mysdps(A,b,c,K)

{% endhighlight %}

The returned variables have the following meaning: `objt` stores the
approximate primal and dual optimal value, `xt` represents the approximate
primal solution in vectorized form, and `(yt,zt)` is the dual solution pair.
The last returned variable `info` gives information on the success of the
conic solver:

* `info = 0`: successful termination,
* `info = 1`: the problem might be primal infeasible,
* `info = 2`: the problem might be dual infeasible,
* `info = 3`: the problem might be primal and dual infeasible.


With the approximate solution, a verified lower bound of the primal optimal
value can be computed by the function `vsdplow`:

{% highlight octave %}
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 4 column 28
	in:


[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)

{% endhighlight %}

The output consists of

1. a verified lower bound for the optimal value stored in `fL`,
2. a rigorous interval enclosure of a dual feasible solution `y`, and
3. a componentwise lower bound of $z = c - A^{T} y$ stored in `dl`.


Since `dl` is positive, the dual problem is strictly feasible, and the
rigorous interval vector `y` contains a dual interior solution.  Here only
some significant digits of this interval vector are displayed.  The upper
and lower bounds of the interval `y` can be obtained by using the `sup` and
`inf` routines of INTLAB.  For more information about the `intval` data type
see [[Rump1999]](/references#Rump1999).

Next we compute an upper bound for the optimal value by using `vsdpup`:

{% highlight octave %}
[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 4 column 27
	in:


[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)

{% endhighlight %}

The returned variables have a similar meaning to those of `vsdplow`: `fU` is
a verified upper bound for the optimal value, `x` is a rigorous interval
enclosure of a primal feasible solution, and `lb` is a componentwise lower
bound for `x`.  Since `lb` is a positive vector, hence contained in the
positive orthant, the primal problem is strictly feasible.  As for the
interval vector `y` also for the interval vector `x` only some significant
digits are displayed.  The quantity `x` is proper interval vector.  This
becomes clear when displaying the first component with `midrad`

{% highlight octave %}
midrad(x(1))
{% endhighlight %}

{% highlight text %}
error: 'x' undefined near line 4 column 8
	in:


midrad(x(1))

{% endhighlight %}

or `infsup`

{% highlight octave %}
infsup(x(1))
{% endhighlight %}

{% highlight text %}
error: 'x' undefined near line 4 column 8
	in:


infsup(x(1))

{% endhighlight %}

Summarizing, we have obtained a primal dual interval solution pair that
contains a primal and dual strictly feasible $ε$-optimal solution, where
$ε = \frac{2 (fU-fL)}{|fU|+|fL|} \approx 4.83 \times 10^{-9}$.

How a linear program with free variables can be solved with VSDP is
demonstrated by the following example with one free variable $x_{3}$:
$$
\begin{array}{ll}
\text{minimize}   &amp; x_{1} + x_{2} - 0.5 x_{3}, \\
\text{subject to}
&amp; x_{1} - x_{2} + 2 x_{3} = 0.5, \\
&amp; x_{1} + x_{2} -   x_{3} = 1, \\
&amp; x_{1} \geq 0, \\
&amp; x_{2} \geq 0.
\end{array}
$$

The optimal solution pair of this problem is
$x^{*} = \begin{pmatrix} \dfrac{5}{6} & 0 & -\dfrac{1}{6} \end{pmatrix}^{T}$,
$y^{*} = \begin{pmatrix} \dfrac{1}{6} & \dfrac{5}{6}\end{pmatrix}^{T}$ with
$\hat{f}_{p} = \hat{f}_{d} = \dfrac{11}{12}$.

When entering a problem the order of the variables is important: Firstly free
variables, secondly nonnegative variables, thirdly second order cone
variables, and last semidefinite variables.  This order must be maintained
in the matrix `A` as well as in the primal objective `c`.  In the given
example, the free variable is $x_{3}$, the nonnegative variables are $x_{1}$,
$x_{2}$.  Second order cone variables and semidefinite variables are not
present.  Therefore, the problem data are

{% highlight octave %}
K.f = 1;  % number of free variables
K.l = 2;  % number of nonnegative variables
A = [ 2, 1, -1;   % first column corresponds to free variable x3
     -1, 1,  1];  % second and third to bounded x1, x2
c = [-0.5; 1; 1]; % the same applies to c
b = [0.5; 1];
{% endhighlight %}

Rigorous bounds for the optimal value can be optained with:

{% highlight octave %}
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)



{% endhighlight %}

# Second Order Cone Programming

This section explains how to work with second order cone problems.  Due to
\eqref{stdPrim} the second order cone problem in standard primal form is
given by
$$
\label{socpPrim}
\begin{array}{ll}
\text{minimize}
&amp; \langle c^{f}, x^{f} \rangle +
  \sum_{i=1}^{n_{q}} \langle c_{i}^{q}, x_{i}^{q} \rangle, \\
\text{subject to}
&amp; A^{f} x^{f} + \sum_{i=1}^{n_{q}} A_{i}^{q} x_{i}^{q} = b, \\
&amp; x^{f} \in \mathbb{R}^{n_{f}}, \\
&amp; x_{i}^{q} \in \mathbb{L}^{q_{i}}, \quad i = 1, \ldots, n_{q}.
\end{array}
$$
The corresponding dual problem is
$$
\label{socpDual}
\begin{array}{ll}
\text{maximize}   &amp; b^{T} y, \\
\text{subject to}
&amp; (A_{i}^{q})^{T} y + z_{i}^{q} = c_{i}^{q},
\quad z_{i}^{q} \in \mathbb{L}^{q_{i}},
\quad i = 1,\ldots,n_{q}, \\
&amp; (A^{f})^{T} y + z^{f} = c^{f},
\quad z^{f} \in \mathbb{R}^{n_{f}}, \\
&amp; z^{f} = 0.
\end{array}
$$

Let us consider the total least squares problem taken from
[[ElGhaoui1997]](/references#ElGhaoui1997):
$$
\label{LSQexample}
\begin{array}{ll}
\text{maximize}   &amp; -y_{1} - y_{2}, \\
\text{subject to}
&amp; y_{1} \geq `` (q - P y_{3:5} ) ||_{2}, \\
&amp; y_{2} \geq
  \begin{Vmatrix}\begin{pmatrix} 1 \\ y_{3:5} \end{pmatrix}\end{Vmatrix}_{2},
\end{array}
$$
where
$$
P = \begin{pmatrix}
 3 &amp; 1 &amp; 4 \\
 0 &amp; 1 &amp; 1 \\
-2 &amp; 5 &amp; 3 \\
 1 &amp; 4 &amp; 5
\end{pmatrix},
\quad q = \begin{pmatrix} 0 \\ 2 \\ 1 \\ 3 \end{pmatrix},
\quad y \in \mathbb{R}^5.
$$
We want to transform this problem to the dual form \eqref{socpDual}.
The two inequalities can be written in the form
$$
\begin{pmatrix} y_{1} \\ q - P y_{3:5} \end{pmatrix} \in \mathbb{L}^{5}
\quad\text{and}\quad
\begin{pmatrix} y_{2} \\ 1 \\ y_{3:5} \end{pmatrix} \in \mathbb{L}^{5}.
$$
Since
$$
\begin{pmatrix} y_{1} \\ q - P y_{3:5} \end{pmatrix} =
\underbrace{\begin{pmatrix} 0 \\ 0 \\ 2 \\ 1 \\ 3 \end{pmatrix}}_{=c_{1}^{q}}
- \underbrace{\begin{pmatrix}
-1 &amp; 0 &amp;  0 &amp; 0 &amp; 0 \\
 0 &amp; 0 &amp;  3 &amp; 1 &amp; 4 \\
 0 &amp; 0 &amp;  0 &amp; 1 &amp; 1 \\
 0 &amp; 0 &amp; -2 &amp; 5 &amp; 3 \\
 0 &amp; 0 &amp;  1 &amp; 4 &amp; 5
\end{pmatrix}}_{=(A_{1}^{q})^{T}}
\begin{pmatrix} y_{1} \\ y_{2} \\ y_{3} \\ y_{4} \\ y_{5} \end{pmatrix},
$$
and
$$
\begin{pmatrix} y_{2} \\ 1 \\ y_{3:5} \end{pmatrix} =
\underbrace{\begin{pmatrix} 0 \\ 1 \\ 0 \\ 0 \\ 0 \end{pmatrix}}_{=c_{2}^{q}}
- \underbrace{\begin{pmatrix}
0 &amp; -1 &amp;  0 &amp;  0 &amp;  0 \\
0 &amp;  0 &amp;  0 &amp;  0 &amp;  0 \\
0 &amp;  0 &amp; -1 &amp;  0 &amp;  0 \\
0 &amp;  0 &amp;  0 &amp; -1 &amp;  0 \\
0 &amp;  0 &amp;  0 &amp;  0 &amp; -1
\end{pmatrix}}_{=(A_{2}^{q})^{T}}
\begin{pmatrix} y_{1} \\ y_{2} \\ y_{3} \\ y_{4} \\ y_{5} \end{pmatrix},
$$
our dual problem \eqref{socpDual} takes the form
$$
\label{SOCPexample}
\begin{array}{ll}
\text{maximize}
&amp; \underbrace{\begin{pmatrix} -1 &amp; -1 &amp; 0 &amp; 0 &amp; 0 \end{pmatrix}}_{=b^{T}} y, \\
\text{subject to}
&amp; z = \underbrace{\begin{pmatrix}
                  0 \\ 0 \\ 2 \\ 1 \\ 3 \\ 0 \\ 1 \\ 0 \\ 0 \\ 0
                  \end{pmatrix}}_{=c}
    - \underbrace{\begin{pmatrix}
                  -1 &amp;  0 &amp;  0 &amp;  0 &amp;  0 \\
                   0 &amp;  0 &amp;  3 &amp;  1 &amp;  4 \\
                   0 &amp;  0 &amp;  0 &amp;  1 &amp;  1 \\
                   0 &amp;  0 &amp; -2 &amp;  5 &amp;  3 \\
                   0 &amp;  0 &amp;  1 &amp;  4 &amp;  5 \\
                   0 &amp; -1 &amp;  0 &amp;  0 &amp;  0 \\
                   0 &amp;  0 &amp;  0 &amp;  0 &amp;  0 \\
                   0 &amp;  0 &amp; -1 &amp;  0 &amp;  0 \\
                   0 &amp;  0 &amp;  0 &amp; -1 &amp;  0 \\
                   0 &amp;  0 &amp;  0 &amp;  0 &amp; -1
                  \end{pmatrix}}_{=A^{T}} y \in K^{*},
\end{array}
$$
where $K^{*} = \mathbb{L}^{5} \times \mathbb{L}^{5}$.

We want to solve this problem with SeDuMi and enter the problem data of the
primal problem.

{% highlight octave %}
clear A b c K

vsdpinit('sedumi');
c = [0; 0; 2; 1; 3; 0; 1; 0; 0; 0];
A = [ -1, 0, 0,  0, 0,  0, 0,  0,  0,  0;
       0, 0, 0,  0, 0, -1, 0,  0,  0,  0;
       0, 3, 0, -2, 1,  0, 0, -1,  0,  0;
       0, 1, 1,  5, 4,  0, 0,  0, -1,  0;
       0, 4, 1,  3, 5,  0, 0,  0,  0, -1];
b = [-1; -1; 0; 0; 0];
{% endhighlight %}

Apart from the data `(A,b,c)`, the vector `q = [5;5]` of the second order
cone block sizes must be forwarded to the structure `K`:

{% highlight octave %}
K.q = [5;5];
{% endhighlight %}

Now we compute approximate solutions by using `mysdps` and then verified
error bounds by using `vsdplow` and `vsdpup`:

{% highlight octave %}
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt);
[fU,x,lb] = vsdpup (A,b,c,K,xt,yt,zt);
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt);
[fU,x,lb] = vsdpup (A,b,c,K,xt,yt,zt);

{% endhighlight %}

The approximate primal and dual optimal values and the rigorous lower and
upper bounds are

{% highlight octave %}
objt, fL, fU
{% endhighlight %}

{% highlight text %}
error: 'objt' undefined near line 4 column 1
	in:


objt, fL, fU

{% endhighlight %}

The quantities `x` and `y` are not diplayed here. The two output vectors
`lb` and `dl` provide rigorous lower bounds for the eigenvalues of these
variables.  Since both vectors are positive

{% highlight octave %}
lb, dl
{% endhighlight %}

{% highlight text %}
error: 'lb' undefined near line 4 column 1
	in:


lb, dl

{% endhighlight %}

the primal and the dual set of feasible solutions have a non empty relative
interior.  Thus Slater's constraint qualifications (**Strong Duality Theorem**)
imply that the duality gap is zero.  The intervals $x$ and $y$ contain
interior feasible $ε$-optimal solutions, where
$ε = \dfrac{2 (fU-fL)}{|fU|+|fL|} \approx 1.85 \times 10^{-9}$.

The conic program \eqref{cpPrim} allows to mix constraints of different types.
Let us, for instance, add the linear inequality
$\sum_{i=1}^{5} y_{i} \leq 3.5$ to the previous dual problem.  By using the
standard form \eqref{cpPrim}, \eqref{cpDual}, and the condensed quantities
\eqref{condensedX} it follows that we must add to the matrix `A` the column
consisting of ones and to `c` the value 3.5.  We extend the input data as
follows:

{% highlight octave %}
A = [[1; 1; 1; 1; 1], A];
c = [3.5; c];
K.l = 1;
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
fL = vsdplow(A,b,c,K,xt,yt,zt);
fU = vsdpup (A,b,c,K,xt,yt,zt);
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


A = [[1; 1; 1; 1; 1], A];
c = [3.5; c];
K.l = 1;
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
fL = vsdplow(A,b,c,K,xt,yt,zt);
fU = vsdpup (A,b,c,K,xt,yt,zt);

{% endhighlight %}

Then we obtain

{% highlight octave %}
fL, fU
{% endhighlight %}

{% highlight text %}
error: 'fL' undefined near line 4 column 1
	in:


fL, fU



{% endhighlight %}

# Semidefinite Programming

Let the SDP program be given in the standard form \eqref{cpPrim}
$$
\label{BlockDiagPSDP}
\begin{array}{lll}
\text{minimize}
&amp; \sum_{j=1}^{n_{s}} \langle C_{j}^{s}, X_{j}^{s} \rangle, &amp; \\
\text{subject to}
&amp; \sum_{j=1}^{n_{s}} \langle A_{i,j}^{s}, X_{j}^{s} \rangle = b_{i},
&amp; i = 1,\ldots,m, \\
&amp; X_{j}^{s} \in \mathbb{S}^{s_{j}}_{+},
&amp; j = 1,\ldots,n_{s}.
\end{array}
$$
Its dual problem \eqref{cpDual} is
$$
\label{BlockDiagDSDP}
\begin{array}{ll}
\text{maximize} &amp; b^{T} y, \\
\text{subject to}
&amp; Z_{j}^{s} = C_{j}^{s} - \sum_{i=1}^{m} y_{i} A_{i,j}^{s}
  \in \mathbb{S}^{s_{j}}_{+},\quad j = 1, \ldots, n_{s}.
\end{array}
$$
The matrices $A_{i,j}^{s}, C_{j}^{s}, X_{j}^{s}$ are assumed to be
symmetric $s_{j} \times s_{j}$ matrices. We store this problem in our
condensed format \eqref{vec}, \eqref{condensedX}, and \eqref{condensedA}.

Let us consider the example
(see [[Borchers2009]](/references#Borchers2009)):
$$
\begin{array}{lll}
\text{minimize}
&amp; \sum_{j=1}^{3} \langle C_{j}^{s}, X_{j}^{s} \rangle, &amp; \\
\text{subject to}
&amp; \sum_{j=1}^{3} \langle A_{i,j}^{s}, X_{j}^{s} \rangle = b_{i},\quad
     i = 1,2, \\
&amp; X_{1}^{s} \in \mathbb{S}^{2}_{+}, \\
&amp; X_{2}^{s} \in \mathbb{S}^{3}_{+}, \\
&amp; X_{3}^{s} \in \mathbb{S}^{2}_{+},
\end{array}
$$
where
$$
\begin{array}{ccc}
  A^{s}_{1,1} = \begin{pmatrix} 3 &amp; 1 \\ 1 &amp; 3 \end{pmatrix}
&amp; A^{s}_{1,2} =
  \begin{pmatrix} 0 &amp; 0 &amp; 0 \\ 0 &amp; 0 &amp; 0 \\ 0 &amp; 0 &amp; 0 \end{pmatrix}
&amp; A^{s}_{1,3} = \begin{pmatrix} 1 &amp; 0 \\ 0 &amp; 0 \end{pmatrix} \\
  A^{s}_{2,1} = \begin{pmatrix} 0 &amp; 0 \\ 0 &amp; 0 \end{pmatrix}
&amp; A^{s}_{2,2} =
  \begin{pmatrix} 3 &amp; 0 &amp; 1 \\ 0 &amp; 4 &amp; 0 \\ 1 &amp; 0 &amp; 5 \end{pmatrix}
&amp; A^{s}_{2,3} = \begin{pmatrix} 0 &amp; 0 \\ 0 &amp; 1 \end{pmatrix} \\
  C^{s}_{1} = \begin{pmatrix} -2 &amp; -1 \\ -1 &amp; -2 \end{pmatrix}
&amp; C^{s}_{2} =
  \begin{pmatrix} -3 &amp; 0 &amp; -1 \\ 0 &amp; -2 &amp; 0 \\ -1 &amp; 0 &amp; -3 \end{pmatrix}
&amp; C^{s}_{3} = \begin{pmatrix} 0 &amp; 0 \\ 0 &amp; 0 \end{pmatrix} \\
  b = \begin{pmatrix} 1 \\ 2 \end{pmatrix} &amp; &amp;
\end{array}
$$

In the condensed format the corresponding coefficient matrix and the primal
objective are
$$
\begin{aligned}
A &amp;= \begin{pmatrix}
     3 &amp; 1 &amp; 1 &amp; 3 &amp; 0 &amp; 0 &amp; 0 &amp; 0 &amp; 0 &amp; 0 &amp; 0 &amp; 0 &amp; 0 &amp; 1 &amp; 0 &amp; 0 &amp; 0 \\
     0 &amp; 0 &amp; 0 &amp; 0 &amp; 3 &amp; 0 &amp; 1 &amp; 0 &amp; 4 &amp; 0 &amp; 1 &amp; 0 &amp; 5 &amp; 0 &amp; 0 &amp; 0 &amp; 1
     \end{pmatrix},\\
c &amp;= \begin{pmatrix}
  -2 &amp; -1 &amp; -1 &amp; -2 &amp; -3 &amp; 0 &amp; -1 &amp; 0 &amp; -2 &amp; 0 &amp; -1 &amp; 0 &amp; -3 &amp; 0 &amp; 0 &amp; 0 &amp; 0
  \end{pmatrix}^{T}.
\end{aligned}
$$

We enter the problem data

{% highlight octave %}
clear A b c K

A = [3, 1, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
     0, 0, 0, 0, 3, 0, 1, 0, 4, 0, 1, 0, 5, 0, 0, 0, 1];
c = [-2; -1; -1; -2; -3; 0; -1; 0; -2; 0; -1; 0; -3; 0; 0; 0; 0];
b = [1; 2];
{% endhighlight %}

define the structure `K` for the PSD-cone

{% highlight octave %}
K.s = [2; 3; 2];
{% endhighlight %}

and call `mysdps`

{% highlight octave %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt

{% endhighlight %}

The other quantities are not displayed for brevity.

By calling `vsdplow` and `vsdpup` we get verified error bounds

{% highlight octave %}
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 4 column 28
	in:


[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)

{% endhighlight %}

{% highlight octave %}
[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 4 column 27
	in:


[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)

{% endhighlight %}

The components `lb(j)` are lower bounds of the smallest eigenvalues
$\lambda_{\min}([X_{j}^{s}])$ for `j = 1,2,3`.  Hence `lb &gt; 0` proves that
all real matrices $X_{j}^{s}$, that are contained in the corresponding
interval matrices $[X_{j}^{s}]$, are in the interior of the cone
$\mathbb{S}^{2}_{+} \times \mathbb{S}^{3}_{+} \times\mathbb{S}^{2}_{+}$,
where the interval matrices $[X_{j}^{s}]$ are obtained by applying the `mat`
operator to intval `x`.  Analogously, `dl(j)` are lower bounds for the
smallest eigenvalues of the dual interval matrices $[Z_{j}^{s}]$ that
correspond to the dual solution `y`.  Since, for this example, both `dl`
and `lb` are positive, strict feasibility is proved for the primal and the
dual problem, and strong duality holds valid.

Now we consider the following example
(see [[Jansson2006]](/references#Jansson2006)):
$$
\label{SDPexample}
\begin{array}{ll}
\text{minimize} &amp; \langle C_{1}, X \rangle, \\
\text{subject to}
&amp; \langle A_{1,1}, X \rangle = 1, \\
&amp; \langle A_{2,1}, X \rangle = 2δ, \\
&amp; \langle A_{3,1}, X \rangle = 0, \\
&amp; \langle A_{4,1}, X \rangle = 0, \\
&amp; X \in \mathbb{S}^{3}_{+},
\end{array}
$$
where
$$
\begin{array}{cc}
C_{1} = \begin{pmatrix}
        0   &amp; 0.5 &amp; 0 \\
        0.5 &amp; δ   &amp; 0 \\
        0   &amp; 0   &amp; δ
        \end{pmatrix},
&amp; b = \begin{pmatrix} 1 \\ 2δ \\ 0 \\ 0 \end{pmatrix}, \\
A_{1,1} = \begin{pmatrix}
           0   &amp; -0.5 &amp; 0 \\
          -0.5 &amp;  0   &amp; 0 \\
           0   &amp;  0   &amp; 0
          \end{pmatrix},
&amp; A_{2,1} = \begin{pmatrix}
            1 &amp; 0 &amp; 0 \\
            0 &amp; 0 &amp; 0 \\
            0 &amp; 0 &amp; 0
            \end{pmatrix}, \\
A_{3,1} = \begin{pmatrix}
          0 &amp; 0 &amp; 1 \\
          0 &amp; 0 &amp; 0 \\
          1 &amp; 0 &amp; 0
          \end{pmatrix},
&amp; A_{4,1} = \begin{pmatrix}
            0 &amp; 0 &amp; 0 \\
            0 &amp; 0 &amp; 1 \\
            0 &amp; 1 &amp; 0
            \end{pmatrix}.
\end{array}
$$

It is easy to prove that for

* $δ > 0$: the problem is feasible with
  $\hat{f}_{p} = \hat{f}_{d} = -0.5$ (zero duality gap),
* $δ = 0$: the problem is feasible but ill-posed with nonzero duality
  gap,
* $δ < 0$: the problem is infeasible.


For $δ > 0$ the primal optimal solution of the problem is given by the
matrix
$$
\label{OptSolSDPExp}
X^{*} = \begin{pmatrix}
2δ &amp; -1 &amp; 0 \\ -1 &amp; \dfrac{1}{2δ} &amp; 0 \\ 0 &amp; 0 &amp; 0
\end{pmatrix}.
$$
The corresponding dual optimal vector is
$y^{*} = \begin{pmatrix} 0 & -1/(4δ) & 0 & 0 \end{pmatrix}^{T}$.
We choose $δ = 10^{-4}$ and enter the problem.

{% highlight octave %}
% define delta parameter
d = 1e-4;
% define the constraint matrices
A1 = [ 0,   -0.5, 0;
      -0.5,  0,   0;
       0,    0,   0];
A2 = [1, 0, 0;
      0, 0, 0;
      0, 0, 0];
A3 = [0, 0, 1;
      0, 0, 0;
      1, 0, 0];
A4 = [0, 0, 0;
      0, 0, 1;
      0, 1, 0];

b = [1; 2*d; 0; 0];

C = [0,   0.5, 0;
     0.5, d,   0;
     0,   0,   d];

% define the cone structure K
K.s = 3;

% vectorize the matrices Ai and C
A = [A1(:), A2(:), A3(:), A4(:)];
c = C(:);
{% endhighlight %}

The SDPT3-solver provides the following results:

{% highlight octave %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity

{% endhighlight %}

The value of the return parameter `info` confirms successful termination of
the solver.  The first eight decimal digits of the primal and dual optimal
values are correct, since $\hat{f}_{p} = \hat{f}_{d} = -0.5$, all components
of the approximate solutions `xt` and `yt` have at least five correct decimal
digits.  Nevertheless, successful termination reported by a solver gives no
guarantee on the quality of the computed solution.

For instance, if we apply SeDuMi to the same problem we obtain:

{% highlight octave %}
vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity

{% endhighlight %}

SeDuMi terminates without any warning, but some results are poor.  Since the
approximate primal optimal value is smaller than the dual one, weak duality
is not satisfied. In other words, the algorithm is not backward stable for
this example.  The CSDP-solver gives similar results:

{% highlight octave %}
vsdpinit('csdp');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('csdp');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt, xt, yt, info  % zt:  hidden for brevity

{% endhighlight %}

A good deal worse are the results that can be derived with older versions of
these solvers, including SDPT3 and SDPA
[[Jansson2006]](/references#Jansson2006).

Reliable results can be obtained by the functions `vsdplow` and `vsdpup`.
Firstly, we consider `vsdplow` and the approximate solver SDPT3.

{% highlight octave %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)

{% endhighlight %}

the vector `y` is a rigorous interior dual $ε$-optimal solution where we shall
see that $ε \approx 2.27 \times 10^{-8}$.  The positivity of `dl` verifies
that `y` contains a dual strictly feasible solution.  In particular, strong
duality holds.  By using SeDuMi similar rigorous results are obtained.  But
for the SDPA-solver we get

{% highlight octave %}
vsdpinit('sdpa');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fL,y,dl] = vsdplow(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
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
$ε$-optimal solution can be computed by using the `vsdpup` function
together with SDPT3:

{% highlight octave %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[fU,x,lb] = vsdpup(A,b,c,K,xt,yt,zt)

{% endhighlight %}

The output `fU` is close to the dual optimal value $\hat{f}_{d} = -0.5$.
The interval vector `x` contains a primal strictly feasible solution, see
\eqref{OptSolSDPExp}, and the variable `lb` is a lower bound for the smallest
eigenvalue of `x`.  Because `lb` is positive, Slater's condition is fulfilled
and strong duality is verified once more.

Summarizing, by using SDPT3 for the considered example with parameter
$δ = 10^{-4}$, VSDP verified strong duality with rigorous bounds for the
optimal value
$$
-0.500000007 \leq \hat{f}_{p} = \hat{f}_{d} \leq -0.499999994.
$$

The rigorous upper and lower error bounds of the optimal value show only
modest overestimation.  Strictly primal and dual feasible solutions are
obtained.  Strong duality is verified.  Moreover, we have seen that the
quality of the rigorous results depends strongly on the quality of the
computed approximations.

# A Priori Upper Bounds for Optimal Solutions

In many practical applications the order of the magnitude of a primal or dual
optimal solution is known a priori.  This is the case in many combinatorial
optimization problems, or, for instance, in truss topology design where the
design variables such as bar volumes can be roughly bounded.  If such bounds
are available they can speed up the computation of guaranteed error bounds
for the optimal value substantially, see
[[Jansson2006]](/references#Jansson2006).

For linear programming problems the upper bound for the variable $x^{l}$
is a vector $\bar{x}$ such that $x^{l} \leq \bar{x}$.  For second
order cone programming the upper bounds for block variables $x_{i}^{q}$
can be entered as a vector of upper bounds $\overline{\lambda}_{i}$ of the
largest eigenvalues $\lambda_{\max}(x_{i}^{q}) = (x_{i}^{q})_{1} +
||(x_{i}^{q})_{:}||_{2}$, $i = 1,\ldots,n_{q}$.  Similarly, for
semidefinite programs upper bounds for the primal variables $X_{j}^{s}$
can be entered as a vector of upper bounds of the largest eigenvalues
$\lambda_{\max}(X_{j}^{s})$, $j = 1,\ldots,n_{s}$. An upper bound
$\bar{y}$ for the dual optimal solution $y$ is a vector which is
componentwise larger then $|y|$. Analogously, for conic programs with free
variables the upper bound can be entered as a vector $\bar{x}$ such that
$|x^{f}| \leq \bar{x}$.

As an example, we consider the previous SDP problem \eqref{SDPexample} with
an upper bound $xu = 10^{5}$ for $\lambda_{\max}(X)$.

{% highlight octave %}
vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
xu = 1e5;
fL = vsdplow(A,b,C,K,xt,yt,zt,xu)
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
xu = 1e5;
fL = vsdplow(A,b,C,K,xt,yt,zt,xu)

{% endhighlight %}

Now, we suppose the existence of dual upper bounds

{% highlight octave %}
yu = 1e5 * [1 1 1 1]';
fU = vsdpup(A, b, C, K, xt, yt, zt, yu)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 5 column 25
	in:


yu = 1e5 * [1 1 1 1]';
fU = vsdpup(A, b, C, K, xt, yt, zt, yu)

{% endhighlight %}

yielding also a reasonable bound.

# Rigorous Certificates of Infeasibility

The functions `vsdplow` and `vsdpup` prove strict feasibility and compute
rigorous error bounds.  For the verification of infeasibility the function
`vsdpinfeas` can be applied.  In this section we show how to use this
function.

We consider a slightly modified second order cone problem
([[BenTal2001]](/references#BenTal2001), Example 2.4.2)

$$
\begin{array}{ll}
\text{minimize} &amp; 0^{T} x, \\
\text{subject to}
&amp; \begin{pmatrix} 1 &amp; 0 &amp; 0.5 \\ 0 &amp; 1 &amp; 0 \end{pmatrix}
  x = \begin{pmatrix} 0 \\ 1 \end{pmatrix}, \\
&amp; x \in \mathbb{L}^{3},
\end{array}
$$
with its dual problem
$$
\begin{array}{ll}
\text{maximize} &amp; -y_{2}, \\
\text{subject to}
&amp; \begin{pmatrix} 0 \\ 0 \\ 0 \end{pmatrix} -
  \begin{pmatrix} 1 &amp; 0 \\ 0 &amp; 1 \\ 0.5 &amp; 0 \end{pmatrix}
  y \in \mathbb{L}^{3}.
\end{array}
$$

Both, the primal and the dual problem, are infeasible.  We can easily prove
this fact by assuming that there exists a primal feasible point $x$.  This
point has to satisfy $x_{3} = -2x_{1}$, and therefore
$x_{1} \geq \sqrt{x_{2}^{2} + (-2x_{1})^{2}}$.  From the second equality
constraint we get $x_{2} = 1$ yielding the contradiction
$x_{1} \geq \sqrt{1 + 4x_{1}^{2}}$.  Thus, the primal problem has no feasible
solution.  A certificateof infeasibility of the primal problem is given by
the dual unbounded ray $y = \alpha (-2,1)^{T}$.

The input data are

{% highlight octave %}
clear A b c K

A = [1, 0, 0.5;
     0, 1, 0];
b = [0; 1];
c = [0; 0; 0];
K.q = 3;
{% endhighlight %}

Using the approximate solver SDPT3 we obtain a rigorous certificate of
infeasibility with the routine `vsdpinfeas`:

{% highlight octave %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'p',xt,yt,zt);
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'p',xt,yt,zt);

{% endhighlight %}

Apart from the problem data parameters `(A,b,c,K)` and the approximations
`(xt,yt,zt)` an additional parameter is required, namely

* `'p'` if primal infeasibility should be verified, or
* `'d'` if dual infeasibility should be verified.


The function `vsdpinfeas` tries to verify the existence of an improving
ray using the approximations that are computed by the approximate solver.
If the return value `isinfeas` is equal to one then `vsdpinfeas` has
verified primal infeasibility.  The return value is equal to negative one
if dual infeasibility could be proved.  In the case that no certificate of
infeasibility could be found `vsdpinfeas` returns zero.

For the considered example `vsdpinfeas` returns

{% highlight octave %}
isinfeas, x, y
{% endhighlight %}

{% highlight text %}
error: 'isinfeas' undefined near line 4 column 1
	in:


isinfeas, x, y

{% endhighlight %}

Hence, primal infeasibility is verified.  The return parameter `y` provides
a rigorous dual improving ray. The return parameter `x` must be `NaN`, since
we did not check dual infeasibility.

Now we try to solve the problem \eqref{SDPexample} for $δ = -10^{4} < 0$.
We know that in this case the problem is primal and dual infeasible.

{% highlight octave %}
d = -1e-4;
A1 = [ 0,   -0.5, 0;
      -0.5,  0,   0;
       0,    0,   0];
A2 = [1, 0, 0;
      0, 0, 0;
      0, 0, 0];
A3 = [0, 0, 1;
      0, 0, 0;
      1, 0, 0];
A4 = [0, 0, 0;
      0, 0, 1;
      0, 1, 0];
A = [A1(:), A2(:), A3(:), A4(:)];
b = [1; 2*d; 0; 0];
C = [0,   0.5, 0;
     0.5, d,   0;
     0,   0,   d];
c = C(:);
K.s = 3;

vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
info
{% endhighlight %}

{% highlight text %}
error: 'import_vsdp' undefined near line 78 column 34
	in:


d = -1e-4;
A1 = [ 0,   -0.5, 0;
      -0.5,  0,   0;
       0,    0,   0];
A2 = [1, 0, 0;
      0, 0, 0;
      0, 0, 0];
A3 = [0, 0, 1;
      0, 0, 0;
      1, 0, 0];
A4 = [0, 0, 0;
      0, 0, 1;
      0, 1, 0];
A = [A1(:), A2(:), A3(:), A4(:)];
b = [1; 2*d; 0; 0];
C = [0,   0.5, 0;
     0.5, d,   0;
     0,   0,   d];
c = C(:);
K.s = 3;

vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
info

{% endhighlight %}

SeDuMi terminates the computation with the termination code `info = 1` and
gives the warnings

{% highlight octave %}
...
  Dual infeasible, primal improving direction found.
...
  Primal infeasible, dual improving direction found.
...
{% endhighlight %}

If we apply the routines `vsdplow` and `vsdpup`

{% highlight octave %}
fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 4 column 22
	in:


fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)

{% endhighlight %}

then the bounds $fL$, $fU$ are infinite, as expected.  By applying
`vsdpinfeas` we obtain

{% highlight octave %}
[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'p',xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 4 column 40
	in:


[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'p',xt,yt,zt)

{% endhighlight %}

Since `isinfeas = 0`, primal infeasibility could not be verified, and
therefore the certificates `x`, `y` are set to `NaN`.  The reason is that
all dual improving rays `y` must satisfy
$$
\label{exmImpvRay}
-\sum_{i=1}^{4} y_{i} A_{i,1} =
\begin{pmatrix}
-y_{2}   &amp; y_{1}/2 &amp; -y_{3} \\
 y_{1}/2 &amp; 0       &amp; -y_{4} \\
-y_{3}   &amp; -y_{4}  &amp; 0
\end{pmatrix} \in \mathbb{S}^{3}_{+}.
$$

This is only possible for $y_{1} = y_{3} = y_{4} = 0$.  Hence, for each
improving ray the matrix \eqref{exmImpvRay} has a zero eigenvalue.  In VSDP
we verify positive semidefiniteness by computing enclosures of the
eigenvalues.  If all enclosures are non-negative positive semidefiniteness is
proved.  If one eigenvalue is zero then, except in special cases, the
corresponding enclosure has a negative component implying that positive
semidefinitness cannot be proved and primal infeasibility is not verified.

Now we try to verify dual infeasibility by using `vsdpinfeas` with the
parameter `'d'`.

{% highlight octave %}
[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'d',xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 4 column 40
	in:


[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'d',xt,yt,zt)

{% endhighlight %}

Also dual infeasibility cannot be proved.  An easy calculation shows that the
primal improving ray must satisfy
$$
X = \begin{pmatrix}
0 &amp; 0 &amp; 0\\
0 &amp; x_{22} &amp; 0\\
0 &amp; 0 &amp; x_{33}
\end{pmatrix} \in \mathbb{S}^{3}_{+}.
$$

and with the same argument as above positive semidefiniteness cannot be
verified.

# Handling Free Variables

Free variables occur often in practice.  Handling free variables in interior
point algorithms is a pending issue (see for example
[[Andersen2002]](/references#Andersen2002),
[[Anjos2007]](/references#Anjos2007), and
[[Meszaros1998]](/references#Meszaros1998)).  Frequently users
convert a problem with free variables into one with restricted variables by
representing the free variables as a difference of two nonnegative variables.
This approach increases the problem size and introduces ill-posedness, which
may lead to numerical difficulties.

For an example we consider the test problem _nb_L1_ from the DIMACS test
library [[Pataki2002]](/references#Pataki2002).  The problem
originates from side lobe minimization in antenna engineering.  This is a
second order cone programming problem with 915 equality constraints, 793 SOCP
blocks each of size 3, and 797 nonnegative variables.  Moreover, the problem
has two free variables that are described as the difference of four
nonnegative variables.  This problem can be loaded from the examples
directory of VSDP.  As the computation is more expensive, only the results
are reported here:

{% highlight octave %}
vsdpinit('sdpt3');
load(fullfile('examples','nb_L1.mat'));
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt
{% endhighlight %}

{% highlight octave %}
objt =
 -13.012270628163670 -13.012270796164543
{% endhighlight %}

SDPT3 solves the problem without warnings, although it is ill-posed according
to Renegar's definition [[Renegar1994]](/references#Renegar1994).

Now we try to get rigorous bounds using the approximation of SDPT3.

{% highlight octave %}
fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight octave %}
fL =
  -Inf
fU =
 -13.012270341861644
{% endhighlight %}

These results reflect that the interior of the dual feasible solution set is
empty.  An ill-posed problem has the property that the distance to primal or
dual infeasibility is zero.  If as above the distance to dual infeasibility
is zero, then there are sequences of dual infeasible problems with input data
converging to the input data of the original problem. Each problem of the
sequence is dual infeasible and thus has the dual optimal solution $-\infty$.
Hence, the result $-\infty$ of `vsdplow` is exactly the limit of the optimal
values of the dual infeasible problems and reflects the fact that the
distance to dual infeasibility is zero.  This demonstrates that the infinite
bound computed by VSDP is sharp, when viewed as the limit of a sequence of
infeasible problems.  We have a similar situation if the distance to primal
infeasibility is zero.

If the free variables are not converted into restricted ones then the problem
is well-posed and a rigorous finite lower bound can be computed.

{% highlight octave %}
load(fullfile('examples','nb_L1free.mat'));
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
objt
{% endhighlight %}

{% highlight octave %}
objt =
 -13.012270619970032 -13.012270818869100
{% endhighlight %}

By using the computed approximations we obtain the following rigorous bounds:

{% highlight octave %}
fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight octave %}
fL =
 -13.012270819014953
fU =
 -13.012270617556419
{% endhighlight %}

Therefore, without splitting the free variables, we get rigorous finite lower
and upper bounds of the exact optimal value with an accuracy of about eight
decimal digits.  Moreover, verified interior solutions are computed for both
the primal and the dual problem, proving strong duality.

In Table [benchmark_dimacs_free_2012_12_12.html](benchmark_dimacs_free_2012_12_12.html) we display rigorous bounds
for the optimal value of eight problems contained in the DIMACS test library
that have free variables (see [[Anjos2007]](/references#Anjos2007)
and [[Kobayashi2007]](/references#Kobayashi2007)).  These
problems have been modified by reversing the substitution of the free
variables.  We have listed the results for the problems with free variables
and for the same problems when representing the free variables as the
difference of two nonnegative variables.  The table contains the rigorous
upper bounds $fU$, the rigorous lower bounds $fL$, and the computing times
measured in seconds for the approximate solution $t_s$, the lower bound
$t_u$, and the upper bound $t_l$, respectively.  The table demonstrates the
drastic improvement if free variables are not split.

Independent of the transformation of the free variables the primal problems
of the *nql* instances are ill-posed.  The weak error bound of the optimal
constraints.  A solution for the *qssp180* instance is due to the large
number of equality system with 130141 equality constraints and 261365
variables has to be solved rigorously.  In the next version of VSDP the
accuracy for such large problems will be improved.

# Statistics of the Numerical Results

{% highlight text %}
"If error analysis could be automated, the mysteries of floating-point
arithmetic could remain hidden; the computer would append to every
displayed numerical result a modest over-estimate of its uncertainty due
to imprecise data and approximate arithmetic, or else explain what went
wrong, and all at a cost not much higher than if no error analysis had
been performed.  So far, every attempt to achieve this ideal has been
thwarted."
-- W. M. Kahan, The Regrettable Failure of Automated Error Analysis, 1989
<https://www.seas.upenn.edu/~sweirich/types/archive/1989/msg00057.html>
{% endhighlight %}

In this section, we present statistics for the numerical results obtained
by VSDP for conic programming problems.  The tests were performed using
approximations computed by the conic solvers: CSDP, SEDUMI, SDPT3, SDPA,
LINPROG, and LPSOLVE.  For second order cone programming problems only
SEDUMI and SDPT3 were used.  The solvers have been called with their default
parameters.  Almost all of the problems that could not be solved with a
guaranteed accuracy about $10^{-7}$ are known to be ill-posed
(cf. [[Freund2003]](/references#Freund2003)).

We measure the difference between two numbers by the frequently used quantity
$$
\label{eq:accurracy_measure}
μ(a,b) := \dfrac{a-b}{\max\{1.0, (`a`+`b`)/2\}}.
$$

Notice that we do not use the absolute value of $a - b$.  Hence, a negative
sign implies that $a < b$.

# SDPLIB

In the following, we describe the numerical results for problems from the
SDPLIB suite of Borchers
[[Borchers1999]](/references#Borchers1999).  In
[[Freund2007]](/references#Freund2007) it is shown that four
problems are infeasible, and 32 problems are ill-posed.

VSDP could compute rigorous bounds of the optimal values for all feasible
well-posed problems and verify the existence of strictly primal and dual
feasible solutions.  Hence, strong duality is proved. For the 32 ill-posed
problems VSDP has computed the upper bound $fU = \infty$, which reflects the
fact that the distance to the next primal infeasible problem is zero.  For
the four infeasible problems VSDP could compute rigorous certificates of
infeasibility.  Detailed numerical results can be found in Table
[benchmark_sdplib_2012_12_12.html](benchmark_sdplib_2012_12_12.html), where the computed rigorous upper bound
$fU$, the rigorous lower bound $fL$, and the rigorous error bound $μ(fU,fL)$
are displayed.  We have set $μ(fU,fL) = NaN$ if the upper or the lower bound
is infinite.  Table [benchmark_sdplib_2012_12_12.html](benchmark_sdplib_2012_12_12.html) also contains
running times in seconds, where $t_{s}$ is the time for computing the
approximations, and $t_{u}$ and $t_{l}$ are the times for computing the upper
and the lower rigorous error bounds, respectively.

Some major characteristics of our numerical results for the SDPLIB are
summarized below.

{% highlight octave %}
disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_sdplib_2012_12_12.csv')))
{% endhighlight %}

{% highlight text %}
                   csdp        sdpa        sdpt3       sedumi  
med (mu(fU,fL))    1.03e-08    5.37e-08    1.68e-08    4.63e-07
max (mu(fU,fL))    4.15e-04    6.99e-05    7.41e-04    1.11e+00
min (mu(fU,fL))    9.32e-10    1.13e-08    5.79e-10    1.67e-09
med (tu/ts)        1.01        1.07        2.05        1.68    
med (tl/ts)        1.55        0.01        0.01        1.26    

{% endhighlight %}

It displays in the first row the median $\operatorname{med}(μ(fU,fL))$ of the
computed error bounds, in the second row the largest error bound
$\max(μ(fU,fL))$, and in the third row the minimal error bound
$\min(μ(fU,fL))$.  For this statistic only the well-posed problems are taken
into account.  In the two last rows the medians of time ratios
$t_{u} / t_{s}$ and $t_{l} / t_{s}$ are displayed.

The median of $μ(fU,fL)$ shows that for all conic solvers rigorous error
bounds with 7 or 8 significant decimal digits could be computed for most
problems.

Furthermore, the table shows that the error bounds as well as the time ratios
depend significantly on the used conic solver.  In particular the resulting
time ratios indicate that the conic solvers CSDP and SeDuMi aim to compute
approximate primal interior $ε$-optimal solutions.  In contrast SDPA and SDPT3
aim to compute dual interior $ε$-optimal solutions.

Even the largest problem *MaxG60* with about 24 million variables and 7000
constraints can be solved rigorously by VSDP, with high accuracy and in a
reasonable time.

# NETLIB LP

Here we describe some numerical results for the
[NETLIB linear programming library](http://www.netlib.org).  This is a well
known test suite containing many difficult to solve, real-world examples
from a variety of sources.

For this test set Ordóñez and Freund
[[Freund2003]](/references#Freund2003) have shown that 71 % of
the problems are ill-posed.  This statement is well reflected by our results:
for the ill-posed problems VSDP computed infinite lower or infinite upper
bounds.  This happens if the distance to the next dual infeasible or primal
infeasible problem is zero, respectively.

For the computation of approximations we used the solvers LINPROG, LPSOLVE,
SEDUMI, and SDPT3.  In the following table we display the same quantities as
in the previous section.  Again only the well-posed problems are taken into
account.

{% highlight octave %}
disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_netlib_lp_2012_12_12.csv')))
{% endhighlight %}

{% highlight text %}
                   linprog     lpsolve     sdpt3       sedumi  
med (mu(fU,fL))    1.18e-06    2.46e-07    3.02e-08    1.08e-05
max (mu(fU,fL))    2.00e+00    6.55e-03    6.60e-03    6.32e-01
min (mu(fU,fL))    6.02e-10    5.22e-10    2.34e-10    2.06e-11
med (tu/ts)        1.42        3.73        0.92        1.28    
med (tl/ts)        1.13        5.53        0.31        2.25    

{% endhighlight %}

Here we would like to mention also the numerical results of the C++ software
package LURUPA [[Keil2006]](/references#Keil2006),
[[Keil2009]](/references#Keil2009).  In
[[Keil2008]](/references#Keil2008) comparisons with other
software packages for the computation of rigorous errors bounds are described.

Detailed results can be found in Table [benchmark_netlib_lp_2012_12_12.html](benchmark_netlib_lp_2012_12_12.html).

# DIMACS

We present some statistics of numerical results for the DIMACS test library
of semidefinte-quadratic-linear programs.  This library was assembled for
the purposes of the 7-th DIMACS Implementation Challenge.  There are about
50 challenging problems that are divided into 12 groups.  For details see
[[Pataki2002]](/references#Pataki2002).  In each group there are
about 5 instances, from routinely solvable ones reaching to those at or
beyond the capabilities of current solvers.  Due to limited available memory
some problems of the DIMACS test library have been omitted in our test.
These are: *coppo68*, *industry2*, *fap09*, *fap25*, *fap36*, *hamming112*,
and *qssp180old*.

One of the largest problems which could be solved by VSDP is the problem
*hamming102*, with 23041 equality constraints and 1048576 variables.

{% highlight octave %}
disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_dimacs_2012_12_12.csv')))
{% endhighlight %}

{% highlight text %}
                   csdp        sdpa        sdpt3       sedumi  
med (mu(fU,fL))    4.02e-09    5.49e-08    8.90e-09    2.30e-08
max (mu(fU,fL))    1.11e-08    4.02e-07    1.16e+00    1.98e+00
min (mu(fU,fL))    1.24e-09    1.32e-08    5.92e-10    2.11e-09
med (tu/ts)        0.03        0.03        0.78        1.03    
med (tl/ts)        1.17        0.06        0.35        2.25    

{% endhighlight %}

The approximate solvers SDPA and CSDP are designed for SDP problems only.
Hence, in the table above we have displayed for these solvers only the
statistic of the SDP problems.

Detailed results can be found in Table [benchmark_dimacs_2012_12_12.html](benchmark_dimacs_2012_12_12.html).

# Kovcara's Library of Structural Optimization Problems

In this section a statistic of the numerical results for problems from
structural and topological optimization is presented.  Structural and
especially free material optimization gains more and more interest in the
recent years.  The most prominent example is the design of ribs in the
leading edge of the new Airbus A380.  We performed tests on problems from
the test library collected by Kocvara.  This is a collection of 26 sparse
semidefinite programming problems.  More details on these problems can be
found in [[BenTal2000]](/references#BenTal2000),
[[Kocvara2002]](/references#Kocvara2002), and
[[Bendsoe1997]](/references#Bendsoe1997).  For 24 problems out
of this collection VSDP could compute a rigorous primal and dual $ε$-optimal
solution.  Caused by the limited available memory and the great computational
times the largest problems *mater-5*, *mater-6*, *shmup5*, *trto5*, and
*vibra5* has been tested only with the solver SDPT3.  The largest problem
that was rigorously solved by VSDP is *shmup5*.  This problem has 1800
equality constraints and 13849441 variables.

A statistic of these numerical experiments is given below:

{% highlight octave %}
disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_kovcara_2012_12_12.csv')))
{% endhighlight %}

{% highlight text %}
                   csdp        sdpa        sdpt3       sedumi  
med (mu(fU,fL))    3.44e-07    2.26e-05    1.90e-06    1.93e-07
max (mu(fU,fL))    6.31e-05    1.89e-03    6.38e-04    8.80e-04
min (mu(fU,fL))    1.63e-09    1.05e-08    1.39e-09    7.75e-09
med (tu/ts)        0.38        1.01        2.11        3.21    
med (tl/ts)        1.92        0.01        0.01        2.58    

{% endhighlight %}

Detailed results can be found in Table [benchmark_kovcara_2012_12_12.html](benchmark_kovcara_2012_12_12.html).


Published with GNU Octave 4.4.0

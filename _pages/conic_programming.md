---
title: Conic Programming
permalink: conic_programming.html
---

# Conic Programming


* TOC
{:toc}


## Primal and dual form

VSDP can handle three self dual convex cones <span>$\mathcal{K}$</span>, that often occur
in practical applications.  These are:

* The non-negative orthant:
  <div>$$\mathbb{R}^{n}_{+} := \{ x \in \mathbb{R}^{n} \colon\; x_{i} \geq 0,
  \; i = 1, \ldots, n \}.$$</div>
* The Lorentz cone (see
  [[Alizadeh2003]](https://vsdp.github.io/references.html#Alizadeh2003)):
  <div>$$\mathbb{L}^{n} := \{ x \in \mathbb{R}^{n} \colon x_{1}
  \geq \|x_{2:n}\|_{2}\}.$$</div>
* The cone of symmetric positive semidefinite matrices:
  <div>$$\mathbb{S}^{n}_{+} := \left\{ X \in \mathbb{R}^{n \times n} \colon\;
  X = X^{T},\; v^{T} X v \geq 0,\; \forall v \in \mathbb{R}^{n} \right\}.$$</div>


If a quantity is in the interior of one of the above cones, the definitions
above must hold with strict inequalities.

By <span>$\langle c, x \rangle := c^{T} x$</span> the usual Euclidean inner product of
vectors in <span>$\mathbb{R}^{n}$</span> is denoted.  For symmetric matrices
<span>$X, Y \in \mathbb{S}^{n}$</span> the inner product is given by
<span>$\langle X,Y \rangle := \text{trace}(XY)$</span>.

Let <span>$A^{f}$</span> and <span>$A^{l}$</span> be a <span>$m \times n_{f}$</span> and a <span>$m \times n_{l}$</span> matrix,
respectively, and let <span>$A_{i}^{q}$</span> be <span>$m \times q_{i}$</span> matrices for
<span>$i = 1,\ldots,n_{q}$</span>.  Let <span>$c^{f} \in \mathbb{R}^{n_{f}}$</span>,
<span>$c^{l} \in \mathbb{R}^{n_{l}}$</span>, <span>$c_{i}^{q} \in \mathbb{R}^{q_i}$</span>, and
<span>$b \in \mathbb{R}^{m}$</span>.  Moreover, let <span>$A_{1,j}^{s}, \ldots, A_{m,j}^{s}$</span>,
<span>$C_{j}^{s}$</span>, <span>$X_{j}^{s}$</span> be symmetric <span>$(s_{j} \times s_{j})$</span> matrices for
<span>$j = 1, \ldots, n_{s}$</span>.

Now we can define the conic semidefinite-quadratic-linear programming
problem in primal standard form:
<div>$$\begin{array}{ll}
\text{minimize} &
\langle c^{f}, x^{f} \rangle + \langle c^{l}, x^{l} \rangle +
\sum_{i=1}^{n_{q}} \langle c_{i}^{q}, x_{i}^{q} \rangle +
\sum_{j=1}^{n_{s}} \langle C_{j}^{s}, X_{j}^{s} \rangle \\
\text{subject to} &
A^{f} x^{f} + A^{l} x^{l} + \sum_{i=1}^{n_{q}} A_{i}^{q} x_{i}^{q} +
\sum_{j=1}^{n_{s}}\mathcal{A}_{j}^{s}(X_{j}^{s}) = b,
\end{array}$$</div>
where <span>$x^{f} \in \mathbb{R}^{n_{f}}$</span> are "free variables",
<span>$x^{l} \in \mathbb{R}^{n_{l}}_{+}$</span> are "non-negative variables",
<span>$x_{i}^{q} \in \mathbb{L}^{q_i}$</span>, <span>$i = 1, \ldots, n_{q}$</span>, are "second-order
cone (SOCP) variables", and finally <span>$X_{j}^{s} \in \mathbb{S}^{s_{j}}_{+}$</span>,
<span>$j = 1, \ldots, n_{s}$</span> "positive semidefinite (SDP) variables".  The linear
operator
<div>$$\mathcal{A}_{j}^{s}(X_{j}^{s}) :=
\begin{pmatrix}
\langle A_{1j}^{s}, X_{j}^{s} \rangle \\
\vdots \\
\langle A_{mj}^{s}, X_{j}^{s} \rangle
\end{pmatrix}$$</div>
maps the symmetric matrices <span>$X_{j}^{s}$</span> to <span>$\mathbb{R}^{m}$</span>.  The adjoint
linear operator is
<span>$$</span>
(\mathcal{A}_{j}^{s})^{*} y := \sum_{k=1}^{m} A_{kj}^{s} y_{k}.
<span>$$</span>

The dual problem associated with the primal standard form is
<div>$$\begin{array}{ll}
\text{maximize} & b^{T} y \\
\text{subject to}
& (A^{f})^{T} y + z^{f} = c^{f}, \\
& (A^{l})^{T} y + z^{l} = c^{l}, \\
& (A_{i}^{q})^{T} y + z_{i}^{q} = c_{i}^{q}, \\
& (\mathcal{A}_{j}^{s})^{*} y + Z_{j}^{s} = C_{j}^{s},
\end{array}$$</div>
where <span>$z^{f} \in \{0\}^{n_{f}}$</span>, <span>$z^{l} \in \mathbb{R}^{n_{l}}_{+}$</span>,
<span>$z_{i}^{q} \in \mathbb{L}^{q_i}$</span>, <span>$i = 1, \ldots, n_{q}$</span>, and
<span>$Z_{j}^{s} \in \mathbb{S}^{s_{j}}_{+}$</span>, <span>$j = 1, \ldots, n_{s}$</span>.

The objective functions and equality constraints of the primal and dual
problem are linear.  Thus conic programming can be seen an extension of linear
programming with additional conic constraints.

By definition the vector <span>$x^{f}$</span> contains all unconstrained or free
variables, whereas all other variables are bounded by conic constraints.
In several applications some solvers (for example SDPA or CSDP) require that
free variables are converted into the difference of nonnegative variables.
Besides the major disadvantage that this transformation is numerical
unstable, it also increases the number of variables of the particular
problems.  In VSDP [free variables](https://vsdp.github.io/free_variables)
can be handled in a numerical stable manner.

## Condensed form

Occasionally, it is useful to represent the conic programming problem in a
more compact form by using the symmetric vectorization operator.  This
operator maps a symmetric matrix <span>$X \in \mathbb{S}^{n \times n}$</span> to a
<span>$n(n + 1)/2$</span>-dimensional vector
<div>$$svec(X, \alpha) :=
\begin{pmatrix}
X_{11} & \alpha X_{12} & X_{22} & \alpha X_{13} & \cdots &  X_{nn}
\end{pmatrix}^{T},$$</div>
where <span>$\alpha$</span> is a scaling factor for the off diagonal elements.  The
inverse operation is denoted by <span>$smat(x)$</span> such that <span>$smat(svec(X)) = X$</span>.

By using <span>$svec$</span> it is possible to map each symmetric matrix to a vector
quantity.  Additionally, by using the scaling factor <span>$\alpha = 1$</span> for all
<span>$A_{kj}^{s}$</span>, <span>$C_{j}^{s}$</span>, and <span>$Z_{j}^{s}$</span> and the scaling factor
<span>$\alpha = 2$</span> for all <span>$X_{j}^{s}$</span>, the inner product of symmetric matrices
reduces to a simple scalar product of two vectors.  Thus all cones can be
treated in exactly the same way.

The condensed quantities <span>$c$</span>, <span>$x$</span>, and <span>$z$</span> are <span>$n \times 1$</span>-vectors:
<div>$$c :=
\begin{pmatrix}
c^{f} \\ c^{l} \\ c_{1}^{q} \\ \vdots \\ c_{n_{q}}^{q} \\
svec(C_{1}^{s},1) \\ \vdots \\ svec(C_{n_{s},1}^{s}) \\
\end{pmatrix},
x :=
\begin{pmatrix}
x^{f} \\ x^{l} \\ x_{1}^{q} \\ \vdots \\ x_{n_{q}}^{q} \\
svec(X_{1}^{s},2) \\ \vdots \\ svec(X_{n_{s},2}^{s})
\end{pmatrix},
z :=
\begin{pmatrix}
z^{f} \\ z^{l} \\ z_{1}^{q} \\ \vdots \\ z_{n_{q}}^{q} \\
svec(Z_{1}^{s},1) \\ \vdots \\ svec(Z_{n_{s}}^{s},1) \\
\end{pmatrix},$$</div>
where <span>$n = n_{f} + n_{l} + \sum_{i = 1}^{n_{q}} q_{i}
+ \sum_{j = 1}^{n_{s}} s_{i}(s_{i} + 1)/2$</span> and <span>$A^{T}$</span> becomes a <span>$n \times m$</span>
matrix
<div>$$A^{T} :=
\begin{pmatrix}
& A^{f} & \\
& A^{l} & \\
& A_{1}^{q} & \\
& \vdots & \\
& A_{n_{q}}^{q} & \\
svec(A_{11}^{s},1) & \cdots & svec(A_{1m}^{s},1) \\
\vdots & & \vdots \\
svec(A_{n_{s}1}^{s},1) & \cdots & svec(A_{n_{s}m}^{s},1)
\end{pmatrix}$$</div>

Let the constraint cone <span>$K$</span> and its dual cone <span>$K^{*}$</span> be
<div>$$\begin{align}
\mathcal{K} &:=&
\mathbb{R}^{n_{f}} &\times
\mathbb{R}^{n_{l}}_{+} \times
\mathbb{L}^{q_{1}} \times \ldots \times \mathbb{L}^{q_{n_{q}}} \times
\mathbb{S}^{s_{1}}_{+} \times \ldots \times \mathbb{S}^{s_{n_{s}}}_{+}, \\
\mathcal{K}^{*} &:=&
\{0\}^{n_{f}} &\times
\mathbb{R}^{n_{l}}_{+} \times
\mathbb{L}^{q_{1}} \times \ldots \times \mathbb{L}^{q_{n_{q}}} \times
\mathbb{S}^{s_{1}}_{+} \times \ldots \times \mathbb{S}^{s_{n_{s}}}_{+}.
\end{align}$$</div>

With these abbreviations we obtain the following block form of the conic
problem:
<div>$$\begin{array}{ll}
\text{minimize}   & c^{T} x, \\
\text{subject to} & Ax = b, \\
                  & x \in \mathcal{K},
\end{array}$$</div>
with optimal value <span>$\hat{f}_{p}$</span> and the corresponding dual problem
<div>$$\begin{array}{ll}
\text{maximize}   & b^{T} y, \\
\text{subject to} & z = c - (A)^{T} y \in \mathcal{K}^{*},
\end{array}$$</div>
with optimal value <span>$\hat{f}_{d}$</span>.  In VSDP each conic problem is fully
described by the four variables `(A, b, c, K)`.  The first two quantities
represent the affine constraints <span>$Ax = b$</span>.  The third is the primal objective
vector `c`, and the last describes the underlying cone.  The cone `K` is a
structure with four fields: `K.f`, `K.l`, `K.q`, and `K.s`.  The field `K.f`
stores the number of free variables <span>$n_{f}$</span>, the field `K.l` stores the
number of nonnegative variables <span>$n_{l}$</span>, the field `K.q` stores the
dimensions <span>$q_{1}, \ldots, q_{n_{q}}$</span> of the second order cones, and
similarly `K.s` stores the dimensions <span>$s_{1}, \ldots, s_{n_{s}}$</span> of the
semidefinite cones.  If a component of `K` is empty, then it is assumed that
the corresponding cone do not occur.

It is well known that for linear programming problems strong duality
<span>$\hat{f}_{p} = \hat{f}_{d}$</span> holds without any constraint qualifications.
General conic programs satisfy only the weak duality condition
<span>$\hat{f}_{d} \leq \hat{f}_{p}$</span>.  Strong duality requires additional
constraint qualifications, such as *Slater's constraint qualifications* (see
[[Vandenberghe1996]](https://vsdp.github.io/references.html#Vandenberghe1996),
[[BenTal2001]](https://vsdp.github.io/references.html#BenTal2001)).

**Strong Duality Theorem**

* If the primal problem is strictly feasible (i.e. there exists a primal
  feasible point <span>$x$</span> in the interior of <span>$K$</span>) and <span>$\hat{f}_{p}$</span> is finite,
  then <span>$\hat{f}_{p} = \hat{f}_{d}$</span> and the dual supremum is attained.
* If the dual problem is strictly feasible (i.e. there exists some <span>$y$</span> such
  that <span>$z = c - (A)^{T} y$</span> is in the interior of <span>$K^{*}$</span>) and <span>$\hat{f}_{d}$</span>
  is finite, then <span>$\hat{f}_{d} = \hat{f}_{p}$</span>, and the primal infimum is
  attained.


In general, the primal or dual problem formulation may have optimal solutions
while its respective dual problem is infeasible, or the duality gap may be
positive at optimality.

Duality theory is central to the study of optimization.  Firstly, algorithms
are frequently based on duality (like primal-dual interior point methods),
secondly, they enable one to check whether or not a given feasible point is
optimal, and thirdly, it allows one to compute verified results efficiently.

## Interval arithmetic

For the usage of VSDP a knowledge of interval arithmetic is not required.
Intervals are only used to specify error bounds.  An interval vector or an
interval matrix is defined as a set of vectors or matrices that vary between
a lower and an upper vector or matrix, respectively.  In other words, these
are quantities with interval components.  In
[INTLAB](http://www.ti3.tu-harburg.de/rump/intlab/) these interval quantities
can be initialized with the routine `infsup`.  Equivalently, these quantities
can be defined by a midpoint-radius representation, using the routine
`midrad`.


Published with GNU Octave 4.4.0

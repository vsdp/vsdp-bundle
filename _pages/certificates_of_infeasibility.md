---
title: certificates_of_infeasibility
permalink: certificates_of_infeasibility.html
---

# certificates_of_infeasibility


* TOC
{:toc}


## Rigorous Certificates of Infeasibility

The functions `vsdplow` and `vsdpup` prove strict feasibility and compute
rigorous error bounds.  For the verification of infeasibility the function
`vsdpinfeas` can be applied.  In this section we show how to use this
function.

We consider a slightly modified second order cone problem
([[BenTal2001]](/references#BenTal2001), Example 2.4.2)

<span>$$</span>
\begin{array}{ll}
\text{minimize} & 0^{T} x, \\
\text{subject to}
& \begin{pmatrix} 1 & 0 & 0.5 \\ 0 & 1 & 0 \end{pmatrix}
  x = \begin{pmatrix} 0 \\ 1 \end{pmatrix}, \\
& x \in \mathbb{L}^{3},
\end{array}
<span>$$</span>
with its dual problem
<span>$$</span>
\begin{array}{ll}
\text{maximize} & -y_{2}, \\
\text{subject to}
& \begin{pmatrix} 0 \\ 0 \\ 0 \end{pmatrix} -
  \begin{pmatrix} 1 & 0 \\ 0 & 1 \\ 0.5 & 0 \end{pmatrix}
  y \in \mathbb{L}^{3}.
\end{array}
<span>$$</span>

Both, the primal and the dual problem, are infeasible.  We can easily prove
this fact by assuming that there exists a primal feasible point <span>$x$</span>.  This
point has to satisfy <span>$x_{3} = -2x_{1}$</span>, and therefore
<span>$x_{1} \geq \sqrt{x_{2}^{2} + (-2x_{1})^{2}}$</span>.  From the second equality
constraint we get <span>$x_{2} = 1$</span> yielding the contradiction
<span>$x_{1} \geq \sqrt{1 + 4x_{1}^{2}}$</span>.  Thus, the primal problem has no feasible
solution.  A certificateof infeasibility of the primal problem is given by
the dual unbounded ray <span>$y = \alpha (-2,1)^{T}$</span>.

The input data are

{% highlight matlab %}
clear A b c K

A = [1, 0, 0.5;
     0, 1, 0];
b = [0; 1];
c = [0; 0; 0];
K.q = 3;
{% endhighlight %}

Using the approximate solver SDPT3 we obtain a rigorous certificate of
infeasibility with the routine `vsdpinfeas`:

{% highlight matlab %}
vsdpinit('sdpt3');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'p',xt,yt,zt);
{% endhighlight %}

{% highlight text %}
error: 'vsdpinit' undefined near line 1 column 1
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

{% highlight matlab %}
isinfeas, x, y
{% endhighlight %}

{% highlight text %}
error: 'isinfeas' undefined near line 1 column 1
	in:


isinfeas, x, y

{% endhighlight %}

Hence, primal infeasibility is verified.  The return parameter `y` provides
a rigorous dual improving ray. The return parameter `x` must be `NaN`, since
we did not check dual infeasibility.

Now we try to solve the problem \eqref{SDPexample} for <span>$?? = -10^{4} < 0$</span>.
We know that in this case the problem is primal and dual infeasible.

{% highlight matlab %}
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
error: 'vsdpinit' undefined near line 1 column 1
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

{% highlight matlab %}
...
  Dual infeasible, primal improving direction found.
...
  Primal infeasible, dual improving direction found.
...
{% endhighlight %}

If we apply the routines `vsdplow` and `vsdpup`

{% highlight matlab %}
fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 1 column 22
	in:


fL = vsdplow(A,b,c,K,xt,yt,zt)
fU = vsdpup (A,b,c,K,xt,yt,zt)

{% endhighlight %}

then the bounds <span>$fL$</span>, <span>$fU$</span> are infinite, as expected.  By applying
`vsdpinfeas` we obtain

{% highlight matlab %}
[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'p',xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 1 column 40
	in:


[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'p',xt,yt,zt)

{% endhighlight %}

Since `isinfeas = 0`, primal infeasibility could not be verified, and
therefore the certificates `x`, `y` are set to `NaN`.  The reason is that
all dual improving rays `y` must satisfy
<span>$$</span>
\label{exmImpvRay}
-\sum_{i=1}^{4} y_{i} A_{i,1} =
\begin{pmatrix}
-y_{2}   & y_{1}/2 & -y_{3} \\
 y_{1}/2 & 0       & -y_{4} \\
-y_{3}   & -y_{4}  & 0
\end{pmatrix} \in \mathbb{S}^{3}_{+}.
<span>$$</span>

This is only possible for <span>$y_{1} = y_{3} = y_{4} = 0$</span>.  Hence, for each
improving ray the matrix \eqref{exmImpvRay} has a zero eigenvalue.  In VSDP
we verify positive semidefiniteness by computing enclosures of the
eigenvalues.  If all enclosures are non-negative positive semidefiniteness is
proved.  If one eigenvalue is zero then, except in special cases, the
corresponding enclosure has a negative component implying that positive
semidefinitness cannot be proved and primal infeasibility is not verified.

Now we try to verify dual infeasibility by using `vsdpinfeas` with the
parameter `'d'`.

{% highlight matlab %}
[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'d',xt,yt,zt)
{% endhighlight %}

{% highlight text %}
error: 'xt' undefined near line 1 column 40
	in:


[isinfeas,x,y] = vsdpinfeas(A,b,c,K,'d',xt,yt,zt)

{% endhighlight %}

Also dual infeasibility cannot be proved.  An easy calculation shows that the
primal improving ray must satisfy
<span>$$</span>
X = \begin{pmatrix}
0 & 0 & 0\\
0 & x_{22} & 0\\
0 & 0 & x_{33}
\end{pmatrix} \in \mathbb{S}^{3}_{+}.
<span>$$</span>

and with the same argument as above positive semidefiniteness cannot be
verified.


Published with GNU Octave 4.4.1

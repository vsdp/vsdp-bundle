---
title: a_priori_bounds
permalink: a_priori_bounds.html
---

# a_priori_bounds


* TOC
{:toc}


## A Priori Upper Bounds for Optimal Solutions

In many practical applications the order of the magnitude of a primal or dual
optimal solution is known a priori.  This is the case in many combinatorial
optimization problems, or, for instance, in truss topology design where the
design variables such as bar volumes can be roughly bounded.  If such bounds
are available they can speed up the computation of guaranteed error bounds
for the optimal value substantially, see
[[Jansson2006]](https://vsdp.github.io/references.html#Jansson2006).

For linear programming problems the upper bound for the variable <span>$x^{l}$</span>
is a vector <span>$\bar{x}$</span> such that <span>$x^{l} \leq \bar{x}$</span>.  For second
order cone programming the upper bounds for block variables <span>$x_{i}^{q}$</span>
can be entered as a vector of upper bounds <span>$\overline{\lambda}_{i}$</span> of the
largest eigenvalues <span>$\lambda_{\max}(x_{i}^{q}) = (x_{i}^{q})_{1} +
||(x_{i}^{q})_{:}||_{2}$</span>, <span>$i = 1,\ldots,n_{q}$</span>.  Similarly, for
semidefinite programs upper bounds for the primal variables <span>$X_{j}^{s}$</span>
can be entered as a vector of upper bounds of the largest eigenvalues
<span>$\lambda_{\max}(X_{j}^{s})$</span>, <span>$j = 1,\ldots,n_{s}$</span>. An upper bound
<span>$\bar{y}$</span> for the dual optimal solution <span>$y$</span> is a vector which is
componentwise larger then <span>$|y|$</span>. Analogously, for conic programs with free
variables the upper bound can be entered as a vector <span>$\bar{x}$</span> such that
<span>$|x^{f}| \leq \bar{x}$</span>.

As an example, we consider the previous SDP problem \eqref{SDPexample} with
an upper bound <span>$xu = 10^{5}$</span> for <span>$\lambda_{\max}(X)$</span>.

{% highlight matlab %}
vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
xu = 1e5;
fL = vsdplow(A,b,C,K,xt,yt,zt,xu)
{% endhighlight %}

{% highlight text %}
error: 'vsdpinit' undefined near line 1 column 1
	in:


vsdpinit('sedumi');
[objt,xt,yt,zt,info] = mysdps(A,b,c,K);
xu = 1e5;
fL = vsdplow(A,b,C,K,xt,yt,zt,xu)

{% endhighlight %}

Now, we suppose the existence of dual upper bounds

{% highlight matlab %}
yu = 1e5 * [1 1 1 1]';
fU = vsdpup(A, b, C, K, xt, yt, zt, yu)
{% endhighlight %}

{% highlight text %}
error: 'A' undefined near line 1 column 13
	in:


yu = 1e5 * [1 1 1 1]';
fU = vsdpup(A, b, C, K, xt, yt, zt, yu)

{% endhighlight %}

yielding also a reasonable bound.


Published with GNU Octave 4.4.1

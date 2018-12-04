---
title: A Priori Bounds
permalink: a_priori_bounds.html
---

# A Priori Bounds


In many practical applications the order of the magnitude of a primal or dual
optimal solution is known a priori.  This is the case in many combinatorial
optimization problems, or, for instance, in truss topology design where the
design variables such as bar volumes can be roughly bounded.  If such bounds
are available they can speed up the computation of guaranteed error bounds
for the optimal value substantially, see
[[Jansson2006]](https://vsdp.github.io/references.html#Jansson2006).

* TOC
{:toc}


For linear programming problems the upper bound for the variable <span>$x^{l}$</span>
is a vector <span>$\bar{x}$</span> such that <span>$x^{l} \leq \bar{x}$</span>.  For second
order cone programming the upper bounds for block variables <span>$x_{i}^{q}$</span>
with <span>$i = 1,\ldots,n_{q}$</span> can be entered as a vector of upper bounds
<span>$\overline{\lambda}_{i}$</span> of the largest eigenvalues
<div>$$\lambda_{\max}(x_{i}^{q}) = (x_{i}^{q})_{1} + ||(x_{i}^{q})_{:}||_{2}.$$</div>
Similarly, for semidefinite programs upper bounds for the primal variables
<span>$X_{j}^{s}$</span> can be entered as a vector of upper bounds of the largest
eigenvalues <span>$\lambda_{\max}(X_{j}^{s})$</span>, <span>$j = 1,\ldots,n_{s}$</span>. An upper bound
<span>$\bar{y}$</span> for the dual optimal solution <span>$y$</span> is a vector which is
componentwise larger then <span>$|y|$</span>. Analogously, for conic programs with free
variables the upper bound can be entered as a vector <span>$\bar{x}$</span> such that
<span>$|x^{f}| \leq \bar{x}$</span>.

As an example, we consider the previous SDP problem with an upper bound
<span>$xu = 10^{5}$</span> for <span>$\lambda_{\max}(X)$</span>.

{% highlight matlab %}
c = [  0;   1/2;      0;
      1/2; 10^(-3);   0;
       0;    0;     10^(-3) ];

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

b = [1; 10^(-4); 0; 0];

K.s = 3;

obj = vsdp (At, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
{% endhighlight %}

Now we compute approximate solutions by using `solve` and then verified
error bounds by using `rigorous_lower_bound` and `rigorous_upper_bound`:

{% highlight matlab %}
xu = 1e5;
yu = 1e5 * [1 1 1 1]';

obj.solve('sedumi') ...
   .rigorous_lower_bound(xu) ...
   .rigorous_upper_bound(yu)
{% endhighlight %}

{% highlight text %}
ans =
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 6 variables
       m  = 4 constraints
 
  and cones:
 
     K.s = [ 3 ]
 
  obj.solutions.approximate:
 
      Solver 'sedumi': Normal termination, 0.8 seconds.
 
        c'*x = 8.999974295594320e+00
        b'*y = 8.999997616802656e+00
 
 
  obj.solutions.rigorous_lower_bound:
 
      Normal termination, 0.1 seconds, 0 iterations.
 
          fL = 8.999997616802656e+00
 
  obj.solutions.rigorous_upper_bound:
 
      Normal termination, 0.0 seconds, 0 iterations.
 
          fU = 9.000042301043072e+00
 
 
 
  Detailed information:  'obj.info()'
 
 

{% endhighlight %}

yielding also a reasonable bound.


Published with GNU Octave 4.4.1

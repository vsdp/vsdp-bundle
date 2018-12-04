---
title: Second-order Cone Programming
permalink: second-order_cone_programming.html
---

# Second-order Cone Programming


* TOC
{:toc}


Consider a least squares problem from
[[ElGhaoui1997]](https://vsdp.github.io/references.html#ElGhaoui1997)

<div>$$\left\|b_{data} - A_{data}\,\hat{y}\right\|_2
= \min_{y_{3:5} \in \mathbb{R}^{3}}
\left\|b_{data} - A_{data}\,y_{3:5}\right\|_2$$</div>

with singular matrix

{% highlight matlab %}
A_data = [ 3 1 4 ;
           0 1 1 ;
          -2 5 3 ;
           1 4 5 ];
{% endhighlight %}

and right-hand side

{% highlight matlab %}
b_data = [ 0 ;
           2 ;
           1 ;
           3 ];
{% endhighlight %}

This problem can be formulated as second-order cone program in dual standard
form:

<div>$$\begin{array}{ll}
\text{maximize}   & -y_{1} - y_{2}, \\
\text{subject to}
& y_{1} \geq \| (b_{data} - A_{data}\,y_{3:5} ) \|_{2}, \\
& y_{2} \geq
\begin{Vmatrix}\begin{pmatrix} 1 \\ y_{3:5} \end{pmatrix}\end{Vmatrix}_{2}, \\
& y \in \mathbb{R}^{5}.
\end{array}$$</div>

The two inequality constraints can be written as second-order cone vectors

<div>$$\begin{pmatrix} y_{1} \\ b_{data} - A_{data}\,y_{3:5} \end{pmatrix}
\in \mathbb{L}^{5} \quad\text{and}\quad
\begin{pmatrix} y_{2} \\ 1 \\ y_{3:5} \end{pmatrix} \in \mathbb{L}^{5}.$$</div>

Both vectors can be expressed as matrix-vector product of <span>$y$</span>

<div>$$\underbrace{\begin{pmatrix} 0 \\ b_{data} \end{pmatrix}}_{=c_{1}^{q}}
- \underbrace{\begin{pmatrix}
-1 & 0 & 0 & 0 & 0 \\
 0 & 0 & ( & A_{data} & )
\end{pmatrix}}_{=(A_{1}^{q})^{T}}
\begin{pmatrix} y_{1} \\ y_{2} \\ y_{3} \\ y_{4} \\ y_{5} \end{pmatrix}
\in \mathbb{L}^{5}$$</div>
and

<div>$$\underbrace{\begin{pmatrix} 0 \\ 1 \\ 0 \\ 0 \\ 0 \end{pmatrix}}_{=c_{2}^{q}}
- \underbrace{\begin{pmatrix}
0 & -1 &  0 &  0 &  0 \\
0 &  0 &  0 &  0 &  0 \\
0 &  0 & -1 &  0 &  0 \\
0 &  0 &  0 & -1 &  0 \\
0 &  0 &  0 &  0 & -1
\end{pmatrix}}_{=(A_{2}^{q})^{T}}
\begin{pmatrix} y_{1} \\ y_{2} \\ y_{3} \\ y_{4} \\ y_{5} \end{pmatrix}
\in \mathbb{L}^{5}.$$</div>

With these formulations, the dual problem takes the form
<div>$$\begin{array}{ll}
\text{maximize}
& \underbrace{\begin{pmatrix} -1 & -1 & 0 & 0 & 0 \end{pmatrix}}_{=b^{T}} y, \\
\text{subject to}
& z = \underbrace{\begin{pmatrix}
                  0 \\ b_{data} \\ 0 \\ 1 \\ 0 \\ 0 \\ 0
                  \end{pmatrix}}_{=c}
    - \underbrace{\begin{pmatrix}
                  -1 &  0 &  0 &  0 &  0 \\
                   0 &  0 &  ( & A_{data} & ) \\
                   0 & -1 &  0 &  0 &  0 \\
                   0 &  0 &  0 &  0 &  0 \\
                   0 &  0 & -1 &  0 &  0 \\
                   0 &  0 &  0 & -1 &  0 \\
                   0 &  0 &  0 &  0 & -1
                  \end{pmatrix}}_{=A^{T}} y \in K^{*}, \\
& y \in \mathbb{R}^{5}.
\end{array}$$</div>
where <span>$K^{*} = \mathbb{L}^{5} \times \mathbb{L}^{5}$</span>.

We want to solve this problem with SeDuMi and enter the problem data of the
primal problem.

{% highlight matlab %}
At = zeros (10, 5);
At(1,1) = -1;
At(2:5, 3:5)  = A_data;
At(6,2) = -1;
At(8:10, 3:5) = -eye(3);
b = [-1 -1 0 0 0]';
c = [ 0 b_data' 0 0 0 0 0]';
{% endhighlight %}

Apart from the data `(At,b,c)`, the vector `q = [5;5]` of the second-order
cone block sizes must be forwarded to the structure `K`:

{% highlight matlab %}
K.q = [5;5];
{% endhighlight %}

Now we compute approximate solutions by using `solve` and then verified
error bounds by using `rigorous_lower_bound` and `rigorous_upper_bound`:

{% highlight matlab %}
obj = vsdp (At, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sedumi') ...
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
     n    = 10 variables
       m  =  5 constraints
 
  and cones:
 
     K.q = [ 5, 5 ]
 
  obj.solutions.approximate:
 
      Solver 'sedumi': Normal termination, 0.3 seconds.
 
        c'*x = -2.592163303838275e+00
        b'*y = -2.592163303002506e+00
 
 
  obj.solutions.rigorous_lower_bound:
 
      Solver 'sedumi': Normal termination, 0.4 seconds, 1 iterations.
 
          fL = -2.592163303536950e+00
 
  obj.solutions.rigorous_upper_bound:
 
      Solver 'sedumi': Normal termination, 0.4 seconds, 1 iterations.
 
          fU = -2.592163296674863e+00
 
 
 
  Detailed information:  'obj.info()'
 

{% endhighlight %}

Now we analyze the resulting regularized least squares solution `y_SOCP =`
<span>$y_{3:5}$</span>

{% highlight matlab %}
y_SOCP = obj.solutions.approximate.y(3:5)
{% endhighlight %}

{% highlight text %}
y_SOCP =
  -2.2817e-02
   2.1853e-01
   1.9572e-01
 

{% endhighlight %}

and compare it to a naive least squares solution `y_LS`, which takes extreme
values in this example

{% highlight matlab %}
y_LS = A_data \ b_data
{% endhighlight %}

{% highlight text %}
y_LS =
   8.0353e+14
   8.0353e+14
  -8.0353e+14
 

{% endhighlight %}

Displaying the norms of the results side-by-side reveals, that `y_SOCP`
is better suited for numerical computations.

{% highlight matlab %}
[                  norm(y_SOCP)                    norm(y_LS);
 norm(b_data - A_data * y_SOCP)  norm(b_data - A_data * y_LS)]
{% endhighlight %}

{% highlight text %}
ans =
   2.9425e-01   1.3918e+15
   2.2979e+00   2.5125e+00
 

{% endhighlight %}

The conic programming allows to mix constraints of different types.
For instance, one can add the linear inequality
<span>$\sum_{i=1}^{5} y_{i} \leq 3.5$</span> to the previous dual problem.  We extend the
input data as follows:

{% highlight matlab %}
At = [1 1 1 1 1; At];
c =  [3.5      ; c ];
K.l = 1;
{% endhighlight %}

Note that the order of the cone variables matters for `At` and `c`:

1. `K.f` Free              variables
2. `K.l` Linear            variables
3. `K.q` Second-order cone variables
4. `K.s` Semidefinite      variables


{% highlight matlab %}
obj = vsdp (At, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sedumi') ...
   .rigorous_lower_bound() ...
   .rigorous_upper_bound();
{% endhighlight %}

Finally, one obtains

{% highlight matlab %}
disp (obj)
{% endhighlight %}

{% highlight text %}
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 11 variables
       m  =  5 constraints
 
  and cones:
 
     K.l = 1
     K.q = [ 5, 5 ]
 
  obj.solutions.approximate:
 
      Solver 'sedumi': Normal termination, 0.4 seconds.
 
        c'*x = -2.592163292321565e+00
        b'*y = -2.592163288331029e+00
 
 
  obj.solutions.rigorous_lower_bound:
 
      Solver 'sedumi': Normal termination, 0.4 seconds, 1 iterations.
 
          fL = -2.592163308073371e+00
 
  obj.solutions.rigorous_upper_bound:
 
      Normal termination, 0.0 seconds, 0 iterations.
 
          fU = -2.592163292330896e+00
 
 
 
  Detailed information:  'obj.info()'
 

{% endhighlight %}


Published with GNU Octave 4.4.1

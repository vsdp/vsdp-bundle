---
title: Second-order Cone Programming
permalink: s03_second_order_cone_programming.html
---

# Second-order Cone Programming

* TOC
{:toc}

Consider a least squares problem from
[[ElGhaoui1997]](s10_references.html#ElGhaoui1997):

$$
\left\|b_{data} - A_{data}\,\hat{y}\right\|_2
= \min_{y_{3:5} \in \mathbb{R}^{3}}
\left\|b_{data} - A_{data}\,y_{3:5}\right\|_2
$$

with singular matrix


```matlab
A_data = [ 3 1 4 ;
           0 1 1 ;
          -2 5 3 ;
           1 4 5 ];
```

and right-hand side


```matlab
b_data = [ 0 ;
           2 ;
           1 ;
           3 ];
```

This problem can be formulated as second-order cone program in dual standard form:

$$
\begin{array}{ll}
\text{maximize}   & -y_{1} - y_{2}, \\
\text{subject to}
& y_{1} \geq \| (b_{data} - A_{data}\,y_{3:5} ) \|_{2}, \\
& y_{2} \geq
\begin{Vmatrix}\begin{pmatrix} 1 \\ y_{3:5} \end{pmatrix}\end{Vmatrix}_{2}, \\
& y \in \mathbb{R}^{5}.
\end{array}
$$

The two inequality constraints can be written as second-order cone vectors

$$
\begin{pmatrix} y_{1} \\ b_{data} - A_{data}\,y_{3:5} \end{pmatrix}
\in \mathbb{L}^{5} \quad\text{and}\quad
\begin{pmatrix} y_{2} \\ 1 \\ y_{3:5} \end{pmatrix} \in \mathbb{L}^{5}.
$$

Both vectors can be expressed as matrix-vector product of $y$

$$
\underbrace{\begin{pmatrix} 0 \\ b_{data} \end{pmatrix}}_{=c_{1}^{q}}
- \underbrace{\begin{pmatrix}
-1 & 0 & 0 & 0 & 0 \\
 0 & 0 & ( & A_{data} & )
\end{pmatrix}}_{=(A_{1}^{q})^{T}}
\begin{pmatrix} y_{1} \\ y_{2} \\ y_{3} \\ y_{4} \\ y_{5} \end{pmatrix}
\in \mathbb{L}^{5}
$$

and

$$
\underbrace{\begin{pmatrix} 0 \\ 1 \\ 0 \\ 0 \\ 0 \end{pmatrix}}_{=c_{2}^{q}}
- \underbrace{\begin{pmatrix}
0 & -1 &  0 &  0 &  0 \\
0 &  0 &  0 &  0 &  0 \\
0 &  0 & -1 &  0 &  0 \\
0 &  0 &  0 & -1 &  0 \\
0 &  0 &  0 &  0 & -1
\end{pmatrix}}_{=(A_{2}^{q})^{T}}
\begin{pmatrix} y_{1} \\ y_{2} \\ y_{3} \\ y_{4} \\ y_{5} \end{pmatrix}
\in \mathbb{L}^{5}.
$$

With these formulations, the dual problem takes the form
$$
\begin{array}{ll}
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
\end{array}
$$
where $K^{*} = \mathbb{L}^{5} \times \mathbb{L}^{5}$.

We want to solve this problem with SeDuMi and enter the problem data of the primal problem.


```matlab
At = zeros (10, 5);
At(1,1) = -1;
At(2:5, 3:5)  = A_data;
At(6,2) = -1;
At(8:10, 3:5) = -eye(3);
b = [-1 -1 0 0 0]';
c = [ 0 b_data' 0 0 0 0 0]';
```

Apart from the data `(At,b,c)`,
the vector `q = [5;5]` of the second-order cone block sizes
must be forwarded to the structure `K`:


```matlab
K.q = [5; 5];
```

Now we compute approximate solutions by using `obj.solve`
and then verified error bounds by using `obj.rigorous_lower_bound`
and `obj.rigorous_upper_bound`:


```matlab
obj = vsdp (At, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sedumi') ...
   .rigorous_lower_bound() ...
   .rigorous_upper_bound();
```

Finally, we get an overview about all the performed computations:


```matlab
obj
```

    obj =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 10 variables
           m  =  5 constraints

      and cones:

         K.q = [ 5, 5 ]

      obj.solutions.approximate:

          Solver 'sedumi': Normal termination, 0.4 seconds.

            c'*x = -2.592163303832843e+00
            b'*y = -2.592163302997335e+00


      obj.solutions.rigorous_lower_bound:

          Solver 'sedumi': Normal termination, 0.5 seconds, 1 iterations.

              fL = -2.592163303540553e+00

      obj.solutions.rigorous_upper_bound:

          Solver 'sedumi': Normal termination, 0.5 seconds, 1 iterations.

              fU = -2.592163296674519e+00



      Detailed information:  'obj.info()'




Now we analyze the resulting regularized least squares solution:


```matlab
y_SOCP = obj.solutions.approximate.y(3:5)
```

    y_SOCP =
      -0.022817
       0.218532
       0.195715



and compare it to a naive least squares solution `y_LS`,
which takes extreme values in this example


```matlab
y_LS = A_data \ b_data
```

    y_LS =
       8.0353e+14
       8.0353e+14
      -8.0353e+14



Displaying the norms of the results side-by-side reveals,
that `y_SOCP` is better suited for numerical computations.


```matlab
[                  norm(y_SOCP)                    norm(y_LS);
 norm(b_data - A_data * y_SOCP)  norm(b_data - A_data * y_LS)]
```

    ans =
       2.9425e-01   1.3918e+15
       2.2979e+00   2.5125e+00



The conic programming allows to mix constraints of different types.
For instance, one can add the linear inequality
$\sum_{i=1}^{5} y_{i} \leq 3.5$ to the previous dual problem.
We extend the input data as follows:


```matlab
At = [1 1 1 1 1; At];
c =  [3.5      ; c ];
K.l = 1;
```

Remember that the order of the cone variables matters for `At` and `c`.


```matlab
obj = vsdp (At, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sedumi') ...
   .rigorous_lower_bound() ...
   .rigorous_upper_bound();
```

Finally, one obtains


```matlab
obj
```

    obj =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 11 variables
           m  =  5 constraints

      and cones:

         K.l = 1
         K.q = [ 5, 5 ]

      obj.solutions.approximate:

          Solver 'sedumi': Normal termination, 0.4 seconds.

            c'*x = -2.592163292348387e+00
            b'*y = -2.592163288374707e+00


      obj.solutions.rigorous_lower_bound:

          Solver 'sedumi': Normal termination, 0.5 seconds, 1 iterations.

              fL = -2.592163308054316e+00

      obj.solutions.rigorous_upper_bound:

          Normal termination, 0.0 seconds, 0 iterations.

              fU = -2.592163292358021e+00



      Detailed information:  'obj.info()'




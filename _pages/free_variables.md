---
title: Free Variables
permalink: free_variables.html
---

# Free Variables


Free variables occur often in practice.  Handling free variables in interior
point algorithms is a pending issue (see for example
[[Andersen2002]](/references#Andersen2002),
[[Anjos2007]](/references#Anjos2007), and
[[Meszaros1998]](/references#Meszaros1998)).  Frequently users
convert a problem with free variables into one with restricted variables by
representing the free variables as a difference of two nonnegative variables.
This approach increases the problem size and introduces ill-posedness, which
may lead to numerical difficulties.

* TOC
{:toc}


For an example we consider the test problem _nb_L1_ from the DIMACS test
library [[Pataki2002]](/references#Pataki2002).  The problem
originates from side lobe minimization in antenna engineering.  This is a
second order cone programming problem with 915 equality constraints, 793 SOCP
blocks each of size 3, and 797 nonnegative variables.  Moreover, the problem
has two free variables that are described as the difference of four
nonnegative variables.  This problem can be loaded from the examples
directory of VSDP.  As the computation is more expensive, only the results
are reported here:

{% highlight matlab %}
load (fullfile ('..', 'test', 'nb_L1.mat'));
obj = vsdp (A, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3')
{% endhighlight %}

{% highlight text %}
ans =
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 3176 variables
       m  =  915 constraints
 
  and cones:
 
     K.l = 797
     K.q = [ 793 cones (length = 2379) ]
 
  obj.solutions.approximate:
 
      Solver 'sdpt3': Normal termination, 1610.8 seconds.
 
        c'*x = -1.301227061965544e+01
        b'*y = -1.301227082198898e+01
 
 
  Compute a rigorous lower bound:
 
    'obj = obj.rigorous_lower_bound()'
 
  Compute a rigorous upper bound:
 
    'obj = obj.rigorous_upper_bound()'
 
 
  Detailed information:  'obj.info()'
 
 

{% endhighlight %}

SDPT3 solves the problem without warnings, although it is ill-posed according
to Renegar's definition [[Renegar1994]](/references#Renegar1994).

Now we try to get rigorous error bounds using the approximation of SDPT3.

{% highlight matlab %}
obj.rigorous_lower_bound () ...
   .rigorous_upper_bound ()
{% endhighlight %}

{% highlight text %}
warning: rigorous_lower_bound: Conic solver could not find a solution for perturbed problem
ans =
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 3176 variables
       m  =  915 constraints
 
  and cones:
 
     K.l = 797
     K.q = [ 793 cones (length = 2379) ]
 
  obj.solutions.approximate:
 
      Solver 'sdpt3': Normal termination, 1610.8 seconds.
 
        c'*x = -1.301227061965544e+01
        b'*y = -1.301227082198898e+01
 
 
  obj.solutions.rigorous_lower_bound:
 
      Solver 'sdpt3': Unknown, 1434.9 seconds, 1 iterations.
 
          fL = -Inf
 
  obj.solutions.rigorous_upper_bound:
 
      Solver 'sdpt3': Normal termination, 3481.1 seconds, 2 iterations.
 
          fU = -1.301227061976696e+01
 
 
  The rigorous lower bound is infinite, check dual infeasibility:
 
    'obj = obj.check_dual_infeasible()'
 
 
  Detailed information:  'obj.info()'
 
 

{% endhighlight %}

These results reflect that the interior of the dual feasible solution set is
empty.  An ill-posed problem has the property that the distance to primal or
dual infeasibility is zero.  If as above the distance to dual infeasibility
is zero, then there are sequences of dual infeasible problems with input data
converging to the input data of the original problem. Each problem of the
sequence is dual infeasible and thus has the dual optimal solution <span>$-\infty$</span>.
Hence, the result <span>$-\infty$</span> of `rigorous_lower_bound` is exactly the limit of
the optimal values of the dual infeasible problems and reflects the fact that
the distance to dual infeasibility is zero.  This demonstrates that the
infinite bound computed by VSDP is sharp, when viewed as the limit of a
sequence of infeasible problems.  We have a similar situation if the distance
to primal infeasibility is zero.

If the free variables are not converted into restricted ones then the problem
is well-posed and a rigorous finite lower bound can be computed.

{% highlight matlab %}
load (fullfile ('..', 'test', 'nb_L1free.mat'));
obj = vsdp (A, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3')
{% endhighlight %}

{% highlight text %}
ans =
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 3174 variables
       m  =  915 constraints
 
  and cones:
 
     K.f = 2
     K.l = 793
     K.q = [ 793 cones (length = 2379) ]
 
  obj.solutions.approximate:
 
      Solver 'sdpt3': Normal termination, 1567.6 seconds.
 
        c'*x = -1.301227062329676e+01
        b'*y = -1.301227081898066e+01
 
 
  Compute a rigorous lower bound:
 
    'obj = obj.rigorous_lower_bound()'
 
  Compute a rigorous upper bound:
 
    'obj = obj.rigorous_upper_bound()'
 
 
  Detailed information:  'obj.info()'
 
 

{% endhighlight %}

By using the computed approximations we obtain the following rigorous bounds:

{% highlight matlab %}
obj.rigorous_lower_bound () ...
   .rigorous_upper_bound ()
{% endhighlight %}

{% highlight text %}
 
 
--------------------------------------------------
  VSDP.RIGOROUS_LOWER_BOUND  (iteration 1)
--------------------------------------------------
  Violated cones    (dl < 0): 4
  Max. violation     min(dl): -8.66e-13
  Perturbation  max(epsilon): +1.30e-12
 
  Solve perturbed problem using 'sdpt3'.
--------------------------------------------------
 

ans =
  VSDP conic programming problem with dimensions:
 
    [n,m] = size(obj.At)
     n    = 3174 variables
       m  =  915 constraints
 
  and cones:
 
     K.f = 2
     K.l = 793
     K.q = [ 793 cones (length = 2379) ]
 
  obj.solutions.approximate:
 
      Solver 'sdpt3': Normal termination, 1567.6 seconds.
 
        c'*x = -1.301227062329676e+01
        b'*y = -1.301227081898066e+01
 
 
  obj.solutions.rigorous_lower_bound:
 
      Solver 'sdpt3': Normal termination, 1579.5 seconds, 1 iterations.
 
          fL = -1.301227081883969e+01
 
  obj.solutions.rigorous_upper_bound:
 
      Normal termination, 6.9 seconds, 0 iterations.
 
          fU = -1.301227062100146e+01
 
 
 
  Detailed information:  'obj.info()'
 
 

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
upper bounds <span>$fU$</span>, the rigorous lower bounds <span>$fL$</span>, and the computing times
measured in seconds for the approximate solution <span>$t_s$</span>, the lower bound
<span>$t_u$</span>, and the upper bound <span>$t_l$</span>, respectively.  The table demonstrates the
drastic improvement if free variables are not split.

Independent of the transformation of the free variables the primal problems
of the *nql* instances are ill-posed.  The weak error bound of the optimal
constraints.  A solution for the *qssp180* instance is due to the large
number of equality system with 130141 equality constraints and 261365
variables has to be solved rigorously.  In the next version of VSDP the
accuracy for such large problems will be improved.


Published with GNU Octave 4.4.1

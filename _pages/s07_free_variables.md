---
title: Free Variables
permalink: s07_free_variables.html
---

# Free Variables

Free variables occur often in practice.
Handling free variables in interior point algorithms is a pending issue
(see for example
[[Andersen2002]](s10_references.html#Andersen2002),
[[Kobayashi2007]](s10_references.html#Kobayashi2007),
[[Anjos2007]](s10_references.html#Anjos2007), and
[[Meszaros1998]](s10_references.html#Meszaros1998)
Frequently users convert a problem with free variables
into one with restricted variables by representing the free variables
as a difference of two nonnegative variables.
This approach increases the problem size and introduces ill-posedness,
which may lead to numerical difficulties.

For an example we consider the test problem *nb_L1*
from the DIMACS test library [[Pataki2002]](s10_references.html#Pataki2002).
The problem originates from side lobe minimization in antenna engineering.
This is a second-order cone programming problem with 915 equality constraints,
793 SOCP blocks each of size 3,
and 797 nonnegative variables.
Moreover,
the problem has two free variables
that are described as the difference of four nonnegative variables.
This problem can be loaded from the `test` directory of VSDP.

SDPT3 solves the problem without warnings,
although it is ill-posed according to Renegar's definition
(see [[Renegar1994]](s10_references.html#Renegar1994)):


```matlab
load (fullfile ('..', 'test', 'nb_L1.mat'));
obj = vsdp (A, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3') ...
   .rigorous_lower_bound () ...
   .rigorous_upper_bound ()
```

    warning: rigorous_lower_bound: Conic solver could not find a solution for perturbed problem
    warning: called from
        rigorous_lower_bound at line 174 column 5
    ans =
      VSDP conic programming problem with dimensions:

        [n,m] = size(obj.At)
         n    = 3176 variables
           m  =  915 constraints

      and cones:

         K.l = 797
         K.q = [ 793 cones (length = 2379) ]

      obj.solutions.approximate:

          Solver 'sdpt3': Normal termination, 8.4 seconds.

            c'*x = -1.301227062429708e+01
            b'*y = -1.301227079570707e+01


      obj.solutions.rigorous_lower_bound:

          Solver 'sdpt3': Unknown, 12.5 seconds, 1 iterations.

              fL = -Inf

      obj.solutions.rigorous_upper_bound:

          Solver 'sdpt3': Normal termination, 48.6 seconds, 3 iterations.

              fU = -1.301227062938427e+01


      The rigorous lower bound is infinite, check dual infeasibility:

        'obj = obj.check_dual_infeasible()'


      Detailed information:  'obj.info()'




These results reflect that the interior of the dual feasible solution set is empty.
An ill-posed problem has the property
that the distance to primal or dual infeasibility is zero.
If as above the distance to dual infeasibility is zero,
then there are sequences of dual infeasible problems with input data
converging to the input data of the original problem.
Each problem of the sequence is dual infeasible
and thus has the dual optimal solution $-\infty$.
Hence, the result $-\infty$ of `vsdp.rigorous_lower_bound`
is exactly the limit of the optimal values of the dual infeasible problems
and reflects the fact that the distance to dual infeasibility is zero.
This demonstrates that the infinite bound computed by VSDP is sharp,
when viewed as the limit of a sequence of infeasible problems.
We have a similar situation if the distance to primal infeasibility is zero.

If the free variables are not converted into restricted ones,
then the problem is well-posed
and a rigorous finite lower bound can be computed:


```matlab
load (fullfile ('..', 'test', 'nb_L1free.mat'));
obj = vsdp (A, b, c, K);
obj.options.VERBOSE_OUTPUT = false;
obj.solve('sdpt3') ...
   .rigorous_lower_bound () ...
   .rigorous_upper_bound ()
```

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

          Solver 'sdpt3': Normal termination, 7.9 seconds.

            c'*x = -1.301227061722163e+01
            b'*y = -1.301227081900150e+01


      obj.solutions.rigorous_lower_bound:

          Solver 'sdpt3': Normal termination, 33.2 seconds, 2 iterations.

              fL = -1.301227081922624e+01

      obj.solutions.rigorous_upper_bound:

          Normal termination, 5.7 seconds, 0 iterations.

              fU = -1.301227061912123e+01



      Detailed information:  'obj.info()'




Therefore,
without splitting the free variables,
we get rigorous finite lower and upper bounds
of the exact optimal value with an accuracy of about eight decimal digits.
Moreover,
verified interior solutions are computed for both the primal and the dual problem,
proving strong duality.

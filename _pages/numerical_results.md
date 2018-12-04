---
title: Numerical Results
permalink: numerical_results.html
---

# Numerical Results


{% highlight text %}
"If error analysis could be automated, the mysteries of floating-point
arithmetic could remain hidden; the computer would append to every
displayed numerical result a modest over-estimate of its uncertainty due
to imprecise data and approximate arithmetic, or else explain what went
wrong, and all at a cost not much higher than if no error analysis had
been performed.  So far, every attempt to achieve this ideal has been
thwarted."
{% endhighlight %}

-- W. M. Kahan, The Regrettable Failure of Automated Error Analysis, 1989
[https://www.seas.upenn.edu/~sweirich/types/archive/1989/msg00057.html](https://www.seas.upenn.edu/~sweirich/types/archive/1989/msg00057.html)

In this section, we present statistics for the numerical results obtained
by VSDP for conic programming problems.  The tests were performed using
approximations computed by the conic solvers: CSDP, MOSEK, SDPA, SDPT3,
and SeDuMi.  For second order cone programming problems only MOSEK, SDPT3,
and SeDuMi were used.  The solvers have been called with their default
parameters.  Almost all of the problems that could not be solved with a
guaranteed accuracy about <span>$10^{-7}$</span> are known to be ill-posed
(cf. [[Freund2003]](/references#Freund2003)).

We measure the accuracy of two numbers
<div>$$\mu(a,b) := \dfrac{a-b}{\max\{1.0, (|a|+|b|)/2\}}.$$</div>

Notice that we do not use the absolute value of <span>$a - b$</span>.  Hence, a negative
sign implies that <span>$a < b$</span>.

* TOC
{:toc}


## A preview of the numerical results from 2018

* [/_pages/tables/2018_12_04/SDPLIB_SYS1.html](/_pages/tables/2018_12_04/SDPLIB_SYS1.html)
* [/_pages/tables/2018_12_04/SDPLIB_SYS2.html](/_pages/tables/2018_12_04/SDPLIB_SYS2.html)
* [/_pages/tables/2018_12_04/SPARSE_SDP_SYS1.html](/_pages/tables/2018_12_04/SPARSE_SDP_SYS1.html)
* [/_pages/tables/2018_12_04/SPARSE_SDP_SYS2.html](/_pages/tables/2018_12_04/SPARSE_SDP_SYS2.html)
* [/_pages/tables/2018_12_04/DIMACS_SYS2.html](/_pages/tables/2018_12_04/DIMACS_SYS2.html)
* [/_pages/tables/2018_12_04/ESC_SYS2_SDPT3.html](/_pages/tables/2018_12_04/ESC_SYS2_SDPT3.html)
* [/_pages/tables/2018_12_04/ESC_SYS2_MOSEK.html](/_pages/tables/2018_12_04/ESC_SYS2_MOSEK.html)
* [/_pages/tables/2018_12_04/RDM_SYS2_MOSEK.html](/_pages/tables/2018_12_04/RDM_SYS2_MOSEK.html)


## SDPLIB

In the following, we describe the numerical results for problems from the
SDPLIB suite of Borchers
[[Borchers1999]](/references#Borchers1999).  In
[[Freund2007]](/references#Freund2007) it is shown that four
problems are infeasible, and 32 problems are ill-posed.

VSDP could compute rigorous bounds of the optimal values for all feasible
well-posed problems and verify the existence of strictly primal and dual
feasible solutions.  Hence, strong duality is proved. For the 32 ill-posed
problems VSDP has computed the upper bound <span>$fU = \infty$</span>, which reflects the
fact that the distance to the next primal infeasible problem is zero.  For
the four infeasible problems VSDP could compute rigorous certificates of
infeasibility.  Detailed numerical results can be found in Table
[benchmark_sdplib_2012_12_12.html](benchmark_sdplib_2012_12_12.html), where the computed rigorous upper bound
<span>$fU$</span>, the rigorous lower bound <span>$fL$</span>, and the rigorous error bound <span>$\mu(fU,fL)$</span>
are displayed.  We have set <span>$\mu(fU,fL) = NaN$</span> if the upper or the lower bound
is infinite.  Table [benchmark_sdplib_2012_12_12.html](benchmark_sdplib_2012_12_12.html) also contains
running times in seconds, where <span>$t_{s}$</span> is the time for computing the
approximations, and <span>$t_{u}$</span> and <span>$t_{l}$</span> are the times for computing the upper
and the lower rigorous error bounds, respectively.

Some major characteristics of our numerical results for the SDPLIB are
summarized below.

{% highlight matlab %}
disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_sdplib_2012_12_12.csv')))
{% endhighlight %}

{% highlight text %}
error: 'print_csv_table_statistic' undefined near line 1 column 6
	in:


disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_sdplib_2012_12_12.csv')))

{% endhighlight %}

It displays in the first row the median <span>$\operatorname{med}(\mu(fU,fL))$</span> of
the computed error bounds, in the second row the largest error bound
<span>$\max(\mu(fU,fL))$</span>, and in the third row the minimal error bound
<span>$\min(\mu(fU,fL))$</span>.  For this statistic only the well-posed problems are taken
into account.  In the two last rows the medians of time ratios
<span>$t_{u} / t_{s}$</span> and <span>$t_{l} / t_{s}$</span> are displayed.

The median of <span>$\mu(fU,fL)$</span> shows that for all conic solvers rigorous error
bounds with 7 or 8 significant decimal digits could be computed for most
problems.

Furthermore, the table shows that the error bounds as well as the time ratios
depend significantly on the used conic solver.  In particular the resulting
time ratios indicate that the conic solvers CSDP and SeDuMi aim to compute
approximate primal interior <span>$\varepsilon$</span>-optimal solutions.  In contrast
SDPA and SDPT3 aim to compute dual interior <span>$\varepsilon$</span>-optimal solutions.

Even the largest problem *MaxG60* with about 24 million variables and 7000
constraints can be solved rigorously by VSDP, with high accuracy and in a
reasonable time.

## DIMACS

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

{% highlight matlab %}
disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_dimacs_2012_12_12.csv')))
{% endhighlight %}

{% highlight text %}
error: 'print_csv_table_statistic' undefined near line 1 column 6
	in:


disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_dimacs_2012_12_12.csv')))

{% endhighlight %}

The approximate solvers SDPA and CSDP are designed for SDP problems only.
Hence, in the table above we have displayed for these solvers only the
statistic of the SDP problems.

Detailed results can be found in Table [benchmark_dimacs_2012_12_12.html](benchmark_dimacs_2012_12_12.html).

## Kovcara's Library of Structural Optimization Problems

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
of this collection VSDP could compute a rigorous primal and dual <span>$\varepsilon$</span>-optimal
solution.  Caused by the limited available memory and the great computational
times the largest problems *mater-5*, *mater-6*, *shmup5*, *trto5*, and
*vibra5* has been tested only with the solver SDPT3.  The largest problem
that was rigorously solved by VSDP is *shmup5*.  This problem has 1800
equality constraints and 13849441 variables.

A statistic of these numerical experiments is given below:

{% highlight matlab %}
disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_kovcara_2012_12_12.csv')))
{% endhighlight %}

{% highlight text %}
error: 'print_csv_table_statistic' undefined near line 1 column 6
	in:


disp(print_csv_table_statistic(fullfile('doc', ...
  'benchmark_kovcara_2012_12_12.csv')))

{% endhighlight %}

Detailed results can be found in Table [benchmark_kovcara_2012_12_12.html](benchmark_kovcara_2012_12_12.html).


Published with GNU Octave 4.4.1

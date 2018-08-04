---
title: Installation
---

# Installation


* TOC
{:toc}


## Requirements

To run VSDP, the following requirements have to be fulfilled:

* A recent version of [MATLAB](http://www.mathworks.com/products/matlab/) or
  [GNU Octave](http://www.octave.org/) has to be installed.
* The interval toolbox [INTLAB](http://www.ti3.tu-harburg.de/rump/intlab/) is
  required.
* At least one of the following approximate solvers has to be installed:
  [CSDP](https://github.com/coin-or/Csdp),
  [GLPK](https://www.gnu.org/software/glpk/),
  [LINPROG](https://www.mathworks.com/help/optim/ug/linprog.html),
  [lp_solve](https://lpsolve.sourceforge.io),
  [SDPA](https://sdpa.sourceforge.io),
  [SDPT3](https://github.com/sqlp/sdpt3), or
  [SeDuMi](https://github.com/sqlp/sedumi).


## Obtaining VSDP

**ZIP-File**

The most recent version of VSDP and this manual are available at
[https://vsdp.github.io](https://vsdp.github.io).  There you can download a ZIP-file
`vsdp-2018-master.zip` and extract it to an arbitrary location.

Legacy versions of VSDP are available from
[http://www.ti3.tu-harburg.de/jansson/vsdp/](http://www.ti3.tu-harburg.de/jansson/vsdp/).

**Using git**

If you have [git](https://git-scm.com/) installed and about 700 MB of disk
space available, you can easily obtain a full bundle of VSDP, SDPT3, SeDuMi,
and CSDP including several benchmark libraries by the command

{% highlight matlab %}
 git clone --recurse-submodules https://github.com/vsdp/vsdp.github.io
{% endhighlight %}

In the cloned directory `vsdp.github.io/vsdp/2018` you find the latest version
of VSDP.

## Installing VSDP

If all requirements are fulfilled, just call from the MATLAB or GNU Octave
command prompt inside the VSDP directory

{% highlight matlab %}
install_vsdp
{% endhighlight %}

and all necessary paths are set and VSDP is fully functional.  To test the
latter, you can run the small builtin test suite from MATLAB via

{% highlight matlab %}
runtests ('testVSDP')
{% endhighlight %}

{% highlight text %}
Totals:
   5 Passed, 0 Failed, 0 Incomplete.
   8.2712 seconds testing time.
{% endhighlight %}

or from GNU Octave via

{% highlight matlab %}
testVSDP
{% endhighlight %}

{% highlight text %}
Test summary
------------
{% endhighlight %}

{% highlight text %}
testSINDEX      PASSED  0.036834
testSVEC_SMAT   PASSED  0.277806
testLP          PASSED  0.923324
testSOCP        PASSED  0.918687
testSDP         PASSED  1.242036
{% endhighlight %}


Published with GNU Octave 4.4.0

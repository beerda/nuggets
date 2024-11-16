
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nuggets

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/nuggets)](https://CRAN.R-project.org/package=nuggets)
[![Codecov test
coverage](https://codecov.io/gh/beerda/nuggets/graph/badge.svg)](https://app.codecov.io/gh/beerda/nuggets)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/nuggets)](https://cran.r-project.org/package=nuggets)
[![R-CMD-check](https://github.com/beerda/nuggets/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/beerda/nuggets/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/beerda/nuggets/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/beerda/nuggets/actions/workflows/test-coverage.yaml)
<!-- badges: end -->

Extensible R framework for **subgroup discovery** ([Atzmueller
(2015)](https://doi.org/10.1002/widm.1144)), **contrast patterns**
([Chen (2022)](https://doi.org/10.48550/arXiv.2209.13556)), **emerging
patterns** ([Dong (1999)](https://doi.org/10.1145/312129.312191)),
**association rules** ([Agrawal
(1994)](https://www.vldb.org/conf/1994/P487.PDF)), and **conditional
correlations** ([Hájek
(1978)](https://doi.org/10.1007/978-3-642-66943-9)). Both **crisp**
(Boolean, binary) and **fuzzy data** are supported. The package
generates conditions in the form of elementary conjunctions, evaluates
them on a dataset and checks the induced sub-data for interesting
statistical properties. A user-defined function may be defined to
evaluate on each generated condition to search for custom patterns.

## Installation

To install the stable version of `nuggets` from CRAN, type the following
command within the R session:

``` r
install.packages("nuggets")
```

You can also install the development version of `nuggets` from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("beerda/nuggets")
```

To start using the package, load it to the R session with:

``` r
library(nuggets)
```

## Documentation

Read the [full documentation of the nuggets
package](https://beerda.github.io/nuggets/).

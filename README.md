
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

Use the following reference to cite package `nuggets` in publications:

> Burda M (2024). “nuggets: Data Pattern Extraction Framework in R.” In
> Torra, Vicenc, Narukawa, Yasuo, Kikuchi, Hiroaki (eds.), *Modeling
> Decisions for Artificial Intelligence*, 115-126. ISBN
> 978-3-031-68208-7, <doi:10.1007/978-3-031-68208-7_10>
> <https://doi.org/10.1007/978-3-031-68208-7_10>,
> <https://link.springer.com/chapter/10.1007/978-3-031-68208-7_10>.

A BibTeX entry for LaTeX users is:

``` bibtex
@InProceedings{burda2024,
    title = {nuggets: Data Pattern Extraction Framework in R},
    author = {Michal Burda},
    editor = {{Torra} and {Vicenc} and {Narukawa} and {Yasuo} and {Kikuchi} and {Hiroaki}},
    booktitle = {Modeling Decisions for Artificial Intelligence},
    year = {2024},
    publisher = {Springer Nature Switzerland},
    address = {Cham},
    pages = {115--126},
    isbn = {978-3-031-68208-7},
    doi = {10.1007/978-3-031-68208-7_10},
    url = {https://link.springer.com/chapter/10.1007/978-3-031-68208-7_10},
}
```

## Getting Started

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

As some functions from the other packages are used throughout this text,
it is needed to load the `tidyverse` and `lfl` packages as well:

``` r
library(tidyverse)
library(lfl)
```

## Introduction

Package `nuggets` searches for patterns that can be described with
formulae in the form of elementary conjunctions, which are called
**conditions** in this text. The conditions are constructed from
predicates, which represent data columns. The user may select the
interpretation of conditions by selecting the underlying logic:

- **crisp (i.e. Boolean, binary) logic**, where each predicate may be
  either true (1) or false (0), and the truth value of the condition is
  computed using the laws of classical Boolean algebra; or
- **fuzzy logic**, where each predicate may have assigned a *truth
  degree* from the interval $[0, 1]$ and the truth degree of the
  conjunction is computed with a selected *triangular norm (t-norm)*.
  Package `nuggets` allows to work with three most common t-norms:
  *Goedel* (minimum), *Goguen* (product), and *Lukasiewicz*. Let
  $a, b \in [0, 1]$ be the truth degrees of two predicates. Goedel
  t-norm is defined as $\min(a, b)$, Goguen t-norm as $a \cdot b$, and
  Lukasiewicz t-norm as $\max(0, a + b - 1)$.

Before analyzed by `nuggets`, the data columns that would serve as
predices in conditions have to be either dichotomized or transformed to
fuzzy sets. The package provides functions for both transformations. See
the section **Data Preparation** for more details.

`nuggets` provides functions to search for patterns of pre-defined
types, such as `dig_implications()` for implicative rules,
`dig_contrasts()` for contrast patterns, and `dig_correlations()` for
conditional correlations. See the section **Pre-defined Patterns** for
more details.

The user may also define a custom function to evaluate the conditions
and search for patterns of a different type. `dig()` function is a
general function that allows to search for patterns of any type.
`dig_grid()` function is a wrapper around `dig()` that allows to search
for patterns defined by conditions and a pair of columns, whose
combination is evaluated by the user-defined function. See the section
**Custom Patterns** for more details.

## Data Preparation

### Preparations for Crisp (Boolean) Conditions

For patterns based on crisp conditions, the data columns that would
serve as predicates in conditions have to be transformed to logical
(`TRUE`/`FALSE`) data:

- numeric columns have to be transformed to factors with a selected
  number of levels;
- factors have to be transformed to dummy logical columns.

Numeric columns can be transformed to factors with the `cut()` function
from the `base` package. The `cut()` function divides the range of the
data into intervals and codes the values into a factor with the level
names corresponding to the intervals.

For example, consider the `CO2` dataset from the `datasets` package:

``` r
head(CO2)
#> Grouped Data: uptake ~ conc | Plant
#>   Plant   Type  Treatment conc uptake
#> 1   Qn1 Quebec nonchilled   95   16.0
#> 2   Qn1 Quebec nonchilled  175   30.4
#> 3   Qn1 Quebec nonchilled  250   34.8
#> 4   Qn1 Quebec nonchilled  350   37.2
#> 5   Qn1 Quebec nonchilled  500   35.3
#> 6   Qn1 Quebec nonchilled  675   39.2
```

The `conc` and `uptake` columns are numeric. We can transform them to
factors with the `cut()` function by specifying the breaks, which split
the range of values into intervals. For example, we can split the `conc`
column into four intervals: (-Inf, 175\], (175, 350\], (350, 675\], and
(675, Inf). The breaks are thus `c(-Inf, 175, 350, 675, Inf)`.
Similarly, we can split the `uptake` column into three intervals: (-Inf,
10\], (10, 20\], and (20, Inf) by specifying the breaks
`c(-Inf, 10, 20, Inf)`:

``` r
crispCO2 <- CO2
crispCO2$conc <- cut(crispCO2$conc, c(-Inf, 175, 350, 675, Inf))
crispCO2$uptake <- cut(crispCO2$uptake, c(-Inf, 10, 20, Inf))
head(crispCO2)
#> Grouped Data: uptake ~ conc | Plant
#>   Plant   Type  Treatment       conc    uptake
#> 1   Qn1 Quebec nonchilled (-Inf,175]   (10,20]
#> 2   Qn1 Quebec nonchilled (-Inf,175] (20, Inf]
#> 3   Qn1 Quebec nonchilled  (175,350] (20, Inf]
#> 4   Qn1 Quebec nonchilled  (175,350] (20, Inf]
#> 5   Qn1 Quebec nonchilled  (350,675] (20, Inf]
#> 6   Qn1 Quebec nonchilled  (350,675] (20, Inf]
```

Once the numeric columns are transformed to factors, the factors can be
transformed to dummy logical columns. The `dichotomize()` function from
the `nuggets` package transforms factors to dummy logical columns. The
function creates a new column for each factor level and fills it with
logical values (`TRUE`/`FALSE`) based on the factor values:

``` r
crispCO2 <- dichotomize(crispCO2)
head(crispCO2)
#> # A tibble: 6 × 23
#>   `Plant=Qn1` `Plant=Qn2` `Plant=Qn3` `Plant=Qc1` `Plant=Qc3` `Plant=Qc2`
#>   <lgl>       <lgl>       <lgl>       <lgl>       <lgl>       <lgl>      
#> 1 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#> 2 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#> 3 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#> 4 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#> 5 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#> 6 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#> # ℹ 17 more variables: `Plant=Mn3` <lgl>, `Plant=Mn2` <lgl>, `Plant=Mn1` <lgl>,
#> #   `Plant=Mc2` <lgl>, `Plant=Mc3` <lgl>, `Plant=Mc1` <lgl>,
#> #   `Type=Quebec` <lgl>, `Type=Mississippi` <lgl>,
#> #   `Treatment=nonchilled` <lgl>, `Treatment=chilled` <lgl>,
#> #   `conc=(-Inf,175]` <lgl>, `conc=(175,350]` <lgl>, `conc=(350,675]` <lgl>,
#> #   `conc=(675, Inf]` <lgl>, `uptake=(-Inf,10]` <lgl>, `uptake=(10,20]` <lgl>,
#> #   `uptake=(20, Inf]` <lgl>
```

Note that each factor column became replaced by a set of logical
columns, all of which start with the original column name and are
followed by the factor level name. For example, the `Type` column, which
is a factor with two levels `Quebec` and `Mississippi`, was replaced by
two logical columns: `Type=Quebec` and `Type=Mississippi`. Other columns
were replaced in a similar manner:

``` r
colnames(crispCO2)
#>  [1] "Plant=Qn1"            "Plant=Qn2"            "Plant=Qn3"           
#>  [4] "Plant=Qc1"            "Plant=Qc3"            "Plant=Qc2"           
#>  [7] "Plant=Mn3"            "Plant=Mn2"            "Plant=Mn1"           
#> [10] "Plant=Mc2"            "Plant=Mc3"            "Plant=Mc1"           
#> [13] "Type=Quebec"          "Type=Mississippi"     "Treatment=nonchilled"
#> [16] "Treatment=chilled"    "conc=(-Inf,175]"      "conc=(175,350]"      
#> [19] "conc=(350,675]"       "conc=(675, Inf]"      "uptake=(-Inf,10]"    
#> [22] "uptake=(10,20]"       "uptake=(20, Inf]"
```

Now all the columns are logical and can be used as predicates in crisp
conditions.

### Preparations for Fuzzy Conditions

For patterns based on fuzzy conditions, the data columns that would
serve as predicates in conditions have to be transformed to fuzzy
predicates. The fuzzy predicate is represented by a vector of truth
degrees from the interval $[0, 1]$. The truth degree of a predicate is
the degree to which the predicate is true with 0 meaning that the
predicate is false and 1 meaning that the predicate is true. A value
between 0 and 1 indicates a partial truthfulness.

In order to search for fuzzy patterns, the numeric input data columns
have to be transformed to fuzzy predicates, i.e., to vectors of truth
degrees from the interval $[0, 1]$. (The fuzzy approach may be also used
with logical columns created from factors, as discussed in the previous
section.)

The transformation to fuzzy predicates can be done, for example, with
the help of the [lfl](https://cran.r-project.org/package=lfl) package,
which provides tools for definition of fuzzy sets of many types
including fuzzy sets that model linguistic terms such as “very small”,
“extremely big” and so on. In the following example, the `fcut` function
from the `lfl` package transforms the `CO2` dataset to fuzzy predicates
as follows:

- factors are transformed to fuzzy sets similarly as in the previous
  section;
- numeric columns are transformed into a set of columns, each
  representing a fuzzy set. The type of fuzzy sets to be created is
  specified by the `type` argument, which can be one of the following:
  `"triangle"`, `"raisedcos"`. The `breaks` argument specifies the
  breaks that define the shape of fuzzy sets. In the following example,
  both the `conc` and `uptake` columns are transformed to fuzzy sets
  with triangular membership functions. In both cases, three fuzzy sets
  are created. For `conc`, the first triangular fuzzy set is determined
  by the breaks `(-Inf, 175, 350)`, the second by `(175, 350, 675)`, and
  the third by `(350, 675, Inf)`. For `uptake`, the first triangular
  fuzzy set is determined by the breaks `(-Inf, 18, 28)`, the second by
  `(18, 28, 37)`, and the third by `(28, 37, Inf)`.

``` r
fuzzyCO2 <- fcut(CO2,
                 type = "triangle",
                 breaks = list(conc = c(-Inf, 175, 350, 675, Inf),
                               uptake = c(-Inf, 18, 28, 37, Inf)))
```

Note that the `lfl`’s `fcut` function returns an `fsets` object, which
should be converted to tibble data frame with the `as_tibble` function:

``` r
fuzzyCO2 <- as_tibble(fuzzyCO2)
colnames(fuzzyCO2)
#>  [1] "Plant=Qn1"            "Plant=Qn2"            "Plant=Qn3"           
#>  [4] "Plant=Qc1"            "Plant=Qc3"            "Plant=Qc2"           
#>  [7] "Plant=Mn3"            "Plant=Mn2"            "Plant=Mn1"           
#> [10] "Plant=Mc2"            "Plant=Mc3"            "Plant=Mc1"           
#> [13] "Type=Quebec"          "Type=Mississippi"     "Treatment=nonchilled"
#> [16] "Treatment=chilled"    "conc=1"               "conc=2"              
#> [19] "conc=3"               "uptake=1"             "uptake=2"            
#> [22] "uptake=3"
```

See the [`lfl`
documentation](https://github.com/beerda/lfl/blob/master/vignettes/main.pdf)
for more possibilities of defining fuzzy sets such as by using
linguistic expressions like “very small”, “extremely big” and so on.

## Pre-defined Patterns

`nuggets` provides a set of functions for searching for some best-known
pattern types. These functions allow to process Boolean data, fuzzy
data, or both. The result of these functions is always a tibble with
patterns stored as rows. For more advance usage, which allows to search
for custom patterns or to compute user-defined measures and statistics,
see the section **Custom Patterns**.

### Search for Implicative Rules

Implicative patterns are rules of the form $A \Rightarrow B$, where $A$
is either Boolean or fuzzy condition in the form of conjunction, and $B$
is a Boolean or fuzzy predicate.

Before continuing with the search for rules, it is advisable to create
the so-called *vector of disjoints*. The vector of disjoints is a
character vector with the same length as the number of columns in the
analyzed dataset. It specifies predicates, which are mutually exclusive
and should not be combined together in a single pattern’s condition:
columns with equal values in the disjoint vector will not appear in a
single condition. Providing the vector of disjoints to the algorithm
will speed-up the search as it makes no sense, e.g., to combine
`Plant=Qn1` and `Plant=Qn2` in a condition `Plant=Qn1 & Plant=Qn2` as
such formula is never true for any data row.

The vector of disjoints can be easily created from the column names of
the dataset, e.g., by obtaining the first part of column names before
the equal sign as follows:

``` r
disj <- sub("=.*", "", colnames(fuzzyCO2))
print(disj)
#>  [1] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#>  [7] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#> [13] "Type"      "Type"      "Treatment" "Treatment" "conc"      "conc"     
#> [19] "conc"      "uptake"    "uptake"    "uptake"
```

The function `dig_implications` takes the analyzed dataset as its first
parameter and a pair of `tidyselect` expressions to select the column
names to appear in the left-hand (antecedent) and right-hand
(consequent) side of the rule. The following command searches for
implicative rules, such that:

- any column except those starting with “Treatment” is in the
  antecedent;
- any column starting with “Treatment” is in the consequent;
- the minimum support is 0.02 (support is the proportion of rows that
  satisfy the antecedent AND consequent));
- the minimum confidence is 0.8 (confidence is the proportion of rows
  satisfying the consequent GIVEN the antecedent is true).

``` r
result <- dig_implications(fuzzyCO2,
                           antecedent = !starts_with("Treatment"),
                           consequent = starts_with("Treatment"),
                           disjoint = disj,
                           min_support = 0.02,
                           min_confidence = 0.8)
```

The result is a tibble with found rules. We may arrange it by support in
descending order:

``` r
result <- arrange(result, desc(support))
print(result)
#> # A tibble: 188 × 8
#>    antecedent        consequent support confidence coverage conseq_support count
#>    <chr>             <chr>        <dbl>      <dbl>    <dbl>          <dbl> <dbl>
#>  1 {Type=Mississipp… {Treatmen…  0.135       0.895   0.151             0.5  11.4
#>  2 {Plant=Mc3}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#>  3 {Plant=Mc1}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#>  4 {Plant=Qn1}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#>  5 {Plant=Mc2}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#>  6 {Plant=Mn1}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#>  7 {Plant=Mn2}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#>  8 {Plant=Mn3}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#>  9 {Plant=Qc2}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#> 10 {Plant=Qc3}       {Treatmen…  0.0833      1       0.0833            0.5   7  
#> # ℹ 178 more rows
#> # ℹ 1 more variable: antecedent_length <int>
```

### Conditional Correlations

TBD (`dig_correlations`)

### Contrast Patterns

TBD (`dig_contrasts`)

## Custom Patterns

The `nuggets` package allows to execute a user-defined callback function
on each generated frequent condition. That way a custom type of patterns
may be searched. The following example replicates the search for
implicative rules with the custom callback function. For that, a dataset
has to be dichotomized and the disjoint vector created as in the **Data
Preparatio** section above:

``` r
head(fuzzyCO2)
#> # A tibble: 6 × 22
#>   `Plant=Qn1` `Plant=Qn2` `Plant=Qn3` `Plant=Qc1` `Plant=Qc3` `Plant=Qc2`
#>         <dbl>       <dbl>       <dbl>       <dbl>       <dbl>       <dbl>
#> 1           1           0           0           0           0           0
#> 2           1           0           0           0           0           0
#> 3           1           0           0           0           0           0
#> 4           1           0           0           0           0           0
#> 5           1           0           0           0           0           0
#> 6           1           0           0           0           0           0
#> # ℹ 16 more variables: `Plant=Mn3` <dbl>, `Plant=Mn2` <dbl>, `Plant=Mn1` <dbl>,
#> #   `Plant=Mc2` <dbl>, `Plant=Mc3` <dbl>, `Plant=Mc1` <dbl>,
#> #   `Type=Quebec` <dbl>, `Type=Mississippi` <dbl>,
#> #   `Treatment=nonchilled` <dbl>, `Treatment=chilled` <dbl>, `conc=1` <dbl>,
#> #   `conc=2` <dbl>, `conc=3` <dbl>, `uptake=1` <dbl>, `uptake=2` <dbl>,
#> #   `uptake=3` <dbl>
print(disj)
#>  [1] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#>  [7] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#> [13] "Type"      "Type"      "Treatment" "Treatment" "conc"      "conc"     
#> [19] "conc"      "uptake"    "uptake"    "uptake"
```

As we want to search for implicative rules with some minimum support and
confidence, we define the variables to hold that thresholds. We also
need to define a callback function that will be called for each found
frequent condition. Its purpose is to generate the rules with the
obtained condition as an antecedent:

``` r
min_support <- 0.02
min_confidence <- 0.8

f <- function(condition, support, foci_supports) {
    conf <- foci_supports / support
    sel <- !is.na(conf) & conf >= min_confidence & !is.na(foci_supports) & foci_supports >= min_support
    conf <- conf[sel]
    supp <- foci_supports[sel]
    
    lapply(seq_along(conf), function(i) { 
      list(antecedent = format_condition(names(condition)),
           consequent = format_condition(names(conf)[[i]]),
           support = supp[[i]],
           confidence = conf[[i]])
    })
}
```

The callback function `f()` defines three arguments: `condition`,
`support` and `foci_supports`. The names of the arguments are not
random. Based on the argument names of the callback function, the
searching algorithm provides information to the function. Here
`condition` is a vector of indices representing the conjunction of
predicates in a condition. By the predicate we mean the column in the
source dataset. The `support` argument gets the relative frequency of
the condition in the dataset. `foci_supports` is a vector of supports of
special predicates, which we call “foci” (plural of “focus”), within the
rows satisfying the condition. For implicative rules, foci are potential
rule consequents.

Now we can run the digging for rules:

``` r
result <- dig(fuzzyCO2,
              f = f,
              condition = !starts_with("Treatment"),
              focus = starts_with("Treatment"),
              disjoint = disj,
              min_length = 1,
              min_support = min_support)
```

As we return a list of lists in the callback function, we have to
flatten the first level of lists in the result and binding it into a
data frame:

``` r
result <- result %>%
  unlist(recursive = FALSE) %>%
  map(as_tibble) %>%
  do.call(rbind, .) %>%
  arrange(desc(support))

print(result)
#> # A tibble: 188 × 4
#>    antecedent                  consequent             support confidence
#>    <chr>                       <chr>                    <dbl>      <dbl>
#>  1 {Type=Mississippi,uptake=2} {Treatment=nonchilled}  0.135       0.895
#>  2 {Plant=Mc3}                 {Treatment=chilled}     0.0833      1    
#>  3 {Plant=Mc1}                 {Treatment=chilled}     0.0833      1    
#>  4 {Plant=Qn1}                 {Treatment=nonchilled}  0.0833      1    
#>  5 {Plant=Mc2}                 {Treatment=chilled}     0.0833      1    
#>  6 {Plant=Mn1}                 {Treatment=nonchilled}  0.0833      1    
#>  7 {Plant=Mn2}                 {Treatment=nonchilled}  0.0833      1    
#>  8 {Plant=Mn3}                 {Treatment=nonchilled}  0.0833      1    
#>  9 {Plant=Qc2}                 {Treatment=chilled}     0.0833      1    
#> 10 {Plant=Qc3}                 {Treatment=chilled}     0.0833      1    
#> # ℹ 178 more rows
```

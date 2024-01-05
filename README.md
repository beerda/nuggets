
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nuggets

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/nuggets)](https://CRAN.R-project.org/package=nuggets)
[![R-CMD-check](https://github.com/beerda/nuggets/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/beerda/nuggets/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/beerda/nuggets/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/beerda/nuggets/actions/workflows/test-coverage.yaml)
[![Codecov test
coverage](https://codecov.io/gh/beerda/nuggets/branch/main/graph/badge.svg)](https://app.codecov.io/gh/beerda/nuggets?branch=main)
<!-- badges: end -->

Extensible R framework for subgroup discovery ([Atzmueller
(2015)](https://doi.org/10.1002/widm.1144)), contrast patterns ([Chen
(2022)](https://doi.org/10.48550/arXiv.2209.13556)), emerging patterns
([Dong (1999)](https://doi.org/10.1145/312129.312191)) and association
rules ([Agrawal (1994)](https://www.vldb.org/conf/1994/P487.PDF)). Both
crisp (binary) and fuzzy data are supported. It generates conditions in
the form of elementary conjunctions, evaluates them on a dataset and
checks the induced sub-data for interesting statistical properties.
Currently, the package searches for implicative association rules and
conditional correlations ([Hájek
(1978)](https://doi.org/10.1007/978-3-642-66943-9)). A user-defined
function may be defined to evaluate on each generated condition to
search for custom patterns.

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

## Examples

### Search for Implicative Rules

We start with loading of the needed packages:

``` r
library(tidyverse)
library(nuggets)
```

We are going to use the `CO2` dataset as an example:

``` r
head(CO2)
#>   Plant   Type  Treatment conc uptake
#> 1   Qn1 Quebec nonchilled   95   16.0
#> 2   Qn1 Quebec nonchilled  175   30.4
#> 3   Qn1 Quebec nonchilled  250   34.8
#> 4   Qn1 Quebec nonchilled  350   37.2
#> 5   Qn1 Quebec nonchilled  500   35.3
#> 6   Qn1 Quebec nonchilled  675   39.2
```

First, the numeric columns need to be transformed to factors:

``` r
d <- mutate(CO2,
            conc = cut(conc, c(-Inf, 175, 350, 675, Inf)),
            uptake = cut(uptake, c(-Inf, 17.9, 28.3, 37.12)))
head(d)
#>   Plant   Type  Treatment       conc      uptake
#> 1   Qn1 Quebec nonchilled (-Inf,175] (-Inf,17.9]
#> 2   Qn1 Quebec nonchilled (-Inf,175] (28.3,37.1]
#> 3   Qn1 Quebec nonchilled  (175,350] (28.3,37.1]
#> 4   Qn1 Quebec nonchilled  (175,350]        <NA>
#> 5   Qn1 Quebec nonchilled  (350,675] (28.3,37.1]
#> 6   Qn1 Quebec nonchilled  (350,675]        <NA>
```

Then every column can be dichotomized, i.e., dummy logical columns may
be created for each factor level:

``` r
d <- dichotomize(d)
head(d)
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
#> #   `conc=(675, Inf]` <lgl>, `uptake=(-Inf,17.9]` <lgl>,
#> #   `uptake=(17.9,28.3]` <lgl>, `uptake=(28.3,37.1]` <lgl>
```

Before starting to search for the rules, it is good idea to create the
vector of disjoints. Columns with equal values in the disjoint vector
will not be combined together. This will speed-up the search as it makes
no sense, e.g., to combine `Plant=Qn1` and `Plant=Qn2` in a single
condition.

``` r
disj <- sub("=.*", "", colnames(d))
print(disj)
#>  [1] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#>  [7] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#> [13] "Type"      "Type"      "Treatment" "Treatment" "conc"      "conc"     
#> [19] "conc"      "conc"      "uptake"    "uptake"    "uptake"
```

Once the data are prepared, the `dig_implications` function may be
invoked. It takes the dataset as its first parameter and a pair of
“tidyselect” expressions to select the column names to appear in the
left- and right-hand side of the rule (antecedent and consequent).

``` r
result <- dig_implications(d,
                           antecedent = !starts_with("Treatment"),
                           consequent = starts_with("Treatment"),
                           disjoint = disj,
                           min_support = 0.02,
                           min_confidence = 0.8)

result <- arrange(result, desc(support))
print(result)
#> # A tibble: 225 × 7
#>    antecedent                 consequent support confidence coverage  lift count
#>    <chr>                      <chr>        <dbl>      <dbl>    <dbl> <dbl> <dbl>
#>  1 {Type=Mississippi,uptake=… {Treatmen…  0.155       0.813   0.190   1.63    16
#>  2 {Type=Mississippi,uptake=… {Treatmen…  0.119       1       0.119   2       10
#>  3 {Plant=Qn1}                {Treatmen…  0.0833      1       0.0833  2        7
#>  4 {Plant=Qn2}                {Treatmen…  0.0833      1       0.0833  2        7
#>  5 {Plant=Qn3}                {Treatmen…  0.0833      1       0.0833  2        7
#>  6 {Plant=Qc1}                {Treatmen…  0.0833      1       0.0833  2        7
#>  7 {Plant=Qc3}                {Treatmen…  0.0833      1       0.0833  2        7
#>  8 {Plant=Qc2}                {Treatmen…  0.0833      1       0.0833  2        7
#>  9 {Plant=Mn3}                {Treatmen…  0.0833      1       0.0833  2        7
#> 10 {Plant=Mn2}                {Treatmen…  0.0833      1       0.0833  2        7
#> # ℹ 215 more rows
```

### Custom Pattern Search

The `nuggets` package allows to execute a user-defined callback function
on each generated frequent condition. That way a custom type of patterns
may be searched. The following example replicates the search for
implicative rules with the custom callback function. For that, a dataset
has to be dichotomized and the disjoint vector created as in the
previous example:

``` r
head(d)
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
#> #   `conc=(675, Inf]` <lgl>, `uptake=(-Inf,17.9]` <lgl>,
#> #   `uptake=(17.9,28.3]` <lgl>, `uptake=(28.3,37.1]` <lgl>
print(disj)
#>  [1] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#>  [7] "Plant"     "Plant"     "Plant"     "Plant"     "Plant"     "Plant"    
#> [13] "Type"      "Type"      "Treatment" "Treatment" "conc"      "conc"     
#> [19] "conc"      "conc"      "uptake"    "uptake"    "uptake"
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
result <- dig(d,
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
#> # A tibble: 225 × 4
#>    antecedent                            consequent           support confidence
#>    <chr>                                 <chr>                  <dbl>      <dbl>
#>  1 {Type=Mississippi,uptake=(-Inf,17.9]} {Treatment=chilled}   0.155       0.813
#>  2 {Type=Mississippi,uptake=(28.3,37.1]} {Treatment=nonchill…  0.119       1    
#>  3 {Plant=Qn1}                           {Treatment=nonchill…  0.0833      1    
#>  4 {Plant=Qn2}                           {Treatment=nonchill…  0.0833      1    
#>  5 {Plant=Qn3}                           {Treatment=nonchill…  0.0833      1    
#>  6 {Plant=Qc1}                           {Treatment=chilled}   0.0833      1    
#>  7 {Plant=Qc3}                           {Treatment=chilled}   0.0833      1    
#>  8 {Plant=Qc2}                           {Treatment=chilled}   0.0833      1    
#>  9 {Plant=Mn3}                           {Treatment=nonchill…  0.0833      1    
#> 10 {Plant=Mn2}                           {Treatment=nonchill…  0.0833      1    
#> # ℹ 215 more rows
```

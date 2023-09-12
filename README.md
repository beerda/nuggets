
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nuggets

<!-- badges: start -->

[![R-CMD-check](https://github.com/beerda/nuggets/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/beerda/nuggets/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

R package for searching the subspaces described with elementary
conjunctions

## Installation

You can install the development version of nuggets from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("beerda/nuggets")
```

## Examples

### Search for implicative rules

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

As we want to search for implicative rules with some minimum support and
confidence, we define the variables to hold that thresholds. We also
need to define a callback function that will be called for each found
frequent condition. Its purpose is to generate the rules with the
obtained condition as an antecedent:

``` r
min_support <- 0.02
min_confidence <- 0.8

f <- function(condition, support, foci_supports) {
    ante <- paste(names(condition), collapse = " & ")
    conf <- foci_supports / support
    conf <- conf[conf > min_confidence]
    
    lapply(seq_along(conf), function(i) { 
      list(antecedent = ante,
           consequent = names(conf)[[i]],
           support = support,
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

Before starting to search for the rules, it is good idea to create the
vector of disjoints. Columns with equal values in the disjoint vector
will not be combined together. This will speed-up the search as it makes
no sense, e.g., to combine `Plant=Qn1` and `Plant=Qn2` in a single
condition.

``` r
disj <- sub("=.*", "", colnames(d))
disj <- disj[disj != "Treatment"]
print(disj)
#>  [1] "Plant"  "Plant"  "Plant"  "Plant"  "Plant"  "Plant"  "Plant"  "Plant" 
#>  [9] "Plant"  "Plant"  "Plant"  "Plant"  "Type"   "Type"   "conc"   "conc"  
#> [17] "conc"   "conc"   "uptake" "uptake" "uptake"
```

Now we can run the digging for rules:

``` r
result <- dig(as.matrix(d),
              f = f,
              condition = !starts_with("Treatment"),
              focus = starts_with("Treatment"),
              disjoint = disj,
              min_support = min_support)
```

As we return a list of lists in the callback function, we have to
flatten the first level of lists in the result and binding it into a
data frame:

``` r
result <- result %>%
  unlist(recursive = FALSE) %>%
  map(as.data.frame) %>%
  do.call(rbind, .) %>%
  arrange(desc(support))

head(result)
#>                              antecedent           consequent    support
#> 1 Type=Mississippi & uptake=(-Inf,17.9]    Treatment=chilled 0.19047619
#> 2 Type=Mississippi & uptake=(28.3,37.1] Treatment=nonchilled 0.11904762
#> 3                             Plant=Qn1 Treatment=nonchilled 0.08333333
#> 4                             Plant=Qn2 Treatment=nonchilled 0.08333333
#> 5                             Plant=Qn3 Treatment=nonchilled 0.08333333
#> 6                             Plant=Qc1    Treatment=chilled 0.08333333
#>   confidence
#> 1     0.8125
#> 2     1.0000
#> 3     1.0000
#> 4     1.0000
#> 5     1.0000
#> 6     1.0000
```

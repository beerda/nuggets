# Search for conditional correlations

**\[experimental\]**

Conditional correlations are patterns that identify strong relationships
between pairs of numeric variables under specific conditions.

- Scheme::

  `xvar ~ yvar | C`  
    
  `xvar` and `yvar` highly correlates in data that satisfy the condition
  `C`.

- Example::

  `study_time ~ test_score | hard_exam`  
    
  For *hard exams*, the amount of *study time* is highly correlated with
  the obtained exam's *test score*.

The function computes correlations between all combinations of `xvars`
and `yvars` columns of `x` in multiple sub-data corresponding to
conditions generated from `condition` columns.

## Usage

``` r
dig_correlations(
  x,
  condition = where(is.logical),
  xvars = where(is.numeric),
  yvars = where(is.numeric),
  disjoint = var_names(colnames(x)),
  excluded = NULL,
  method = "pearson",
  alternative = "two.sided",
  exact = NULL,
  min_length = 0L,
  max_length = Inf,
  min_support = 0,
  max_support = 1,
  max_results = Inf,
  verbose = FALSE,
  threads = 1
)
```

## Arguments

- x:

  a matrix or data frame with data to search in.

- condition:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use as condition predicates

- xvars:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use for computation of correlations

- yvars:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use for computation of correlations

- disjoint:

  an atomic vector of size equal to the number of columns of `x` that
  specifies the groups of predicates: if some elements of the `disjoint`
  vector are equal, then the corresponding columns of `x` will NOT be
  present together in a single condition. If `x` is prepared with
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
  using the
  [`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md)
  function on `x`'s column names is a convenient way to create the
  `disjoint` vector.

- excluded:

  NULL or a list of character vectors, where each character vector
  contains the names of columns that must not appear together in a
  single condition.

- method:

  a character string indicating which correlation coefficient is to be
  used for the test. One of `"pearson"`, `"kendall"`, or `"spearman"`

- alternative:

  indicates the alternative hypothesis and must be one of `"two.sided"`,
  `"greater"` or `"less"`. `"greater"` corresponds to positive
  association, `"less"` to negative association.

- exact:

  a logical indicating whether an exact p-value should be computed. Used
  for Kendall's *tau* and Spearman's *rho*. See
  [`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html) for more
  information.

- min_length:

  the minimum size (the minimum number of predicates) of the condition
  to be generated (must be greater or equal to 0). If 0, the empty
  condition is generated in the first place.

- max_length:

  The maximum size (the maximum number of predicates) of the condition
  to be generated. If equal to Inf, the maximum length of conditions is
  limited only by the number of available predicates.

- min_support:

  the minimum support of a condition to trigger the callback function
  for it. The support of the condition is the relative frequency of the
  condition in the dataset `x`. For logical data, it equals to the
  relative frequency of rows such that all condition predicates are TRUE
  on it. For numerical (double) input, the support is computed as the
  mean (over all rows) of multiplications of predicate values.

- max_support:

  the maximum support of a condition to trigger the callback function
  for it. See argument `min_support` for details of what is the support
  of a condition.

- max_results:

  the maximum number of generated conditions to execute the callback
  function on. If the number of found conditions exceeds `max_results`,
  the function stops generating new conditions and returns the results.
  To avoid long computations during the search, it is recommended to set
  `max_results` to a reasonable positive value. Setting `max_results` to
  `Inf` will generate all possible conditions.

- verbose:

  a logical scalar indicating whether to print progress messages.

- threads:

  the number of threads to use for parallel computation.

## Value

An S3 object which is an instance of `correlations` and `nugget` classes
and which is tibble with found patterns.

## See also

[`dig()`](https://beerda.github.io/nuggets/reference/dig.md),
[`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html)

## Author

Michal Burda

## Examples

``` r
# convert iris$Species into dummy logical variables
d <- partition(iris, Species)

# find conditional correlations between all pairs of numeric variables
dig_correlations(d,
                 condition = where(is.logical),
                 xvars = Sepal.Length:Petal.Width,
                 yvars = Sepal.Length:Petal.Width)
#> # A tibble: 24 × 10
#>    condition      support xvar  yvar  estimate  p_value method alternative  rows
#>    <chr>            <dbl> <chr> <chr>    <dbl>    <dbl> <chr>  <chr>       <int>
#>  1 {}               1     Sepa… Sepa…   -0.118 1.52e- 1 Pears… two.sided     150
#>  2 {}               1     Sepa… Peta…    0.872 1.04e-47 Pears… two.sided     150
#>  3 {}               1     Sepa… Peta…    0.818 2.33e-37 Pears… two.sided     150
#>  4 {}               1     Sepa… Peta…   -0.428 4.51e- 8 Pears… two.sided     150
#>  5 {}               1     Sepa… Peta…   -0.366 4.07e- 6 Pears… two.sided     150
#>  6 {}               1     Peta… Peta…    0.963 4.68e-86 Pears… two.sided     150
#>  7 {Species=seto…   0.333 Sepa… Sepa…    0.743 6.71e-10 Pears… two.sided      50
#>  8 {Species=seto…   0.333 Sepa… Peta…    0.267 6.07e- 2 Pears… two.sided      50
#>  9 {Species=seto…   0.333 Sepa… Peta…    0.278 5.05e- 2 Pears… two.sided      50
#> 10 {Species=seto…   0.333 Sepa… Peta…    0.178 2.17e- 1 Pears… two.sided      50
#> # ℹ 14 more rows
#> # ℹ 1 more variable: condition_length <int>

# With `condition = NULL`, dig_correlations() computes correlations between
# all pairs of numeric variables on the whole dataset only, which is an
# alternative way of computing the correlation matrix
dig_correlations(iris,
                 condition = NULL,
                 xvars = Sepal.Length:Petal.Width,
                 yvars = Sepal.Length:Petal.Width)
#> # A tibble: 6 × 10
#>   condition support xvar        yvar  estimate  p_value method alternative  rows
#>   <chr>       <dbl> <chr>       <chr>    <dbl>    <dbl> <chr>  <chr>       <int>
#> 1 {}              1 Sepal.Leng… Sepa…   -0.118 1.52e- 1 Pears… two.sided     150
#> 2 {}              1 Sepal.Leng… Peta…    0.872 1.04e-47 Pears… two.sided     150
#> 3 {}              1 Sepal.Leng… Peta…    0.818 2.33e-37 Pears… two.sided     150
#> 4 {}              1 Sepal.Width Peta…   -0.428 4.51e- 8 Pears… two.sided     150
#> 5 {}              1 Sepal.Width Peta…   -0.366 4.07e- 6 Pears… two.sided     150
#> 6 {}              1 Petal.Leng… Peta…    0.963 4.68e-86 Pears… two.sided     150
#> # ℹ 1 more variable: condition_length <int>
```

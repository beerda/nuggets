# Search for grid-based rules

**\[experimental\]**

This function creates a grid column names specified by `xvars` and
`yvars` (see
[`var_grid()`](https://beerda.github.io/nuggets/reference/var_grid.md)).
After that, it enumerates all conditions created from data in `x` (by
calling [`dig()`](https://beerda.github.io/nuggets/reference/dig.md))
and for each such condition and for each row of the grid of
combinations, a user-defined function `f` is executed on each sub-data
created from `x` by selecting all rows of `x` that satisfy the generated
condition and by selecting the columns in the grid's row.

Function is useful for searching for patterns that are based on the
relationships between pairs of columns, such as in
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md).

## Usage

``` r
dig_grid(
  x,
  f,
  condition = where(is.logical),
  xvars = where(is.numeric),
  yvars = where(is.numeric),
  disjoint = var_names(colnames(x)),
  excluded = NULL,
  allow = "all",
  na_rm = FALSE,
  type = "crisp",
  min_length = 0L,
  max_length = Inf,
  min_support = 0,
  max_support = 1,
  max_results = Inf,
  verbose = FALSE,
  threads = 1L,
  error_context = list(arg_x = "x", arg_f = "f", arg_condition = "condition", arg_xvars =
    "xvars", arg_yvars = "yvars", arg_disjoint = "disjoint", arg_excluded = "excluded",
    arg_allow = "allow", arg_na_rm = "na_rm", arg_type = "type", arg_min_length =
    "min_length", arg_max_length = "max_length", arg_min_support = "min_support",
    arg_max_support = "max_support", arg_max_results = "max_results", arg_verbose =
    "verbose", arg_threads = "threads", call = current_env())
)
```

## Arguments

- x:

  a matrix or data frame with data to search in.

- f:

  the callback function to be executed for each generated condition. The
  arguments of the callback function differ based on the value of the
  `type` argument (see below):

  - If `type = "crisp"` (that is, boolean), the callback function `f`
    must accept a single argument `pd` of type `data.frame` with single
    (if `yvars == NULL`) or two (if `yvars != NULL`) columns, accessible
    as `pd[[1]]` and `pd[[2]]`. Data frame `pd` is a subset of the
    original data frame `x` with all rows that satisfy the generated
    condition. Optionally, the callback function may accept an argument
    `nd` that is a subset of the original data frame `x` with all rows
    that do not satisfy the generated condition.

  - If `type = "fuzzy"`, the callback function `f` must accept an
    argument `d` of type `data.frame` with single (if `yvars == NULL`)
    or two (if `yvars != NULL`) columns, accessible as `d[[1]]` and
    `d[[2]]`, and a numeric argument `weights` with the same length as
    the number of rows in `d`. The `weights` argument contains the truth
    degree of the generated condition for each row of `d`. The truth
    degree is a number in the interval \\\[0, 1\]\\ that represents the
    degree of satisfaction of the condition in the original data row.

  In all cases, the function must return a list of scalar values, which
  will be converted into a single row of result of final tibble.

- condition:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use as condition predicates. The selected columns must
  be logical or numeric. If numeric, fuzzy conditions are considered.

- xvars:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns of `x`, whose names will be used as a domain for
  combinations use at the first place (xvar)

- yvars:

  `NULL` or a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns of `x`, whose names will be used as a domain for
  combinations use at the second place (yvar)

- disjoint:

  an atomic vector of size equal to the number of columns of `x` that
  specifies the groups of predicates: if some elements of the `disjoint`
  vector are equal, then the corresponding columns of `x` will NEITHER
  be present together in a single condition NOR in a single combination
  of `xvars` and `yvars`. If `x` is prepared with
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
  using the
  [`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md)
  function on `x`'s column names is a convenient way to create the
  `disjoint` vector.

- excluded:

  NULL or a list of character vectors, where each character vector
  contains the names of columns that must not appear together in a
  single condition.

- allow:

  a character string specifying which columns are allowed to be selected
  by `xvars` and `yvars` arguments. Possible values are:

  - `"all"` - all columns are allowed to be selected

  - `"numeric"` - only numeric columns are allowed to be selected

- na_rm:

  a logical value indicating whether to remove rows with missing values
  from sub-data before the callback function `f` is called

- type:

  a character string specifying the type of conditions to be processed.
  The `"crisp"` type accepts only logical columns as condition
  predicates. The `"fuzzy"` type accepts both logical and numeric
  columns as condition predicates where numeric data are in the interval
  \\\[0, 1\]\\. The callback function `f` differs based on the value of
  the `type` argument (see the description of `f` above).

- min_length:

  the minimum size (the minimum number of predicates) of the condition
  to be generated (must be greater or equal to 0). If 0, the empty
  condition is generated in the first place.

- max_length:

  the maximum size (the maximum number of predicates) of the condition
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

- error_context:

  a list of details to be used in error messages. This argument is
  useful when `dig_grid()` is called from another function to provide
  error messages, which refer to arguments of the calling function. The
  list must contain the following elements:

  - `arg_x` - the name of the argument `x` as a character string

  - `arg_condition` - the name of the argument `condition` as a
    character string

  - `arg_xvars` - the name of the argument `xvars` as a character string

  - `arg_yvars` - the name of the argument `yvars` as a character string

  - `call` - an environment in which to evaluate the error messages.

## Value

An S3 object, which is an instance of `nugget` class, and which is a
tibble with found patterns. Each row represents a single call of the
callback function `f`.

## See also

[`dig()`](https://beerda.github.io/nuggets/reference/dig.md),
[`var_grid()`](https://beerda.github.io/nuggets/reference/var_grid.md);
see also
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
and
[`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md),
as they are using this function internally.

## Author

Michal Burda

## Examples

``` r
# *** Example of crisp (boolean) patterns:
# dichotomize iris$Species
crispIris <- partition(iris, Species)

# a simple callback function that computes mean difference of `xvar` and `yvar`
f <- function(pd) {
    list(m = mean(pd[[1]] - pd[[2]]),
         n = nrow(pd))
    }

# call f() for each condition created from column `Species`
dig_grid(crispIris,
         f,
         condition = starts_with("Species"),
         xvars = starts_with("Sepal"),
         yvars = starts_with("Petal"),
         type = "crisp")
#> # A tibble: 16 × 7
#>    condition            support xvar         yvar       m     n condition_length
#>    <chr>                  <dbl> <chr>        <chr>  <dbl> <int>            <int>
#>  1 {}                     1     Sepal.Length Peta…  2.09    150                0
#>  2 {}                     1     Sepal.Length Peta…  4.64    150                0
#>  3 {}                     1     Sepal.Width  Peta… -0.701   150                0
#>  4 {}                     1     Sepal.Width  Peta…  1.86    150                0
#>  5 {Species=setosa}       0.333 Sepal.Length Peta…  3.54     50                1
#>  6 {Species=setosa}       0.333 Sepal.Length Peta…  4.76     50                1
#>  7 {Species=setosa}       0.333 Sepal.Width  Peta…  1.97     50                1
#>  8 {Species=setosa}       0.333 Sepal.Width  Peta…  3.18     50                1
#>  9 {Species=versicolor}   0.333 Sepal.Length Peta…  1.68     50                1
#> 10 {Species=versicolor}   0.333 Sepal.Length Peta…  4.61     50                1
#> 11 {Species=versicolor}   0.333 Sepal.Width  Peta… -1.49     50                1
#> 12 {Species=versicolor}   0.333 Sepal.Width  Peta…  1.44     50                1
#> 13 {Species=virginica}    0.333 Sepal.Length Peta…  1.04     50                1
#> 14 {Species=virginica}    0.333 Sepal.Length Peta…  4.56     50                1
#> 15 {Species=virginica}    0.333 Sepal.Width  Peta… -2.58     50                1
#> 16 {Species=virginica}    0.333 Sepal.Width  Peta…  0.948    50                1

# *** Example of fuzzy patterns:
# create fuzzy sets from Sepal columns
fuzzyIris <- partition(iris,
                       starts_with("Sepal"),
                       .method = "triangle",
                       .breaks = 3)

# a simple callback function that computes a weighted mean of a difference of
# `xvar` and `yvar`
f <- function(d, weights) {
    list(m = weighted.mean(d[[1]] - d[[2]], w = weights),
         w = sum(weights))
}

# call f() for each fuzzy condition created from column fuzzy sets whose
# names start with "Sepal"
dig_grid(fuzzyIris,
         f,
         condition = starts_with("Sepal"),
         xvars = Petal.Length,
         yvars = Petal.Width,
         type = "fuzzy")
#> # A tibble: 16 × 7
#>    condition                   support xvar  yvar      m      w condition_length
#>    <chr>                         <dbl> <chr> <chr> <dbl>  <dbl>            <int>
#>  1 {}                          1       Peta… Peta…  2.56 150                   0
#>  2 {Sepal.Width=(2;3.2;4.4)}   0.694   Peta… Peta…  2.56 104.                  1
#>  3 {Sepal.Length=(4.3;6.1;7.9… 0.408   Peta… Peta…  2.78  61.2                 2
#>  4 {Sepal.Length=(-Inf;4.3;6.… 0.188   Peta… Peta…  1.50  28.2                 2
#>  5 {Sepal.Length=(6.1;7.9;Inf… 0.0988  Peta… Peta…  3.70  14.8                 2
#>  6 {Sepal.Length=(4.3;6.1;7.9… 0.600   Peta… Peta…  2.74  89.9                 1
#>  7 {Sepal.Length=(4.3;6.1;7.9… 0.143   Peta… Peta…  3.06  21.5                 2
#>  8 {Sepal.Length=(4.3;6.1;7.9… 0.0486  Peta… Peta…  1.47   7.30                2
#>  9 {Sepal.Length=(-Inf;4.3;6.… 0.271   Peta… Peta…  1.59  40.7                 1
#> 10 {Sepal.Length=(-Inf;4.3;6.… 0.0472  Peta… Peta…  2.23   7.08                2
#> 11 {Sepal.Length=(-Inf;4.3;6.… 0.0364  Peta… Peta…  1.22   5.45                2
#> 12 {Sepal.Width=(-Inf;2;3.2)}  0.212   Peta… Peta…  2.96  31.8                 1
#> 13 {Sepal.Length=(6.1;7.9;Inf… 0.0218  Peta… Peta…  3.87   3.26                2
#> 14 {Sepal.Length=(6.1;7.9;Inf… 0.129   Peta… Peta…  3.76  19.3                 1
#> 15 {Sepal.Length=(6.1;7.9;Inf… 0.00833 Peta… Peta…  4.22   1.25                2
#> 16 {Sepal.Width=(3.2;4.4;Inf)} 0.0933  Peta… Peta…  1.62  14.0                 1
```

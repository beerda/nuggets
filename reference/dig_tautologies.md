# Find tautologies or "almost tautologies" in a dataset

This function finds tautologies (data-driven axioms) in a dataset, i.e.,
rules of the form `{a1 & a2 & ... & an} => {c}` where `a1`, `a2`, ...,
`an` are antecedents and `c` is a consequent that holds with very high
confidence. Such rules can serve as axioms for pruning further pattern
searches: the resulting list of rules can be passed directly to the
`excluded` argument of
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md),
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md),
or related functions via
`parse_condition(result$antecedent, result$consequent)`.

The search is performed by iteratively searching for rules with
increasing length of the antecedent. Rules found in previous iterations
are used as axioms (the `excluded` argument) in the next iteration, so
that rules whose consequent can already be deduced from a shorter
antecedent are not reported again.

## Usage

``` r
dig_tautologies(
  x,
  antecedent = everything(),
  consequent = everything(),
  disjoint = var_names(colnames(x)),
  max_length = Inf,
  min_coverage = 0,
  min_support = 0,
  min_confidence = 0,
  contingency_table = deprecated(),
  t_norm = "goguen",
  max_results = Inf,
  verbose = FALSE,
  threads = 1
)
```

## Arguments

- x:

  a matrix or data frame with data to search in. The matrix must be
  numeric (double) or logical. If `x` is a data frame then each column
  must be either numeric (double) or logical.

- antecedent:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use in the antecedent (left) part of the rules

- consequent:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use in the consequent (right) part of the rules

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

- max_length:

  The maximum length, i.e., the maximum number of predicates in the
  antecedent, of a rule to be generated. If equal to Inf, the maximum
  length is limited only by the number of available predicates.

- min_coverage:

  the minimum coverage of a rule in the dataset `x`. (See Description
  for the definition of *coverage*.)

- min_support:

  the minimum support of a rule in the dataset `x`. (See Description for
  the definition of *support*.)

- min_confidence:

  the minimum confidence of a rule in the dataset `x`. (See Description
  for the definition of *confidence*.)

- contingency_table:

  (Deprecated.) A logical value indicating whether to provide a
  contingency table for each rule. If `TRUE`, the columns `pp`, `pn`,
  `np`, and `nn` are added to the output table. These columns contain
  the number of rows satisfying the antecedent and the consequent, the
  antecedent but not the consequent, the consequent but not the
  antecedent, and neither the antecedent nor the consequent,
  respectively.

- t_norm:

  a t-norm used to compute conjunction of weights. It must be one of
  `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
  (Łukasiewicz t-norm).

- max_results:

  the maximum number of generated conditions to execute the callback
  function on. If the number of found conditions exceeds `max_results`,
  the function stops generating new conditions and returns the results.
  To avoid long computations during the search, it is recommended to set
  `max_results` to a reasonable positive value. Setting `max_results` to
  `Inf` will generate all possible conditions.

- verbose:

  a logical value indicating whether to print progress messages.

- threads:

  the number of threads to use for parallel computation.

## Value

An S3 object which is an instance of `associations` and `nugget` classes
and which is a tibble with found tautologies in the format equal to the
output of
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).

## Author

Michal Burda

## Examples

``` r
d <- partition(mtcars, .breaks = 2)
dig_tautologies(d,
                antecedent = everything(),
                consequent = everything(),
                min_confidence = 0.99)
#> # A tibble: 575 × 13
#>    antecedent  consequent support confidence coverage conseq_support  lift count
#>    <chr>       <chr>        <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>
#>  1 {gear=(-In… {carb=(-I…   0.844          1    0.844          0.938  1.07    27
#>  2 {am=(-Inf;… {carb=(-I…   0.594          1    0.594          0.938  1.07    19
#>  3 {am=(-Inf;… {gear=(-I…   0.594          1    0.594          0.844  1.19    19
#>  4 {cyl=(-Inf… {disp=(-I…   0.562          1    0.562          0.562  1.78    18
#>  5 {cyl=(-Inf… {hp=(-Inf…   0.562          1    0.562          0.781  1.28    18
#>  6 {cyl=(-Inf… {wt=(-Inf…   0.562          1    0.562          0.656  1.52    18
#>  7 {disp=(-In… {hp=(-Inf…   0.562          1    0.562          0.781  1.28    18
#>  8 {disp=(-In… {wt=(-Inf…   0.562          1    0.562          0.656  1.52    18
#>  9 {disp=(-In… {cyl=(-In…   0.562          1    0.562          0.562  1.78    18
#> 10 {vs=(-Inf;… {qsec=(-I…   0.562          1    0.562          0.719  1.39    18
#> # ℹ 565 more rows
#> # ℹ 5 more variables: antecedent_length <int>, pp <dbl>, pn <dbl>, np <dbl>,
#> #   nn <dbl>
```

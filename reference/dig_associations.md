# Search for association rules

**\[experimental\]**

Association rules identify conditions (*antecedents*) under which a
specific feature (*consequent*) is present very often.

- Scheme::

  `A => C`  
    
  If condition `A` is satisfied, then the feature `C` is present very
  often.

- Example::

  `university_edu & middle_age & IT_industry => high_income`  
    
  People in *middle age* with *university education* working in IT
  industry have very likely a *high income*.

Antecedent `A` is usually a set of predicates, and consequent `C` is a
single predicate.

For the following explanations we need a mathematical function
\\supp(I)\\, which is defined for a set \\I\\ of predicates as a
relative frequency of rows satisfying all predicates from \\I\\. For
logical data, \\supp(I)\\ equals to the relative frequency of rows, for
which all predicates \\i_1, i_2, \ldots, i_n\\ from \\I\\ are TRUE. For
numerical (double) input, \\supp(I)\\ is computed as the mean (over all
rows) of truth degrees of the formula `i_1 AND i_2 AND ... AND i_n`,
where `AND` is a triangular norm selected by the `t_norm` argument.

Association rules are characterized with the following quality measures.

*Length* of a rule is the number of elements in the antecedent.

*Coverage* of a rule is equal to \\supp(A)\\.

*Consequent support* of a rule is equal to \\supp(\\c\\)\\.

*Support* of a rule is equal to \\supp(A \cup \\c\\)\\.

*Confidence* of a rule is the fraction \\supp(A) / supp(A \cup \\c\\)\\.

*Lift* of a rule is the ratio of its support to the expected support
assuming antecedent and consequent are independent, i.e., \\supp(A \cup
\\c\\) / (supp(A) \* supp(\\c\\))\\.

## Usage

``` r
dig_associations(
  x,
  antecedent = everything(),
  consequent = everything(),
  disjoint = var_names(colnames(x)),
  excluded = NULL,
  min_length = 0L,
  max_length = Inf,
  min_coverage = 0,
  min_support = 0,
  min_confidence = 0,
  contingency_table = FALSE,
  measures = deprecated(),
  t_norm = "goguen",
  max_results = Inf,
  verbose = FALSE,
  threads = 1,
  error_context = list(arg_x = "x", arg_antecedent = "antecedent", arg_consequent =
    "consequent", arg_disjoint = "disjoint", arg_excluded = "excluded", arg_min_length =
    "min_length", arg_max_length = "max_length", arg_min_coverage = "min_coverage",
    arg_min_support = "min_support", arg_min_confidence = "min_confidence",
    arg_contingency_table = "contingency_table", arg_measures = "measures", arg_t_norm =
    "t_norm", arg_max_results = "max_results", arg_verbose = "verbose", arg_threads =
    "threads", call = current_env())
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

- excluded:

  NULL or a list of character vectors, where each character vector
  contains the names of columns that must not appear together in a
  single antecedent.

- min_length:

  the minimum length, i.e., the minimum number of predicates in the
  antecedent, of a rule to be generated. Value must be greater or equal
  to 0. If 0, rules with empty antecedent are generated in the first
  place.

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

  a logical value indicating whether to provide a contingency table for
  each rule. If `TRUE`, the columns `pp`, `pn`, `np`, and `nn` are added
  to the output table. These columns contain the number of rows
  satisfying the antecedent and the consequent, the antecedent but not
  the consequent, the consequent but not the antecedent, and neither the
  antecedent nor the consequent, respectively.

- measures:

  (Deprecated. Search for associations using
  `dig_associations(contingency_table = TRUE)` and use the
  [`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md)
  function on the result to compute additional measures.) A character
  vector specifying the additional quality measures to compute. If
  `NULL`, no additional measures are computed. Possible values are
  `"lift"`, `"conviction"`, `"added_value"`. See
  <https://mhahsler.github.io/arules/docs/measures> for a description of
  the measures.

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

- error_context:

  a named list providing context for error messages. This is mainly
  useful when `dig_associations()` is called from another function and
  you want error messages to refer to the argument names of that calling
  function. The list must contain the following elements:

  - `arg_x` - name of the argument `x`

  - `arg_antecedent` - name of the argument `antecedent`

  - `arg_consequent` - name of the argument `consequent`

  - `arg_disjoint` - name of the argument `disjoint`

  - `arg_excluded` - name of the argument `excluded`

  - `arg_min_length` - name of the argument `min_length`

  - `arg_max_length` - name of the argument `max_length`

  - `arg_min_coverage` - name of the argument `min_coverage`

  - `arg_min_support` - name of the argument `min_support`

  - `arg_min_confidence` - name of the argument `min_confidence`

  - `arg_contingency_table` - name of the argument `contingency_table`

  - `arg_measures` - name of the argument `measures`

  - `arg_t_norm` - name of the argument `t_norm`

  - `arg_max_results` - name of the argument `max_results`

  - `arg_verbose` - name of the argument `verbose`

  - `arg_threads` - name of the argument `threads`

## Value

An S3 object, which is an instance of `associations` and `nugget`
classes, and which is a tibble with found patterns and computed quality
measures.

## See also

[`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
[`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md),
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md)

## Author

Michal Burda

## Examples

``` r
d <- partition(mtcars, .breaks = 2)
dig_associations(d,
                 antecedent = !starts_with("mpg"),
                 consequent = starts_with("mpg"),
                 min_support = 0.3,
                 min_confidence = 0.8)
#> # A tibble: 524 × 9
#>    antecedent  consequent support confidence coverage conseq_support  lift count
#>    <chr>       <chr>        <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>
#>  1 {carb=(-In… {mpg=(-In…   0.344      0.846    0.406          0.719  1.18    11
#>  2 {carb=(-In… {mpg=(-In…   0.312      0.909    0.344          0.719  1.26    10
#>  3 {am=(-Inf;… {mpg=(-In…   0.312      0.909    0.344          0.719  1.26    10
#>  4 {am=(-Inf;… {mpg=(-In…   0.375      0.857    0.438          0.719  1.19    12
#>  5 {carb=(-In… {mpg=(-In…   0.5        0.889    0.562          0.719  1.24    16
#>  6 {carb=(-In… {mpg=(-In…   0.375      1        0.375          0.719  1.39    12
#>  7 {am=(-Inf;… {mpg=(-In…   0.375      1        0.375          0.719  1.39    12
#>  8 {am=(-Inf;… {mpg=(-In…   0.375      1        0.375          0.719  1.39    12
#>  9 {am=(-Inf;… {mpg=(-In…   0.375      1        0.375          0.719  1.39    12
#> 10 {am=(-Inf;… {mpg=(-In…   0.375      1        0.375          0.719  1.39    12
#> # ℹ 514 more rows
#> # ℹ 1 more variable: antecedent_length <int>
```

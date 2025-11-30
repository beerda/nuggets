# Search for patterns of a custom type

A general function for searching for patterns of a custom type. The
function allows selection of columns of `x` to be used as condition
predicates. It enumerates all possible conditions in the form of
elementary conjunctions of selected predicates, and for each condition
executes a user-defined callback function `f`. The callback is expected
to perform some analysis and return an object (often a list)
representing a pattern or patterns related to the condition. The results
of all calls are returned as a list.

## Usage

``` r
dig(
  x,
  f,
  condition = everything(),
  focus = NULL,
  disjoint = var_names(colnames(x)),
  excluded = NULL,
  min_length = 0,
  max_length = Inf,
  min_support = 0,
  min_focus_support = 0,
  min_conditional_focus_support = 0,
  max_support = 1,
  filter_empty_foci = FALSE,
  t_norm = "goguen",
  max_results = Inf,
  verbose = FALSE,
  threads = 1L,
  error_context = list(arg_x = "x", arg_f = "f", arg_condition = "condition", arg_focus =
    "focus", arg_disjoint = "disjoint", arg_excluded = "excluded", arg_min_length =
    "min_length", arg_max_length = "max_length", arg_min_support = "min_support",
    arg_min_focus_support = "min_focus_support", arg_min_conditional_focus_support =
    "min_conditional_focus_support", arg_max_support = "max_support",
    arg_filter_empty_foci = "filter_empty_foci", arg_t_norm = "t_norm", arg_max_results =
    "max_results", arg_verbose = "verbose", 
     arg_threads = "threads", call =
    current_env())
)
```

## Arguments

- x:

  A matrix or data frame. If a matrix, it must be numeric (double) or
  logical. If a data frame, all columns must be numeric (double) or
  logical.

- f:

  A callback function executed for each generated condition. It may
  declare any subset of the arguments listed below. The algorithm
  detects which arguments are present and provides only those values to
  `f`. This design allows the user to control both the amount of
  information received and the computational cost, as some arguments are
  more expensive to compute than others. The function `f` is expected to
  return an object (typically a list) representing a pattern or patterns
  related to the condition. The results of all calls of `f` are
  collected and returned as a list. Possible arguments are: `condition`,
  `sum`, `support`, `indices`, `weights`, `pp`, `pn`, `np`, `nn`, or
  `foci_supports` (deprecated), which are thoroughly described below in
  the "Details" section.

- condition:

  tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  columns of `x` to use as condition predicates

- focus:

  tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  columns of `x` to use as focus predicates

- disjoint:

  An atomic vector (length = number of columns in `x`) defining groups
  of predicates. Columns in the same group cannot appear together in a
  condition. With data from
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
  use
  [`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md)
  on column names to construct `disjoint`.

- excluded:

  `NULL` or a list of character vectors, each representing an
  implication formula. In each vector, all but the last element form the
  antecedent and the last element is the consequent. These formulae are
  treated as *tautologies* and used to filter out generated conditions.
  If a condition contains both the antecedent and the consequent of any
  such formula, it is not passed to the callback function `f`. Likewise,
  if a condition contains the antecedent, the corresponding focus (the
  consequent) is not passed to `f`.

- min_length:

  Minimum number of predicates in a condition required to trigger the
  callback `f`. Must be \\\ge 0\\. If set to 0, the empty condition also
  triggers the callback.

- max_length:

  Maximum number of predicates allowed in a condition. Conditions longer
  than `max_length` are not generated. If `Inf`, the only limit is the
  total number of available predicates. Must be \\\ge 0\\ and \\\ge
  min_length\\. This setting strongly influences both the number of
  generated conditions and the speed of the search.

- min_support:

  Minimum support of a condition required to trigger `f`. Support is the
  relative frequency of the condition in `x`. For logical data, this is
  the proportion of rows where all condition predicates are `TRUE`. For
  numeric (double) data, support is the mean (over all rows) of the
  products of predicate values. Must be in \\\[0,1\]\\. If a condition’s
  support falls below `min_support`, recursive generation of its
  extensions is stopped. Thus, `min_support` directly affects search
  speed and the number of callback calls.

- min_focus_support:

  Minimum support of a focus required for it to be passed to `f`. For
  logical data, this is the proportion of rows where both the condition
  and the focus are `TRUE`. For numeric (double) data, support is
  computed as the mean (over all rows) of a t-norm of predicate values
  (the t-norm is selected by `t_norm`). Must be in \\\[0,1\]\\. Foci
  with support below this threshold are excluded. Together with
  `filter_empty_foci`, this parameter influences both search speed and
  the number of triggered calls of `f`.

- min_conditional_focus_support:

  Minimum conditional support of a focus within a condition. Defined as
  the relative frequency of rows where the focus is `TRUE` among those
  where the condition is `TRUE`. If \\sum\\ (see `support` in *Details*)
  is the number of rows (or sum of truth degrees for fuzzy data)
  satisfying the condition, and \\pp\\ (see `pp[i]` in *Details*) is the
  sum of truth degrees where both the condition and the focus hold, then
  conditional support is \\pp / sum\\. Must be in \\\[0,1\]\\. Foci
  below this threshold are not passed to `f`. Together with
  `filter_empty_foci`, this parameter influences search speed and the
  number of callback calls.

- max_support:

  Maximum support of a condition to trigger `f`. Conditions with support
  above this threshold are skipped, but recursive generation of their
  supersets continues. Must be in \\\[0,1\]\\.

- filter_empty_foci:

  Logical; controls whether `f` is triggered for conditions with no
  remaining foci after filtering by `min_focus_support` or
  `min_conditional_focus_support`. If `TRUE`, `f` is called only when at
  least one focus remains. If `FALSE`, `f` is called regardless.

- t_norm:

  T-norm used for conjunction of weights: `"goedel"` (minimum),
  `"goguen"` (product), or `"lukas"` (Łukasiewicz).

- max_results:

  Maximum number of results (objects returned by the callback `f`) to
  store and return in the output list. When this limit is reached,
  generation of further conditions stops. Use a positive integer to
  enable early stopping; set to `Inf` to remove the cap.

- verbose:

  Logical; if `TRUE`, print progress messages.

- threads:

  Number of threads for parallel computation.

- error_context:

  A list of details to be used when constructing error messages. This is
  mainly useful when `dig()` is called from another function and errors
  should refer to the caller’s argument names rather than those of
  `dig()`. The list must contain:

  - `arg_x` – name of the argument `x` as a character string

  - `arg_f` – name of the argument `f` as a character string

  - `arg_condition` – name of the argument `condition`

  - `arg_focus` – name of the argument `focus`

  - `arg_disjoint` – name of the argument `disjoint`

  - `arg_excluded` – name of the argument `excluded`

  - `arg_min_length` – name of the argument `min_length`

  - `arg_max_length` – name of the argument `max_length`

  - `arg_min_support` – name of the argument `min_support`

  - `arg_min_focus_support` – name of the argument `min_focus_support`

  - `arg_min_conditional_focus_support` – name of the argument
    `min_conditional_focus_support`

  - `arg_max_support` – name of the argument `max_support`

  - `arg_filter_empty_foci` – name of the argument `filter_empty_foci`

  - `arg_t_norm` – name of the argument `t_norm`

  - `arg_threads` – name of the argument `threads`

  - `call` – environment in which to evaluate error messages

## Value

A list of results returned by the callback function `f`.

## Details

The callback function `f` may accept a number of arguments (see `f`
argument description). The algorithm automatically provides
condition-related information to `f` based on which arguments are
present.

In addition to conditions, the function can evaluate *focus* predicates
(foci). Foci are specified separately and are tested within each
generated condition. Extra information about them is then passed to `f`.

Restrictions may be imposed on generated conditions, such as:

- minimum and maximum condition length (`min_length`, `max_length`);

- minimum condition support (`min_support`);

- minimum focus support (`min_focus_support`), i.e. support of rows
  where both the condition and the focus hold.

Let \\P\\ be the set of condition predicates selected by `condition` and
\\E\\ be the set of focus predicates selected by `focus`. The function
generates all possible conditions as elementary conjunctions of distinct
predicates from \\P\\. These conditions are filtered using `disjoint`,
`excluded`, `min_length`, `max_length`, `min_support`, and
`max_support`.

For each remaining condition, all foci from \\E\\ are tested and
filtered using `min_focus_support` and `min_conditional_focus_support`.
If at least one focus remains (or if `filter_empty_foci = FALSE`), the
callback `f` is executed with details of the condition and foci. Results
of all calls are collected and returned as a list.

Let \\C\\ be a condition (\\C \subseteq P\\), \\F\\ the set of filtered
foci (\\F \subseteq E\\), \\R\\ the set of rows of `x`, and \\\mu_C(r)\\
the truth degree of condition \\C\\ on row \\r\\. The parameters passed
to `f` are defined as:

- `condition`: a named integer vector of column indices representing the
  predicates of \\C\\. Names correspond to column names.

- `sum`: a numeric scalar value of the number of rows satisfying \\C\\
  for logical data, or the sum of truth degrees for fuzzy data, \\sum =
  \sum\_{r \in R} \mu_C(r)\\.

- `support`: a numeric scalar value of relative frequency of rows
  satisfying \\C\\, \\supp = sum / \|R\|\\.

- `pp`, `pn`, `np`, `nn`: a numeric vector of entries of a contingency
  table for \\C\\ and \\F\\, satisfying the Ruspini condition \\pp +
  pn + np + nn = \|R\|\\. The \\i\\-th elements of these vectors
  correspond to the \\i\\-th focus \\F_i\\ from \\F\\ and are defined
  as:

  - `pp[i]`: rows satisfying both \\C\\ and \\F_i\\, \\pp_i = \sum\_{r
    \in R} \mu\_{C \land F_i}(r)\\.

  - `pn[i]`: rows satisfying \\C\\ but not \\F_i\\, \\pn_i = \sum\_{r
    \in R} \mu_C(r) - pp_i\\.

  - `np[i]`: rows satisfying \\F_i\\ but not \\C\\, \\np_i = \sum\_{r
    \in R} \mu\_{F_i}(r) - pp_i\\.

  - `nn[i]`: rows satisfying neither \\C\\ nor \\F_i\\, \\nn_i = \|R\| -
    (pp_i + pn_i + np_i)\\.

## See also

[`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
[`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md),
[`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)

## Author

Michal Burda

## Examples

``` r
library(tibble)

# Prepare iris data
d <- partition(iris, .breaks = 2)

# Simple callback: return formatted condition names
dig(x = d,
    f = function(condition) format_condition(names(condition)),
    min_support = 0.5)
#> [[1]]
#> [1] "{}"
#> 
#> [[2]]
#> [1] "{Sepal.Width=(-Inf;3.2]}"
#> 
#> [[3]]
#> [1] "{Petal.Length=(3.95;Inf],Sepal.Width=(-Inf;3.2]}"
#> 
#> [[4]]
#> [1] "{Sepal.Length=(-Inf;6.1]}"
#> 
#> [[5]]
#> [1] "{Petal.Length=(3.95;Inf]}"
#> 
#> [[6]]
#> [1] "{Petal.Width=(-Inf;1.3]}"
#> 
#> attr(,"class")
#> [1] "nugget" "list"  
#> attr(,"call_function")
#> [1] "dig"
#> attr(,"call_data")
#> attr(,"call_data")$nrow
#> [1] 150
#> 
#> attr(,"call_data")$ncol
#> [1] 11
#> 
#> attr(,"call_data")$colnames
#>  [1] "Sepal.Length=(-Inf;6.1]"  "Sepal.Length=(6.1;Inf]"  
#>  [3] "Sepal.Width=(-Inf;3.2]"   "Sepal.Width=(3.2;Inf]"   
#>  [5] "Petal.Length=(-Inf;3.95]" "Petal.Length=(3.95;Inf]" 
#>  [7] "Petal.Width=(-Inf;1.3]"   "Petal.Width=(1.3;Inf]"   
#>  [9] "Species=setosa"           "Species=versicolor"      
#> [11] "Species=virginica"       
#> 
#> attr(,"call_args")
#> attr(,"call_args")$x
#> [1] "d"
#> 
#> attr(,"call_args")$condition
#>  [1] "Sepal.Length=(-Inf;6.1]"  "Sepal.Length=(6.1;Inf]"  
#>  [3] "Sepal.Width=(-Inf;3.2]"   "Sepal.Width=(3.2;Inf]"   
#>  [5] "Petal.Length=(-Inf;3.95]" "Petal.Length=(3.95;Inf]" 
#>  [7] "Petal.Width=(-Inf;1.3]"   "Petal.Width=(1.3;Inf]"   
#>  [9] "Species=setosa"           "Species=versicolor"      
#> [11] "Species=virginica"       
#> 
#> attr(,"call_args")$focus
#> character(0)
#> 
#> attr(,"call_args")$disjoint
#>  [1] "Sepal.Length" "Sepal.Length" "Sepal.Width"  "Sepal.Width"  "Petal.Length"
#>  [6] "Petal.Length" "Petal.Width"  "Petal.Width"  "Species"      "Species"     
#> [11] "Species"     
#> 
#> attr(,"call_args")$excluded
#> NULL
#> 
#> attr(,"call_args")$min_length
#> [1] 0
#> 
#> attr(,"call_args")$max_length
#> [1] Inf
#> 
#> attr(,"call_args")$min_support
#> [1] 0.5
#> 
#> attr(,"call_args")$min_focus_support
#> [1] 0
#> 
#> attr(,"call_args")$min_conditional_focus_support
#> [1] 0
#> 
#> attr(,"call_args")$max_support
#> [1] 1
#> 
#> attr(,"call_args")$filter_empty_foci
#> [1] FALSE
#> 
#> attr(,"call_args")$t_norm
#> [1] "goguen"
#> 
#> attr(,"call_args")$max_results
#> [1] -1
#> 
#> attr(,"call_args")$verbose
#> [1] FALSE
#> 
#> attr(,"call_args")$threads
#> [1] 1
#> 

# Callback returning condition and support
res <- dig(x = d,
           f = function(condition, support) {
               list(condition = format_condition(names(condition)),
                    support = support)
           },
           min_support = 0.5)
do.call(rbind, lapply(res, as_tibble))
#> # A tibble: 6 × 2
#>   condition                                        support
#>   <chr>                                              <dbl>
#> 1 {}                                                 1    
#> 2 {Sepal.Width=(-Inf;3.2]}                           0.713
#> 3 {Petal.Length=(3.95;Inf],Sepal.Width=(-Inf;3.2]}   0.527
#> 4 {Sepal.Length=(-Inf;6.1]}                          0.633
#> 5 {Petal.Length=(3.95;Inf]}                          0.593
#> 6 {Petal.Width=(-Inf;1.3]}                           0.520

# Within each condition, evaluate also supports of columns starting with
# "Species"
res <- dig(x = d,
           f = function(condition, support, pp) {
               c(list(condition = format_condition(names(condition))),
                 list(condition_support = support),
                 as.list(pp / nrow(d)))
           },
           condition = !starts_with("Species"),
           focus = starts_with("Species"),
           min_support = 0.5,
           min_focus_support = 0)
do.call(rbind, lapply(res, as_tibble))
#> # A tibble: 6 × 5
#>   condition              condition_support `Species=setosa` `Species=versicolor`
#>   <chr>                              <dbl>            <dbl>                <dbl>
#> 1 {}                                 1                0.333                0.333
#> 2 {Sepal.Width=(-Inf;3.…             0.713            0.113                0.32 
#> 3 {Petal.Length=(3.95;I…             0.527            0                    0.247
#> 4 {Sepal.Length=(-Inf;6…             0.633            0.333                0.227
#> 5 {Petal.Length=(3.95;I…             0.593            0                    0.26 
#> 6 {Petal.Width=(-Inf;1.…             0.520            0.333                0.187
#> # ℹ 1 more variable: `Species=virginica` <dbl>

# Multiple patterns per condition based on foci
res <- dig(x = d,
           f = function(condition, support, pp) {
               lapply(seq_along(pp), function(i) {
                   list(condition = format_condition(names(condition)),
                        condition_support = support,
                        focus = names(pp)[i],
                        focus_support = pp[[i]] / nrow(d))
               })
           },
           condition = !starts_with("Species"),
           focus = starts_with("Species"),
           min_support = 0.5,
           min_focus_support = 0)

# Flatten result and convert to tibble
res <- unlist(res, recursive = FALSE)
do.call(rbind, lapply(res, as_tibble))
#> # A tibble: 18 × 4
#>    condition                               condition_support focus focus_support
#>    <chr>                                               <dbl> <chr>         <dbl>
#>  1 {}                                                  1     Spec…        0.333 
#>  2 {}                                                  1     Spec…        0.333 
#>  3 {}                                                  1     Spec…        0.333 
#>  4 {Sepal.Width=(-Inf;3.2]}                            0.713 Spec…        0.113 
#>  5 {Sepal.Width=(-Inf;3.2]}                            0.713 Spec…        0.32  
#>  6 {Sepal.Width=(-Inf;3.2]}                            0.713 Spec…        0.28  
#>  7 {Petal.Length=(3.95;Inf],Sepal.Width=(…             0.527 Spec…        0     
#>  8 {Petal.Length=(3.95;Inf],Sepal.Width=(…             0.527 Spec…        0.247 
#>  9 {Petal.Length=(3.95;Inf],Sepal.Width=(…             0.527 Spec…        0.28  
#> 10 {Sepal.Length=(-Inf;6.1]}                           0.633 Spec…        0.333 
#> 11 {Sepal.Length=(-Inf;6.1]}                           0.633 Spec…        0.227 
#> 12 {Sepal.Length=(-Inf;6.1]}                           0.633 Spec…        0.0733
#> 13 {Petal.Length=(3.95;Inf]}                           0.593 Spec…        0     
#> 14 {Petal.Length=(3.95;Inf]}                           0.593 Spec…        0.26  
#> 15 {Petal.Length=(3.95;Inf]}                           0.593 Spec…        0.333 
#> 16 {Petal.Width=(-Inf;1.3]}                            0.520 Spec…        0.333 
#> 17 {Petal.Width=(-Inf;1.3]}                            0.520 Spec…        0.187 
#> 18 {Petal.Width=(-Inf;1.3]}                            0.520 Spec…        0     
```

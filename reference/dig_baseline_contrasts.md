# Search for conditions that yield in statistically significant one-sample test in selected variables.

**\[experimental\]**

Baseline contrast patterns identify conditions under which a specific
feature is significantly different from a given value by performing a
one-sample statistical test.

- Scheme::

  `var != 0 | C`  
    
  Variable `var` is (in average) significantly different from 0 under
  the condition `C`.

- Example::

  `(measure_error != 0 | measure_tool_A `  
    
  If measuring with measure tool *A*, the average measure error is
  significantly different from 0.

The baseline contrast is computed using a one-sample statistical test,
which is specified by the `method` argument. The function computes the
contrast between all variables specified by the `vars` argument.
Baseline contrasts are computed in sub-data corresponding to conditions
generated from the `condition` columns. Function
`dig_baseline_contrasts()` supports crisp conditions only, i.e., the
condition columns in `x` must be logical.

## Usage

``` r
dig_baseline_contrasts(
  x,
  condition = where(is.logical),
  vars = where(is.numeric),
  disjoint = var_names(colnames(x)),
  excluded = NULL,
  min_length = 0L,
  max_length = Inf,
  min_support = 0,
  max_support = 1,
  method = "t",
  alternative = "two.sided",
  h0 = 0,
  conf_level = 0.95,
  max_p_value = 0.05,
  wilcox_exact = FALSE,
  wilcox_correct = TRUE,
  wilcox_tol_root = 1e-04,
  wilcox_digits_rank = Inf,
  max_results = Inf,
  verbose = FALSE,
  threads = 1
)
```

## Arguments

- x:

  a matrix or data frame with data to search the patterns in.

- condition:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use as condition predicates

- vars:

  a tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to use for computation of contrasts

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

- method:

  a character string indicating which contrast to compute. One of `"t"`,
  for parametric, or `"wilcox"`, for non-parametric test on equality in
  position.

- alternative:

  indicates the alternative hypothesis and must be one of `"two.sided"`,
  `"greater"` or `"less"`. `"greater"` corresponds to positive
  association, `"less"` to negative association.

- h0:

  a numeric value specifying the null hypothesis for the test. For the
  `"t"` method, it is the value of the mean. For the `"wilcox"` method,
  it is the value of the median. The default value is 0.

- conf_level:

  a numeric value specifying the level of the confidence interval. The
  default value is 0.95.

- max_p_value:

  the maximum p-value of a test for the pattern to be considered
  significant. If the p-value of the test is greater than `max_p_value`,
  the pattern is not included in the result.

- wilcox_exact:

  (used for the `"wilcox"` method only) a logical value indicating
  whether the exact p-value should be computed. If `NULL`, the exact
  p-value is computed for sample sizes less than 50. See
  [`wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html) and its
  `exact` argument for more information. Contrary to the behavior of
  [`wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html), the
  default value is `FALSE`.

- wilcox_correct:

  (used for the `"wilcox"` method only) a logical value indicating
  whether the continuity correction should be applied in the normal
  approximation for the p-value, if `wilcox_exact` is `FALSE`. See
  [`wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html) and its
  `correct` argument for more information.

- wilcox_tol_root:

  (used for the `"wilcox"` method only) a numeric value specifying the
  tolerance for the root-finding algorithm used to compute the exact
  p-value. See
  [`wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html) and its
  `tol.root` argument for more information.

- wilcox_digits_rank:

  (used for the `"wilcox"` method only) a numeric value specifying the
  number of digits to round the ranks to. See
  [`wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html) and its
  `digits.rank` argument for more information.

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

An S3 object which is an instance of `baseline_contrasts` and `nugget`
classes and which is a tibble with found patterns in rows. The following
columns are always present:

- condition:

  the condition of the pattern as a character string in the form
  `{p1 & p2 & ... & pn}` where `p1`, `p2`, ..., `pn` are `x`'s column
  names.

- support:

  the support of the condition, i.e., the relative frequency of the
  condition in the dataset `x`.

- var:

  the name of the contrast variable.

- estimate:

  the estimated mean or median of variable `var`.

- statistic:

  the statistic of the selected test.

- p_value:

  the p-value of the underlying test.

- n:

  the number of rows in the sub-data corresponding to the condition.

- conf_int_lo:

  the lower bound of the confidence interval of the estimate.

- conf_int_hi:

  the upper bound of the confidence interval of the estimate.

- alternative:

  a character string indicating the alternative hypothesis. The value
  must be one of `"two.sided"`, `"greater"`, or `"less"`.

- method:

  a character string indicating the method used for the test.

- comment:

  a character string with additional information about the test (mainly
  error messages on failure).

For the `"t"` method, the following additional columns are also present
(see also [`t.test()`](https://rdrr.io/r/stats/t.test.html)):

- df:

  the degrees of freedom of the t test.

- stderr:

  the standard error of the mean.

## See also

[`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md),
[`dig_complement_contrasts()`](https://beerda.github.io/nuggets/reference/dig_complement_contrasts.md),
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md),
[`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md),
[`stats::t.test()`](https://rdrr.io/r/stats/t.test.html),
[`stats::wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html)

## Author

Michal Burda

# Search for conditions that provide significant differences in selected variables to the rest of the data table

**\[experimental\]**

Complement contrast patterns identify conditions under which there is a
significant difference in some numerical variable between elements that
satisfy the identified condition and the rest of the data table.

- Scheme::

  `(var | C) != (var | not C)`  
    
  There is a statistically significant difference in variable `var`
  between group of elements that satisfy condition `C` and a group of
  elements that do not satisfy condition `C`.

- Example::

  `(life_expectancy | smoker) < (life_expectancy | non-smoker)`  
    
  The life expectancy in people that smoke cigarettes is in average
  significantly lower than in people that do not smoke.

The complement contrast is computed using a two-sample statistical test,
which is specified by the `method` argument. The function computes the
complement contrast in all variables specified by the `vars` argument.
Complement contrasts are computed based on sub-data corresponding to
conditions generated from the `condition` columns and the rest of the
data table. Function \#' `dig_complement_contrasts()` supports crisp
conditions only, i.e., the condition columns in `x` must be logical.

## Usage

``` r
dig_complement_contrasts(
  x,
  condition = where(is.logical),
  vars = where(is.numeric),
  disjoint = var_names(colnames(x)),
  excluded = NULL,
  min_length = 0L,
  max_length = Inf,
  min_support = 0,
  max_support = 1 - min_support,
  method = "t",
  alternative = "two.sided",
  h0 = if (method == "var") 1 else 0,
  conf_level = 0.95,
  max_p_value = 0.05,
  t_var_equal = FALSE,
  wilcox_exact = FALSE,
  wilcox_correct = TRUE,
  wilcox_tol_root = 1e-04,
  wilcox_digits_rank = Inf,
  max_results = Inf,
  verbose = FALSE,
  threads = 1L
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
  position, and `"var"` for F-test on comparison of variances of two
  populations.

- alternative:

  indicates the alternative hypothesis and must be one of `"two.sided"`,
  `"greater"` or `"less"`. `"greater"` corresponds to positive
  association, `"less"` to negative association.

- h0:

  a numeric value specifying the null hypothesis for the test. For the
  `"t"` method, it is the difference in means. For the `"wilcox"`
  method, it is the difference in medians. For the `"var"` method, it is
  the hypothesized ratio of the population variances. The default value
  is 1 for `"var"` method, and 0 otherwise.

- conf_level:

  a numeric value specifying the level of the confidence interval. The
  default value is 0.95.

- max_p_value:

  the maximum p-value of a test for the pattern to be considered
  significant. If the p-value of the test is greater than `max_p_value`,
  the pattern is not included in the result.

- t_var_equal:

  (used for the `"t"` method only) a logical value indicating whether
  the variances of the two samples are assumed to be equal. If `TRUE`,
  the pooled variance is used to estimate the variance in the t-test. If
  `FALSE`, the Welch (or Satterthwaite) approximation to the degrees of
  freedom is used. See [`t.test()`](https://rdrr.io/r/stats/t.test.html)
  and its `var.equal` argument for more information.

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

An S3 object which is an instance of `complement_contrasts` and `nugget`
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

  the estimate value (see the underlying test.

- statistic:

  the statistic of the selected test.

- p_value:

  the p-value of the underlying test.

- n_x:

  the number of rows in the sub-data corresponding to the condition.

- n_y:

  the number of rows in the sub-data corresponding to the negation of
  the condition.

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

  the standard error of the mean difference.

## See also

[`dig_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_baseline_contrasts.md),
[`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md),
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md),
[`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md),
[`stats::t.test()`](https://rdrr.io/r/stats/t.test.html),
[`stats::wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html),
[`stats::var.test()`](https://rdrr.io/r/stats/var.test.html)

## Author

Michal Burda

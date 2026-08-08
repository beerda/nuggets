# Contrast Patterns

## Introduction

**Contrast patterns** identify conditions under which numeric variables
show statistically significant differences. In `nuggets`, this family is
represented by three related functions:

- [`dig_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_baseline_contrasts.md)
  for testing whether a variable differs from a chosen baseline value
  under a condition,
- [`dig_complement_contrasts()`](https://beerda.github.io/nuggets/reference/dig_complement_contrasts.md)
  for comparing rows satisfying a condition with the remaining rows,
- [`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md)
  for comparing two paired variables inside a condition.

These pattern families answer different questions:

- *Is a variable unusually high or low in some subgroup?*
- *Does a subgroup differ from the rest of the data?*
- *Do two paired measurements differ inside a subgroup?*

Before going further, load the packages used in this vignette:

``` r

library(nuggets)
library(dplyr)     # for data manipulation
```

For the overall package workflow, see
[`vignette("nuggets")`](https://beerda.github.io/nuggets/articles/nuggets.md).

## A Small Working Dataset

To demonstrate all three contrast types, we prepare a version of `iris`
that contains:

- logical columns that can define conditions,
- numeric variables that can be compared by the contrast functions,
- derived variables whose interpretation is easy to explain.

``` r

iris_contrasts <- iris |>
    mutate(long_sepal = Sepal.Length >= median(Sepal.Length),
           wide_petal = Petal.Width >= median(Petal.Width),
           length_gap = Sepal.Length - Petal.Length,
           width_gap = Sepal.Width - Petal.Width,
           sepal_ratio = Sepal.Length / Sepal.Width,
           petal_ratio = Petal.Length / Petal.Width) |>
    partition(Species)

head(iris_contrasts, n = 3)
#> # A tibble: 3 × 13
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width long_sepal wide_petal
#>          <dbl>       <dbl>        <dbl>       <dbl> <lgl>      <lgl>     
#> 1          5.1         3.5          1.4         0.2 FALSE      FALSE     
#> 2          4.9         3            1.4         0.2 FALSE      FALSE     
#> 3          4.7         3.2          1.3         0.2 FALSE      FALSE     
#>   length_gap width_gap sepal_ratio petal_ratio `Species=setosa`
#>        <dbl>     <dbl>       <dbl>       <dbl> <lgl>           
#> 1        3.7       3.3        1.46         7   TRUE            
#> 2        3.5       2.8        1.63         7   TRUE            
#> 3        3.4       3          1.47         6.5 TRUE            
#>   `Species=versicolor` `Species=virginica`
#>   <lgl>                <lgl>              
#> 1 FALSE                FALSE              
#> 2 FALSE                FALSE              
#> 3 FALSE                FALSE
```

The `Species` factor is expanded into dummy predicates, while the
logical helper columns remain available as additional condition
predicates. The numeric columns are then used as the variables being
tested.

For more information on creating predicate columns, see
[`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md).

## Selecting Conditions and Variables

The contrast functions use slightly different argument names, but they
all rely on the same idea:

- `condition` selects columns from which conditions are generated,
- `vars` selects numeric variables for one-sample or two-sample
  contrasts,
- `xvars` and `yvars` select paired numeric variables.

These arguments accept [tidyselect
expressions](https://tidyselect.r-lib.org/reference/language.html), so
you can target specific sets of predicates and variables without
manually listing every column.

## Baseline Contrasts

**Baseline contrasts** search for conditions under which a numeric
variable differs from a chosen baseline value `h0`.

The basic scheme is:

> *var* != *h0* \| *condition*

Here we test whether two derived gap variables differ from zero inside
the discovered subgroups. With `method = "t"`, the underlying test is
[`stats::t.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html)
(one-sample, testing whether the mean equals `h0`):

``` r

baseline_result <- dig_baseline_contrasts(iris_contrasts,
                                          condition = where(is.logical),
                                          vars = c(length_gap, width_gap),
                                          min_length = 1,
                                          max_length = 2,
                                          min_support = 0.2,
                                          method = "t",
                                          max_p_value = 0.01)

head(baseline_result, n = 6)
#> # A tibble: 6 × 15
#>   condition                       support var        estimate statistic    df
#>   <chr>                             <dbl> <chr>         <dbl>     <dbl> <dbl>
#> 1 {wide_petal}                      0.567 length_gap     1.29      25.9    84
#> 2 {wide_petal}                      0.567 width_gap      1.16      28.8    84
#> 3 {long_sepal,wide_petal}           0.473 length_gap     1.30      23.5    70
#> 4 {long_sepal,wide_petal}           0.473 width_gap      1.13      25.9    70
#> 5 {Species=versicolor,wide_petal}   0.233 length_gap     1.66      26.1    34
#> 6 {Species=versicolor,wide_petal}   0.233 width_gap      1.45      34.2    34
#>    p_value     n conf_lo conf_hi stderr alternative method            comment
#>      <dbl> <int>   <dbl>   <dbl>  <dbl> <chr>       <chr>             <chr>  
#> 1 9.35e-42    85    1.19    1.39 0.0500 two.sided   One Sample t-test ""     
#> 2 2.70e-45    85    1.08    1.24 0.0401 two.sided   One Sample t-test ""     
#> 3 7.01e-35    71    1.19    1.42 0.0556 two.sided   One Sample t-test ""     
#> 4 1.44e-37    71    1.04    1.22 0.0437 two.sided   One Sample t-test ""     
#> 5 4.65e-24    35    1.53    1.79 0.0637 two.sided   One Sample t-test ""     
#> 6 6.60e-28    35    1.37    1.54 0.0425 two.sided   One Sample t-test ""     
#>   condition_length
#>              <int>
#> 1                1
#> 2                1
#> 3                2
#> 4                2
#> 5                2
#> 6                2
```

This result tells us under which conditions the mean gap is
significantly different from zero.

- `condition` - the generated condition, `support` - relative frequency
  of the condition,
- `var` - the tested variable,
- `estimate` - the estimated mean difference from the baseline,
- `statistic` - the test statistic (determined by `method` argument),
- `df` - degrees of freedom for the test,
- `p_value` - significance of the test,
- `n` - number of rows in the corresponding sub-data,
- `conf_lo`, `conf_hi` - confidence-interval bounds,
- `stderr` - standard error of the estimate,
- `condition_length` - number of predicates in the condition,
- `alternative`, `method`, `comment` - additional information about the
  test.

### Non-parametric Baseline Contrasts

If you prefer a rank-based one-sample test, use `method = "wilcox"`.
This applies
[`stats::wilcox.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/wilcox.test.html)
(Wilcoxon signed-rank test), which tests whether the pseudo-median
equals `h0`:

``` r

baseline_wilcox <- dig_baseline_contrasts(iris_contrasts,
                                          condition = starts_with("Species"),
                                          vars = length_gap,
                                          min_length = 1,
                                          max_length = 1,
                                          min_support = 0.2,
                                          method = "wilcox",
                                          max_p_value = 0.01)

baseline_wilcox
#> # A tibble: 3 × 13
#>   condition            support var        estimate statistic  p_value     n
#>   <chr>                  <dbl> <chr>         <dbl>     <dbl>    <dbl> <int>
#> 1 {Species=setosa}       0.333 length_gap     3.55      1275 7.62e-10    50
#> 2 {Species=versicolor}   0.333 length_gap     1.70      1275 7.45e-10    50
#> 3 {Species=virginica}    0.333 length_gap     1.05      1275 7.48e-10    50
#>   conf_lo conf_hi alternative
#>     <dbl>   <dbl> <chr>      
#> 1   3.45     3.65 two.sided  
#> 2   1.60     1.80 two.sided  
#> 3   0.950    1.15 two.sided  
#>   method                                               comment condition_length
#>   <chr>                                                <chr>              <int>
#> 1 Wilcoxon signed rank test with continuity correction ""                     1
#> 2 Wilcoxon signed rank test with continuity correction ""                     1
#> 3 Wilcoxon signed rank test with continuity correction ""                     1
```

This is useful when you want a method that is less sensitive to
departures from normality.

## Complement Contrasts

**Complement contrasts** compare a subgroup with the rest of the
dataset. Their scheme is:

> (*var* \| *condition*) != (*var* \| not *condition*)

This is often the most natural contrast pattern when you want to know
whether a condition identifies an unusual subgroup. With `method = "t"`,
the underlying test is
[`stats::t.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html)
(two-sample Welch t-test, comparing the means of the condition subgroup
and its complement):

``` r

complement_result <- dig_complement_contrasts(iris_contrasts,
                                              condition = where(is.logical),
                                              vars = c(Sepal.Length, Petal.Length, petal_ratio),
                                              min_length = 1,
                                              max_length = 2,
                                              min_support = 0.2,
                                              method = "t",
                                              max_p_value = 0.01)

head(complement_result, n = 6)
#> # A tibble: 6 × 17
#>   condition               support var          estimate_x estimate_y statistic
#>   <chr>                     <dbl> <chr>             <dbl>      <dbl>     <dbl>
#> 1 {wide_petal}              0.567 Sepal.Length       6.39       5.13     14.9 
#> 2 {wide_petal}              0.567 Petal.Length       5.10       2.01     20.6 
#> 3 {wide_petal}              0.567 petal_ratio        2.92       6.13     -8.89
#> 4 {long_sepal,wide_petal}   0.473 Sepal.Length       6.56       5.20     17.6 
#> 5 {long_sepal,wide_petal}   0.473 Petal.Length       5.26       2.41     17.2 
#> 6 {long_sepal,wide_petal}   0.473 petal_ratio        2.91       5.57     -8.09
#>      df  p_value   n_x   n_y conf_lo conf_hi stderr alternative
#>   <dbl>    <dbl> <int> <int>   <dbl>   <dbl>  <dbl> <chr>      
#> 1 146.  4.86e-31    85    65    1.10    1.43 0.0849 two.sided  
#> 2 109.  2.51e-39    85    65    2.79    3.39 0.150  two.sided  
#> 3  65.7 7.11e-13    85    65   -3.92   -2.48 0.360  two.sided  
#> 4 135.  1.02e-36    71    79    1.21    1.52 0.0776 two.sided  
#> 5 119.  4.11e-34    71    79    2.52    3.18 0.165  two.sided  
#> 6  81.2 4.95e-12    71    79   -3.31   -2.00 0.328  two.sided  
#>   method                  comment condition_length
#>   <chr>                   <chr>              <int>
#> 1 Welch Two Sample t-test ""                     1
#> 2 Welch Two Sample t-test ""                     1
#> 3 Welch Two Sample t-test ""                     1
#> 4 Welch Two Sample t-test ""                     2
#> 5 Welch Two Sample t-test ""                     2
#> 6 Welch Two Sample t-test ""                     2
```

The output contains separate estimates for the subgroup and its
complement:

- `estimate_x` average (or median) value of selected variable for rows
  satisfying the condition,
- `estimate_y` average (or median) value of selected variable for rows
  not satisfying the condition,
- `n_x` and `n_y` for the corresponding sample sizes.

### Comparing Variability Instead of Location

[`dig_complement_contrasts()`](https://beerda.github.io/nuggets/reference/dig_complement_contrasts.md)
also supports `method = "var"` for testing whether the variability in
one group differs from the variability in its complement. This uses
[`stats::var.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/var.test.html)
(F-test of equality of variances):

``` r

complement_var <- dig_complement_contrasts(iris_contrasts,
                                           condition = starts_with("Species"),
                                           vars = Petal.Length,
                                           min_length = 1,
                                           max_length = 1,
                                           min_support = 0.2,
                                           method = "var",
                                           max_p_value = 0.01)

complement_var
#> # A tibble: 3 × 14
#>   condition            support var          estimate statistic  p_value   n_x
#>   <chr>                  <dbl> <chr>           <dbl>     <dbl>    <dbl> <int>
#> 1 {Species=setosa}       0.333 Petal.Length   0.0442    0.0442 1.57e-22    50
#> 2 {Species=versicolor}   0.333 Petal.Length   0.0503    0.0503 2.96e-21    50
#> 3 {Species=virginica}    0.333 Petal.Length   0.145     0.145  2.28e-11    50
#>     n_y conf_lo conf_hi alternative method                          comment
#>   <int>   <dbl>   <dbl> <chr>       <chr>                           <chr>  
#> 1   100  0.0277  0.0736 two.sided   F test to compare two variances ""     
#> 2   100  0.0315  0.0837 two.sided   F test to compare two variances ""     
#> 3   100  0.0907  0.241  two.sided   F test to compare two variances ""     
#>   condition_length
#>              <int>
#> 1                1
#> 2                1
#> 3                1
```

This is helpful when a subgroup is not mainly distinguished by a higher
or lower mean, but by being more or less variable.

## Paired Baseline Contrasts

**Paired baseline contrasts** compare two numeric variables observed on
the same rows under generated conditions.

The scheme is:

> (*xvar* - *yvar*) != 0 \| *condition*

This is appropriate for paired measurements such as “before vs after”,
“left vs right”, or two alternative measurements recorded for the same
case. With `method = "t"`, the underlying test is
[`stats::t.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html)
(paired t-test, testing whether the mean difference equals zero):

``` r

paired_result <- dig_paired_baseline_contrasts(iris_contrasts,
                                               condition = where(is.logical),
                                               xvars = c(Sepal.Length, Sepal.Width),
                                               yvars = c(Petal.Length, Petal.Width),
                                               min_length = 1,
                                               max_length = 1,
                                               min_support = 0.2,
                                               method = "t",
                                               max_p_value = 0.01)

head(paired_result, n = 6)
#> # A tibble: 6 × 16
#>   condition    support xvar         yvar         estimate statistic    df
#>   <chr>          <dbl> <chr>        <chr>           <dbl>     <dbl> <dbl>
#> 1 {wide_petal}   0.567 Sepal.Length Petal.Length     1.29      25.9    84
#> 2 {wide_petal}   0.567 Sepal.Length Petal.Width      4.61      76.1    84
#> 3 {wide_petal}   0.567 Sepal.Width  Petal.Length    -2.16     -29.3    84
#> 4 {wide_petal}   0.567 Sepal.Width  Petal.Width      1.16      28.8    84
#> 5 {long_sepal}   0.513 Sepal.Length Petal.Length     1.38      20.2    76
#> 6 {long_sepal}   0.513 Sepal.Length Petal.Width      4.74      80.4    76
#>    p_value     n conf_lo conf_hi stderr alternative method        comment
#>      <dbl> <int>   <dbl>   <dbl>  <dbl> <chr>       <chr>         <chr>  
#> 1 9.35e-42    85    1.19    1.39 0.0500 two.sided   Paired t-test ""     
#> 2 3.05e-79    85    4.49    4.73 0.0606 two.sided   Paired t-test ""     
#> 3 6.75e-46    85   -2.31   -2.02 0.0737 two.sided   Paired t-test ""     
#> 4 2.70e-45    85    1.08    1.24 0.0401 two.sided   Paired t-test ""     
#> 5 2.45e-32    77    1.24    1.51 0.0680 two.sided   Paired t-test ""     
#> 6 2.65e-75    77    4.62    4.85 0.0589 two.sided   Paired t-test ""     
#>   condition_length
#>              <int>
#> 1                1
#> 2                1
#> 3                1
#> 4                1
#> 5                1
#> 6                1
```

The result reports the condition, the selected variable pair (`xvar`,
`yvar`), the estimated difference, test statistic, p-value, and sample
size.

### Non-parametric Paired Contrasts

For a paired rank-based alternative, use the Wilcoxon signed-rank test
by setting `method = "wilcox"`. This calls
[`stats::wilcox.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/wilcox.test.html)
with `paired = TRUE`, testing whether the pseudo-median of the pairwise
differences equals zero:

``` r

paired_wilcox <- dig_paired_baseline_contrasts(iris_contrasts,
                                               condition = starts_with("Species"),
                                               xvars = Sepal.Length,
                                               yvars = Petal.Length,
                                               min_length = 1,
                                               max_length = 1,
                                               min_support = 0.2,
                                               method = "wilcox",
                                               max_p_value = 0.01)

paired_wilcox
#> # A tibble: 3 × 14
#>   condition            support xvar         yvar         estimate statistic
#>   <chr>                  <dbl> <chr>        <chr>           <dbl>     <dbl>
#> 1 {Species=setosa}       0.333 Sepal.Length Petal.Length     3.55      1275
#> 2 {Species=versicolor}   0.333 Sepal.Length Petal.Length     1.70      1275
#> 3 {Species=virginica}    0.333 Sepal.Length Petal.Length     1.05      1275
#>    p_value     n conf_lo conf_hi alternative
#>      <dbl> <int>   <dbl>   <dbl> <chr>      
#> 1 7.62e-10    50   3.45     3.65 two.sided  
#> 2 7.45e-10    50   1.60     1.80 two.sided  
#> 3 7.48e-10    50   0.950    1.15 two.sided  
#>   method                                               comment condition_length
#>   <chr>                                                <chr>              <int>
#> 1 Wilcoxon signed rank test with continuity correction ""                     1
#> 2 Wilcoxon signed rank test with continuity correction ""                     1
#> 3 Wilcoxon signed rank test with continuity correction ""                     1
```

## Controlling the Search

All three contrast functions support the usual search controls:

- `min_length`, `max_length` for condition complexity,
- `min_support`, `max_support` for subgroup size,
- `max_results` to stop long searches early,
- `max_p_value` to keep only statistically significant results.

## Which Contrast Family Should You Use?

The three contrast types complement each other:

- use **baseline contrasts** when you have a meaningful reference value,
- use **complement contrasts** when you want to compare a subgroup with
  the rest of the data,
- use **paired baseline contrasts** when two measurements belong to the
  same observational units.

In practice, it is often useful to start with complement contrasts to
locate interesting subgroups, then refine the analysis with baseline or
paired contrasts depending on the scientific question.

## Notes on Interpretation

When reading discovered contrast patterns, keep the following points in
mind:

- a large absolute `estimate` indicates a stronger effect,
- `p_value` reflects statistical evidence for the chosen alternative,
  but should be interpreted with caution due to multiple comparisons
  (see below),
- `support` and `n` describe how much data contributed to the pattern,
- longer conditions describe more specific subgroups, but usually with
  smaller support.

### Multiple Comparisons

A typical contrast-pattern search tests many condition–variable
combinations simultaneously. When hundreds of tests are run at level
0.05, several spurious discoveries are expected by chance alone, even if
no true effect exists.

The patterns returned by the `dig_*_contrasts()` functions are therefore
best understood as **generated hypotheses** - promising associations
that deserve further scrutiny - rather than as confirmed findings. This
is known as the problem of *simultaneous statistical inference* or
*multiple comparisons*.

A standard remedy is to **adjust the p-values** to control either the
family-wise error rate (FWER) or the false discovery rate (FDR):

- **FWER-controlling methods** (e.g. Bonferroni, Holm) ensure that the
  probability of making *any* false discovery across all tests stays
  below a chosen threshold. They are conservative when the number of
  tests is large.
- **FDR-controlling methods** (e.g. Benjamini–Hochberg, abbreviated BH)
  allow a small *proportion* of discoveries to be false positives. This
  is less stringent than FWER control and retains more patterns in
  exploratory analyses.

R’s built-in [`p.adjust()`](https://rdrr.io/r/stats/p.adjust.html)
function supports both families. The example below applies Holm
correction (FWER) and Benjamini–Hochberg correction (FDR) to the result
of a complement-contrast search:

``` r

complement_result$p_holm <- p.adjust(complement_result$p_value, method = "holm")
complement_result$p_bh   <- p.adjust(complement_result$p_value, method = "BH")

complement_result[, c("condition", "var", "p_value", "p_holm", "p_bh")]
#> # A tibble: 26 × 5
#>    condition                       var           p_value   p_holm     p_bh
#>    <chr>                           <chr>           <dbl>    <dbl>    <dbl>
#>  1 {wide_petal}                    Sepal.Length 4.86e-31 7.78e-30 1.15e-30
#>  2 {wide_petal}                    Petal.Length 2.51e-39 6.28e-38 3.27e-38
#>  3 {wide_petal}                    petal_ratio  7.11e-13 6.40e-12 1.03e-12
#>  4 {long_sepal,wide_petal}         Sepal.Length 1.02e-36 2.34e-35 6.62e-36
#>  5 {long_sepal,wide_petal}         Petal.Length 4.11e-34 7.82e-33 1.34e-33
#>  6 {long_sepal,wide_petal}         petal_ratio  4.95e-12 3.47e-11 6.44e-12
#>  7 {Species=versicolor,wide_petal} Sepal.Length 3.41e- 3 3.41e- 3 3.41e- 3
#>  8 {Species=versicolor,wide_petal} Petal.Length 6.34e- 6 1.90e- 5 6.87e- 6
#>  9 {Species=versicolor,wide_petal} petal_ratio  2.31e- 8 1.15e- 7 2.73e- 8
#> 10 {Species=virginica,wide_petal}  Sepal.Length 6.32e-17 8.85e-16 1.17e-16
#> # ℹ 16 more rows
```

After adjustment, you can filter by the corrected p-values:

``` r

complement_result[complement_result$p_bh < 0.05, ]
#> # A tibble: 26 × 19
#>    condition                       support var          estimate_x estimate_y
#>    <chr>                             <dbl> <chr>             <dbl>      <dbl>
#>  1 {wide_petal}                      0.567 Sepal.Length       6.39       5.13
#>  2 {wide_petal}                      0.567 Petal.Length       5.10       2.01
#>  3 {wide_petal}                      0.567 petal_ratio        2.92       6.13
#>  4 {long_sepal,wide_petal}           0.473 Sepal.Length       6.56       5.20
#>  5 {long_sepal,wide_petal}           0.473 Petal.Length       5.26       2.41
#>  6 {long_sepal,wide_petal}           0.473 petal_ratio        2.91       5.57
#>  7 {Species=versicolor,wide_petal}   0.233 Sepal.Length       6.11       5.76
#>  8 {Species=versicolor,wide_petal}   0.233 Petal.Length       4.45       3.55
#>  9 {Species=versicolor,wide_petal}   0.233 petal_ratio        3.12       4.67
#> 10 {Species=virginica,wide_petal}    0.333 Sepal.Length       6.59       5.47
#>    statistic    df  p_value   n_x   n_y conf_lo conf_hi stderr alternative
#>        <dbl> <dbl>    <dbl> <int> <int>   <dbl>   <dbl>  <dbl> <chr>      
#>  1     14.9  146.  4.86e-31    85    65   1.10    1.43  0.0849 two.sided  
#>  2     20.6  109.  2.51e-39    85    65   2.79    3.39  0.150  two.sided  
#>  3     -8.89  65.7 7.11e-13    85    65  -3.92   -2.48  0.360  two.sided  
#>  4     17.6  135.  1.02e-36    71    79   1.21    1.52  0.0776 two.sided  
#>  5     17.2  119.  4.11e-34    71    79   2.52    3.18  0.165  two.sided  
#>  6     -8.09  81.2 4.95e-12    71    79  -3.31   -2.00  0.328  two.sided  
#>  7      2.99 110.  3.41e- 3    35   115   0.117   0.575 0.116  two.sided  
#>  8      4.70 133.  6.34e- 6    35   115   0.522   1.28  0.192  two.sided  
#>  9     -5.99 118.  2.31e- 8    35   115  -2.06   -1.04  0.258  two.sided  
#> 10     10.1   98.9 6.32e-17    50   100   0.898   1.34  0.110  two.sided  
#>    method                  comment condition_length   p_holm     p_bh
#>    <chr>                   <chr>              <int>    <dbl>    <dbl>
#>  1 Welch Two Sample t-test ""                     1 7.78e-30 1.15e-30
#>  2 Welch Two Sample t-test ""                     1 6.28e-38 3.27e-38
#>  3 Welch Two Sample t-test ""                     1 6.40e-12 1.03e-12
#>  4 Welch Two Sample t-test ""                     2 2.34e-35 6.62e-36
#>  5 Welch Two Sample t-test ""                     2 7.82e-33 1.34e-33
#>  6 Welch Two Sample t-test ""                     2 3.47e-11 6.44e-12
#>  7 Welch Two Sample t-test ""                     2 3.41e- 3 3.41e- 3
#>  8 Welch Two Sample t-test ""                     2 1.90e- 5 6.87e- 6
#>  9 Welch Two Sample t-test ""                     2 1.15e- 7 2.73e- 8
#> 10 Welch Two Sample t-test ""                     2 8.85e-16 1.17e-16
#> # ℹ 16 more rows
```

In a large exploratory search you may prefer the FDR approach (BH)
because it keeps more patterns visible while still limiting the expected
fraction of false discoveries. Use FWER control (Holm) when you need
stronger guarantees.

## Related Tools

The contrast functions focus on built-in statistical tests. If you need
custom statistics under generated conditions,
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) and
[`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
provide the general framework; see
[`vignette("custom-patterns")`](https://beerda.github.io/nuggets/articles/custom-patterns.md).

Conditional correlations are another related pattern family for
subgroup-based analysis of numeric variables; see
[`vignette("conditional-correlations")`](https://beerda.github.io/nuggets/articles/conditional-correlations.md).

For interactive inspection of discovered patterns, you can use:

``` r

explore(complement_result, iris_contrasts)
```

## Summary

This vignette introduced the main contrast-pattern workflows in
`nuggets`:

1.  **Baseline contrasts** test whether a variable differs from a
    reference value under a condition.
2.  **Complement contrasts** compare a subgroup with the remaining data.
3.  **Paired baseline contrasts** compare two paired variables within a
    subgroup.
4.  **Search controls** such as support, condition length, and p-value
    thresholds help keep the result focused and interpretable.
5.  **Tidyselect-based column selection** makes it easy to describe both
    the condition predicates and the tested variables.

For related material, see:

- [`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md)
  for preparing predicate columns,
- [`vignette("conditional-correlations")`](https://beerda.github.io/nuggets/articles/conditional-correlations.md)
  for subgroup-based correlation analysis,
- [`vignette("custom-patterns")`](https://beerda.github.io/nuggets/articles/custom-patterns.md)
  for custom statistical pattern searches,
- [`vignette("nuggets")`](https://beerda.github.io/nuggets/articles/nuggets.md)
  for the package overview.

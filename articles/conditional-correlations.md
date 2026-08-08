# Conditional Correlations

## Introduction

**Conditional correlations** identify conditions under which two numeric
variables are strongly related. In `nuggets`, the basic scheme is:

> *xvar* ~ *yvar* \| *condition*

This reads as: the variables `xvar` and `yvar` are highly correlated in
the sub-data satisfying the given condition.

For example:

> `study_time ~ test_score | hard_exam`

This means that for difficult exams, the amount of study time is
strongly related to the obtained test score.

The
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
function searches over generated conditions and computes correlations
for all selected combinations of numeric variables. It supports the
standard correlation methods implemented by
[`stats::cor.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.test.html),
namely Pearson, Kendall, and Spearman correlations.

Before going further, load the packages used in this vignette:

``` r

library(nuggets)
library(dplyr)     # for data manipulation
```

For a broader overview of the package workflow, see
[`vignette("nuggets")`](https://beerda.github.io/nuggets/articles/nuggets.md).

## A Small Working Dataset

[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
expects **logical condition columns** and **numeric variables** to
correlate. The built-in `iris` dataset is convenient for this, because
it already contains several numeric measurements and one factor column
that can be transformed into condition predicates.

In the next example, we:

- convert `Species` into dummy logical predicates with
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
- add two logical helper conditions,
- add two derived numeric variables that will be useful in examples.

``` r

iris_corr <- iris |>
    mutate(long_sepal = Sepal.Length >= median(Sepal.Length),
           wide_petal = Petal.Width >= median(Petal.Width),
           sepal_ratio = Sepal.Length / Sepal.Width,
           petal_ratio = Petal.Length / Petal.Width) |>
    partition(Species)

head(iris_corr, n = 3)
#> # A tibble: 3 × 11
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width long_sepal wide_petal
#>          <dbl>       <dbl>        <dbl>       <dbl> <lgl>      <lgl>     
#> 1          5.1         3.5          1.4         0.2 FALSE      FALSE     
#> 2          4.9         3            1.4         0.2 FALSE      FALSE     
#> 3          4.7         3.2          1.3         0.2 FALSE      FALSE     
#>   sepal_ratio petal_ratio `Species=setosa` `Species=versicolor`
#>         <dbl>       <dbl> <lgl>            <lgl>               
#> 1        1.46         7   TRUE             FALSE               
#> 2        1.63         7   TRUE             FALSE               
#> 3        1.47         6.5 TRUE             FALSE               
#>   `Species=virginica`
#>   <lgl>              
#> 1 FALSE              
#> 2 FALSE              
#> 3 FALSE
```

The dummy columns created from `Species` and the logical helper columns
can be used to generate conditions, while the original and derived
numeric columns can be used in the correlation tests.

For more information on preparing data for pattern extraction, see
[`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md).

## Basic Conditional Correlation Search

The simplest search chooses condition predicates and numeric variables,
then limits the condition length and support:

``` r

corr_basic <- dig_correlations(iris_corr,
                               condition = where(is.logical),
                               xvars = c(Sepal.Length, Sepal.Width, sepal_ratio),
                               yvars = c(Petal.Length, Petal.Width, petal_ratio),
                               min_length = 0,
                               max_length = 2,
                               min_support = 0.2)

corr_basic |>
    arrange(desc(abs(estimate))) |>
    head(n = 6)
#> # A tibble: 6 × 10
#>   condition                      support xvar         yvar         estimate
#>   <chr>                            <dbl> <chr>        <chr>           <dbl>
#> 1 {}                               1     Sepal.Length Petal.Length    0.872
#> 2 {Species=virginica,wide_petal}   0.333 Sepal.Length Petal.Length    0.864
#> 3 {Species=virginica}              0.333 Sepal.Length Petal.Length    0.864
#> 4 {long_sepal,Species=virginica}   0.313 Sepal.Length Petal.Length    0.846
#> 5 {}                               1     sepal_ratio  Petal.Length    0.838
#> 6 {}                               1     Sepal.Length Petal.Width     0.818
#>    p_value method                               alternative     n
#>      <dbl> <chr>                                <chr>       <int>
#> 1 1.04e-47 Pearson's product-moment correlation two.sided     150
#> 2 6.30e-16 Pearson's product-moment correlation two.sided      50
#> 3 6.30e-16 Pearson's product-moment correlation two.sided      50
#> 4 6.86e-14 Pearson's product-moment correlation two.sided      47
#> 5 1.01e-40 Pearson's product-moment correlation two.sided     150
#> 6 2.33e-37 Pearson's product-moment correlation two.sided     150
#>   condition_length
#>              <int>
#> 1                0
#> 2                2
#> 3                1
#> 4                2
#> 5                0
#> 6                0
```

The result is a tibble where each row represents one discovered pattern.
The main columns are:

- `condition` - the generated condition,
- `support` - relative frequency of the condition,
- `xvar`, `yvar` - the correlated variable pair,
- `estimate` - the correlation coefficient,
- `p_value` - significance of the test,
- `n` - number of rows in the corresponding sub-data,
- `alternative`, `method` - additional information about the test.

## Controlling the Search Space

The `condition`, `xvars`, and `yvars` arguments accept [tidyselect
expressions](https://tidyselect.r-lib.org/reference/language.html). This
makes it easy to restrict the search to specific groups of columns.

As with other `dig_*()` functions, the search can be controlled with
`min_length`, `max_length`, `min_support`, `max_support`, and
`max_results`.

For example, the following search uses only species predicates as
conditions and correlates all sepal variables against all petal
variables:

``` r

corr_species <- dig_correlations(iris_corr,
                                 condition = starts_with("Species"),
                                 xvars = starts_with("Sepal"),
                                 yvars = starts_with("Petal"),
                                 min_length = 1,
                                 max_length = 1,
                                 min_support = 0.3)

head(corr_species, n = 6)
#> # A tibble: 6 × 10
#>   condition        support xvar         yvar         estimate p_value
#>   <chr>              <dbl> <chr>        <chr>           <dbl>   <dbl>
#> 1 {Species=setosa}   0.333 Sepal.Length Petal.Length    0.267  0.0607
#> 2 {Species=setosa}   0.333 Sepal.Length Petal.Width     0.278  0.0505
#> 3 {Species=setosa}   0.333 Sepal.Length petal_ratio    -0.194  0.178 
#> 4 {Species=setosa}   0.333 Sepal.Width  Petal.Length    0.178  0.217 
#> 5 {Species=setosa}   0.333 Sepal.Width  Petal.Width     0.233  0.104 
#> 6 {Species=setosa}   0.333 Sepal.Width  petal_ratio    -0.132  0.362 
#>   method                               alternative     n condition_length
#>   <chr>                                <chr>       <int>            <int>
#> 1 Pearson's product-moment correlation two.sided      50                1
#> 2 Pearson's product-moment correlation two.sided      50                1
#> 3 Pearson's product-moment correlation two.sided      50                1
#> 4 Pearson's product-moment correlation two.sided      50                1
#> 5 Pearson's product-moment correlation two.sided      50                1
#> 6 Pearson's product-moment correlation two.sided      50                1
```

## Choosing the Correlation Method

The `method` argument selects which correlation coefficient is used:

- `"pearson"` for linear relationships,
- `"spearman"` for monotone relationships based on ranks,
- `"kendall"` for rank-based association with Kendall’s tau.

Under the hood, every combination uses
[`stats::cor.test()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.test.html)
with the corresponding `method` argument. The `estimate`, `statistic`,
`p_value`, and confidence-interval columns in the result map directly to
the values returned by
[`cor.test()`](https://rdrr.io/r/stats/cor.test.html).

Here is the same basic search with Spearman correlation. As we are O.K.
with non-exact p-values, we can set `exact = FALSE` (otherwise a warning
is issued for small sub-data sizes):

``` r

corr_spearman <- dig_correlations(iris_corr,
                                  condition = where(is.logical),
                                  xvars = c(Sepal.Length, Sepal.Width),
                                  yvars = c(Petal.Length, Petal.Width),
                                  method = "spearman",
                                  exact = FALSE,
                                  min_length = 1,
                                  max_length = 1,
                                  min_support = 0.2)

head(corr_spearman, n = 6)
#> # A tibble: 6 × 10
#>   condition    support xvar         yvar         estimate  p_value
#>   <chr>          <dbl> <chr>        <chr>           <dbl>    <dbl>
#> 1 {wide_petal}   0.567 Sepal.Length Petal.Length    0.704 5.62e-14
#> 2 {wide_petal}   0.567 Sepal.Length Petal.Width     0.473 4.87e- 6
#> 3 {wide_petal}   0.567 Sepal.Width  Petal.Length    0.302 4.91e- 3
#> 4 {wide_petal}   0.567 Sepal.Width  Petal.Width     0.399 1.56e- 4
#> 5 {long_sepal}   0.513 Sepal.Length Petal.Length    0.654 1.08e-10
#> 6 {long_sepal}   0.513 Sepal.Length Petal.Width     0.440 6.14e- 5
#>   method                          alternative     n condition_length
#>   <chr>                           <chr>       <int>            <int>
#> 1 Spearman's rank correlation rho two.sided      85                1
#> 2 Spearman's rank correlation rho two.sided      85                1
#> 3 Spearman's rank correlation rho two.sided      85                1
#> 4 Spearman's rank correlation rho two.sided      85                1
#> 5 Spearman's rank correlation rho two.sided      77                1
#> 6 Spearman's rank correlation rho two.sided      77                1
```

If you are interested specifically in positive or negative
relationships, use the `alternative` argument with values `"greater"` or
`"less"`.

## Correlations on the Whole Dataset

If `condition = NULL`,
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
computes correlations on the whole dataset only. This is useful when you
want the same output structure without searching over conditions.

``` r

corr_whole <- dig_correlations(
    iris_corr,
    condition = NULL,
    xvars = starts_with("Sepal"),
    yvars = starts_with("Petal")
)

corr_whole
#> # A tibble: 9 × 10
#>   condition support xvar         yvar         estimate  p_value
#>   <chr>       <dbl> <chr>        <chr>           <dbl>    <dbl>
#> 1 {}              1 Sepal.Length Petal.Length    0.872 1.04e-47
#> 2 {}              1 Sepal.Length Petal.Width     0.818 2.33e-37
#> 3 {}              1 Sepal.Length petal_ratio    -0.574 1.64e-14
#> 4 {}              1 Sepal.Width  Petal.Length   -0.428 4.51e- 8
#> 5 {}              1 Sepal.Width  Petal.Width    -0.366 4.07e- 6
#> 6 {}              1 Sepal.Width  petal_ratio     0.368 3.71e- 6
#> 7 {}              1 sepal_ratio  Petal.Length    0.838 1.01e-40
#> 8 {}              1 sepal_ratio  Petal.Width     0.754 8.92e-29
#> 9 {}              1 sepal_ratio  petal_ratio    -0.612 8.78e-17
#>   method                               alternative     n condition_length
#>   <chr>                                <chr>       <int>            <int>
#> 1 Pearson's product-moment correlation two.sided     150                0
#> 2 Pearson's product-moment correlation two.sided     150                0
#> 3 Pearson's product-moment correlation two.sided     150                0
#> 4 Pearson's product-moment correlation two.sided     150                0
#> 5 Pearson's product-moment correlation two.sided     150                0
#> 6 Pearson's product-moment correlation two.sided     150                0
#> 7 Pearson's product-moment correlation two.sided     150                0
#> 8 Pearson's product-moment correlation two.sided     150                0
#> 9 Pearson's product-moment correlation two.sided     150                0
```

This is effectively a convenient way to compute a structured set of
pairwise correlation tests between selected columns.

## Notes on Interpretation

When reading discovered correlations, it is useful to keep the following
points in mind:

- a large absolute `estimate` indicates a stronger relationship,
- `p_value` reflects statistical evidence for the chosen alternative,
  but should be interpreted with caution due to multiple comparisons
  (see below),
- `support` and `n` describe how much data contributed to the pattern,
- longer conditions describe more specific contexts, but usually with
  smaller support.

Conditional correlations are therefore most useful when the relationship
between two variables changes across subgroups and would be hidden in a
single global correlation.

### Multiple Comparisons

When
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
is applied to a dataset, it simultaneously tests correlations for a
potentially large number of condition–variable-pair combinations. Each
test produces a `p_value`, but interpreting any individual `p_value` as
if it were the result of a single pre-planned test is misleading: if
hundreds of tests are performed at level 0.05, several false discoveries
are expected by chance alone.

The patterns returned by
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
are therefore best understood as **generated hypotheses** - promising
associations that deserve further scrutiny - rather than as confirmed
findings. This is known as the problem of *simultaneous statistical
inference* or *multiple comparisons*.

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
of a search:

``` r

corr_basic$p_holm <- p.adjust(corr_basic$p_value, method = "holm")
corr_basic$p_bh   <- p.adjust(corr_basic$p_value, method = "BH")

corr_basic[, c("condition", "xvar", "yvar", "p_value", "p_holm", "p_bh")]
#> # A tibble: 90 × 6
#>    condition    xvar         yvar          p_value   p_holm     p_bh
#>    <chr>        <chr>        <chr>           <dbl>    <dbl>    <dbl>
#>  1 {}           Sepal.Length Petal.Length 1.04e-47 9.35e-46 9.35e-46
#>  2 {}           Sepal.Length Petal.Width  2.33e-37 2.05e-35 6.98e-36
#>  3 {}           Sepal.Length petal_ratio  1.64e-14 1.34e-12 1.64e-13
#>  4 {}           Sepal.Width  Petal.Length 4.51e- 8 3.48e- 6 2.90e- 7
#>  5 {}           Sepal.Width  Petal.Width  4.07e- 6 3.01e- 4 2.16e- 5
#>  6 {}           Sepal.Width  petal_ratio  3.71e- 6 2.78e- 4 2.09e- 5
#>  7 {}           sepal_ratio  Petal.Length 1.01e-40 9.02e-39 4.56e-39
#>  8 {}           sepal_ratio  Petal.Width  8.92e-29 7.76e-27 2.01e-27
#>  9 {}           sepal_ratio  petal_ratio  8.78e-17 7.47e-15 1.32e-15
#> 10 {wide_petal} Sepal.Length Petal.Length 3.68e-18 3.16e-16 6.62e-17
#> # ℹ 80 more rows
```

After adjustment, you can filter by the corrected p-values:

``` r

corr_basic[corr_basic$p_bh < 0.05, ]
#> # A tibble: 54 × 12
#>    condition    support xvar         yvar         estimate  p_value
#>    <chr>          <dbl> <chr>        <chr>           <dbl>    <dbl>
#>  1 {}             1     Sepal.Length Petal.Length    0.872 1.04e-47
#>  2 {}             1     Sepal.Length Petal.Width     0.818 2.33e-37
#>  3 {}             1     Sepal.Length petal_ratio    -0.574 1.64e-14
#>  4 {}             1     Sepal.Width  Petal.Length   -0.428 4.51e- 8
#>  5 {}             1     Sepal.Width  Petal.Width    -0.366 4.07e- 6
#>  6 {}             1     Sepal.Width  petal_ratio     0.368 3.71e- 6
#>  7 {}             1     sepal_ratio  Petal.Length    0.838 1.01e-40
#>  8 {}             1     sepal_ratio  Petal.Width     0.754 8.92e-29
#>  9 {}             1     sepal_ratio  petal_ratio    -0.612 8.78e-17
#> 10 {wide_petal}   0.567 Sepal.Length Petal.Length    0.774 3.68e-18
#>    method                               alternative     n condition_length
#>    <chr>                                <chr>       <int>            <int>
#>  1 Pearson's product-moment correlation two.sided     150                0
#>  2 Pearson's product-moment correlation two.sided     150                0
#>  3 Pearson's product-moment correlation two.sided     150                0
#>  4 Pearson's product-moment correlation two.sided     150                0
#>  5 Pearson's product-moment correlation two.sided     150                0
#>  6 Pearson's product-moment correlation two.sided     150                0
#>  7 Pearson's product-moment correlation two.sided     150                0
#>  8 Pearson's product-moment correlation two.sided     150                0
#>  9 Pearson's product-moment correlation two.sided     150                0
#> 10 Pearson's product-moment correlation two.sided      85                1
#>      p_holm     p_bh
#>       <dbl>    <dbl>
#>  1 9.35e-46 9.35e-46
#>  2 2.05e-35 6.98e-36
#>  3 1.34e-12 1.64e-13
#>  4 3.48e- 6 2.90e- 7
#>  5 3.01e- 4 2.16e- 5
#>  6 2.78e- 4 2.09e- 5
#>  7 9.02e-39 4.56e-39
#>  8 7.76e-27 2.01e-27
#>  9 7.47e-15 1.32e-15
#> 10 3.16e-16 6.62e-17
#> # ℹ 44 more rows
```

In a large exploratory search you may prefer the FDR approach (BH)
because it keeps more patterns visible while still limiting the expected
fraction of false discoveries. Use FWER control (Holm) when you need
stronger guarantees.

## Related Tools

[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
is a specialized wrapper around
[`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md).
If you need custom statistics on pairs of variables under generated
conditions, see
[`vignette("custom-patterns")`](https://beerda.github.io/nuggets/articles/custom-patterns.md)
for the more general workflow.

For interactive inspection of discovered patterns, you can also use:

``` r

explore(corr_basic, iris_corr)
```

## Summary

This vignette showed how to search for conditional correlations with
`nuggets`:

1.  prepare logical condition predicates and numeric variables in one
    dataset,
2.  use
    [`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
    to search over generated conditions,
3.  select condition and variable columns with tidyselect expressions,
4.  control the search with support, condition length, and result
    limits,
5.  choose a correlation method appropriate for the data and
    interpretation.

For related material, see:

- [`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md)
  for creating condition predicates,
- [`vignette("contrast-patterns")`](https://beerda.github.io/nuggets/articles/contrast-patterns.md)
  for condition-dependent statistical differences,
- [`vignette("custom-patterns")`](https://beerda.github.io/nuggets/articles/custom-patterns.md)
  for custom grid-based analyses,
- [`vignette("nuggets")`](https://beerda.github.io/nuggets/articles/nuggets.md)
  for the package overview.

# Test whether a vector is almost constant

Check if a vector contains (almost) the same value in the majority of
its elements. The function returns `TRUE` if the proportion of the most
frequent value in `x` is greater than or equal to the specified
`threshold`.

This is useful for detecting low-variability or degenerate variables,
which may be uninformative in modeling or analysis.

## Usage

``` r
is_almost_constant(x, threshold = 1, na_rm = FALSE)
```

## Arguments

- x:

  A vector to be tested.

- threshold:

  A numeric scalar in the interval \\\[0,1\]\\ specifying the minimum
  required proportion of the most frequent value. Defaults to 1.

- na_rm:

  Logical; if `TRUE`, `NA` values are removed before computing
  proportions. If `FALSE`, `NA` is treated as an ordinary value, so a
  large number of `NA`s can cause the function to return `TRUE`.

## Value

A logical scalar. Returns `TRUE` in the following cases:

- `x` is empty or has length one.

- `x` contains only `NA` values.

- The proportion of the most frequent value in `x` is greater than or
  equal to `threshold`. Otherwise, returns `FALSE`.

## See also

[`remove_almost_constant()`](https://beerda.github.io/nuggets/reference/remove_almost_constant.md),
[`unique()`](https://rdrr.io/r/base/unique.html),
[`table()`](https://rdrr.io/r/base/table.html)

## Author

Michal Burda

## Examples

``` r
is_almost_constant(1)
#> [1] TRUE
is_almost_constant(1:10)
#> [1] FALSE
is_almost_constant(c(NA, NA, NA), na_rm = TRUE)
#> [1] TRUE
is_almost_constant(c(NA, NA, NA), na_rm = FALSE)
#> [1] TRUE
is_almost_constant(c(NA, NA, NA, 1, 2), threshold = 0.5, na_rm = FALSE)
#> [1] TRUE
is_almost_constant(c(NA, NA, NA, 1, 2), threshold = 0.5, na_rm = TRUE)
#> [1] TRUE
```

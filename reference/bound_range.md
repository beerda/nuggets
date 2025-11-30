# Bound a range of numeric values

This function computes the range of numeric values in a vector and
adjusts the bounds to "nice" rounded numbers. Specifically, it rounds
the lower bound downwards (similar to
[`floor()`](https://rdrr.io/r/base/Round.html)) and the upper bound
upwards (similar to [`ceiling()`](https://rdrr.io/r/base/Round.html)) to
the specified number of digits. This can be useful when preparing data
ranges for axis labels, plotting, or reporting. The function returns a
numeric vector of length two, containing the adjusted lower and upper
bounds.

## Usage

``` r
bound_range(x, digits = 0, na_rm = FALSE)
```

## Arguments

- x:

  A numeric vector to be bounded.

- digits:

  An integer scalar specifying the number of digits to round the bounds
  to. A positive value determines the number of decimal places used. A
  negative value rounds to the nearest 10, 100, etc. If `digits` is
  `NULL`, no rounding is performed and the exact range is returned.

- na_rm:

  A logical flag indicating whether `NA` values should be removed before
  computing the range. If `TRUE`, the range is computed from non-`NA`
  values only. If `FALSE` and `x` contains any `NA` values, the function
  returns `c(NA, NA)`.

## Value

A numeric vector of length two with the rounded lower and upper bounds
of the range of `x`. The lower bound is always rounded down, and the
upper bound is always rounded up. If `x` is `NULL` or has length zero,
the function returns `NULL`.

## See also

[`floor()`](https://rdrr.io/r/base/Round.html),
[`ceiling()`](https://rdrr.io/r/base/Round.html)

## Author

Michal Burda

## Examples

``` r
bound_range(c(1.9, 2, 3.1), digits = 0)      # returns c(1, 4)
#> [1] 1 4
bound_range(c(190, 200, 301), digits = -2)   # returns c(100, 400)
#> [1] 100 400
```

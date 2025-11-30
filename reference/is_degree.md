# Test whether an object contains numeric values from the interval \\\[0,1\]\\

Check if the input consists only of numeric values between 0 and 1,
inclusive. This is often useful when validating truth degrees,
membership values in fuzzy sets, or probabilities.

## Usage

``` r
is_degree(x, na_rm = FALSE)
```

## Arguments

- x:

  The object to be tested. Can be a numeric vector, matrix, or array.

- na_rm:

  Logical; whether to ignore `NA` values. If `TRUE`, `NA`s are treated
  as valid values. If `FALSE` and `x` contains any `NA`s, the function
  immediately returns `FALSE`.

## Value

A logical scalar. Returns `TRUE` if all (non-`NA`) elements of `x` are
numeric and lie within the closed interval \\\[0,1\]\\. Returns `FALSE`
if:

- `x` contains any `NA` values and `na_rm = FALSE`

- any element is outside the interval \\\[0,1\]\\

- `x` is not numeric

- `x` is empty (`length(x) == 0`)

## See also

[`is.numeric()`](https://rdrr.io/r/base/numeric.html)

## Author

Michal Burda

## Examples

``` r
is_degree(0.5)
#> [1] TRUE
is_degree(c(0, 0.2, 1))
#> [1] TRUE
is_degree(c(0.5, NA), na_rm = TRUE)   # TRUE
#> [1] TRUE
is_degree(c(0.5, NA), na_rm = FALSE)  # FALSE
#> [1] FALSE
is_degree(c(-0.1, 0.5))               # FALSE
#> [1] FALSE
is_degree(numeric(0))                 # FALSE
#> [1] TRUE
```

# Determine whether one vector is a subset of another

Check if all elements of `x` are also contained in `y`. This is
equivalent to testing whether `setdiff(x, y)` is empty.

## Usage

``` r
is_subset(x, y)
```

## Arguments

- x:

  The first vector.

- y:

  The second vector.

## Value

A logical scalar. Returns `TRUE` if `x` is a subset of `y`, i.e. all
elements of `x` are also elements of `y`. Returns `FALSE` otherwise.

## Details

- If `x` is empty, the result is always `TRUE` (the empty set is a
  subset of any set).

- If `y` is empty and `x` is not, the result is `FALSE`.

- Duplicates in `x` are ignored; only set membership is tested.

- `NA` values are treated as ordinary elements. In particular, `NA` in
  `x` is considered a subset element only if `NA` is also present in
  `y`.

## See also

[`generics::setdiff()`](https://generics.r-lib.org/reference/setops.html),
[`generics::intersect()`](https://generics.r-lib.org/reference/setops.html),
[`generics::union()`](https://generics.r-lib.org/reference/setops.html)

## Author

Michal Burda

## Examples

``` r
is_subset(1:3, 1:5)               # TRUE
#> [1] TRUE
is_subset(c(2, 5), 1:4)           # FALSE
#> [1] FALSE
is_subset(numeric(0), 1:5)        # TRUE
#> [1] TRUE
is_subset(1:3, numeric(0))        # FALSE
#> [1] FALSE
is_subset(c(1, NA), c(1, 2, NA))  # TRUE
#> [1] TRUE
is_subset(c(NA), 1:5)             # FALSE
#> [1] FALSE
```

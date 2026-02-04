# Check if an object is logical or numeric with only 0s and 1s

Check if an object is logical or numeric with only 0s and 1s

## Usage

``` r
is_logicalish(x)
```

## Arguments

- x:

  An R object to check.

## Value

A logical value indicating whether `x` is logical or numeric containing
only 0s and 1s.

## Author

Michal Burda

## Examples

``` r
is_logicalish(c(TRUE, FALSE, NA))        # returns TRUE
#> [1] TRUE
is_logicalish(c(0, 1, 1, 0, NA))         # returns TRUE
#> [1] TRUE
is_logicalish(c(0.0, 1.0, NA))           # returns TRUE
#> [1] TRUE
is_logicalish(c(0, 0.5, 1))              # returns FALSE
#> [1] FALSE
is_logicalish("TRUE")                    # returns FALSE
#> [1] FALSE
```

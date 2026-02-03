# Test whether an object is a nugget

Check if the given object is a nugget, i.e. an object created by
[`nugget()`](https://beerda.github.io/nuggets/reference/nugget.md). If a
`flavour` is specified, the function returns `TRUE` only if the object
is a nugget of the given flavour.

Technically, nuggets are implemented as S3 objects. An object is
considered a nugget if it inherits from the S3 class `"nugget"`. It is a
nugget of a given flavour if it inherits from both the specified
`flavour` class and the `"nugget"` class.

## Usage

``` r
is_nugget(x, flavour = NULL)
```

## Arguments

- x:

  An object to be tested.

- flavour:

  Optional character string specifying the required flavour of the
  nugget. If `NULL` (default), the function checks only whether `x` is a
  nugget of any flavour.

## Value

A logical scalar: `TRUE` if `x` is a nugget (and of the specified
flavour, if given), otherwise `FALSE`.

## See also

[`nugget()`](https://beerda.github.io/nuggets/reference/nugget.md)

## Author

Michal Burda

## Examples

``` r
d <- partition(mtcars, .breaks = 2)
rules <- dig_associations(d, min_support = 0.3)
is_nugget(rules)
#> [1] TRUE
is_nugget(rules, "associations")
#> [1] TRUE
is_nugget(mtcars)
#> [1] FALSE
```

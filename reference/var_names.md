# Extract variable names from predicate names

This function extracts the variable part from a character vector of
predicate names. Each element of `x` is expected to follow the pattern
`<varname>=<value>`, where `<varname>` is a variable name and `<value>`
is the associated value.

## Usage

``` r
var_names(x)
```

## Arguments

- x:

  A character vector of predicate names.

## Value

A character vector containing the `<varname>` parts of predicate names
in `x`. If an element does not contain `=`, the entire string is
returned as is. If `x` is `NULL`, the function returns `NULL`. If `x`
has length zero (`character(0)`), the function returns `character(0)`.

## Details

If an element does not contain an equal sign (`=`), the entire string is
returned unchanged.

This function is the counterpart to
[`values()`](https://beerda.github.io/nuggets/reference/values.md),
which extracts the value part of predicates. Together, `var_names()` and
[`values()`](https://beerda.github.io/nuggets/reference/values.md)
provide a convenient way to split predicate strings into their variable
and value components.

## See also

[`values()`](https://beerda.github.io/nuggets/reference/values.md)

## Author

Michal Burda

## Examples

``` r
var_names(c("a=1", "a=2", "b=x", "b=y"))
#> [1] "a" "a" "b" "b"
# returns c("a", "a", "b", "b")

var_names(c("a", "b=3"))
#> [1] "a" "b"
# returns c("a", "b")

var_names(character(0))
#> character(0)
# returns character(0)

var_names(NULL)
#> NULL
# returns character(0)
```

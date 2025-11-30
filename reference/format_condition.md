# Format a vector of predicates into a condition string

Convert a character vector of predicate names into a standardized string
representation of a condition. Predicates are concatenated with commas
and enclosed in curly braces. This formatting ensures consistency when
storing or comparing conditions in other functions.

## Usage

``` r
format_condition(condition)
```

## Arguments

- condition:

  A character vector of predicate names to be formatted. If `NULL` or of
  length zero, the result is `"{}"`, representing an empty condition
  that is always true.

## Value

A character scalar containing the formatted condition string.

## See also

[`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md),
[`fire()`](https://beerda.github.io/nuggets/reference/fire.md)

## Author

Michal Burda

## Examples

``` r
format_condition(NULL)
#> [1] "{}"
format_condition(character(0))
#> [1] "{}"
format_condition(c("a", "b", "c"))
#> [1] "{a,b,c}"
```

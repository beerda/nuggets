# Remove invalid conditions from a list

From a given list of character vectors, remove those elements that are
not valid conditions.

## Usage

``` r
remove_ill_conditions(x, data)
```

## Arguments

- x:

  A list of character vectors, each representing a condition.

- data:

  A matrix or data frame whose column names define valid predicates.

## Value

A list containing only those elements of `x` that are valid conditions.

## Details

A valid condition is a character vector of predicates, where each
predicate corresponds to a column name in the supplied data frame or
matrix. Empty character vectors and `NULL` elements are also considered
valid conditions.

This function acts as a simple filter around
[`is_condition()`](https://beerda.github.io/nuggets/reference/is_condition.md).
It checks each element of `x` against the column names of `data` and
removes those that contain invalid predicates. The result preserves only
valid conditions and discards the invalid ones.

## See also

[`is_condition()`](https://beerda.github.io/nuggets/reference/is_condition.md)

## Author

Michal Burda

## Examples

``` r
d <- data.frame(foo = 1:5, bar = 1:5, blah = 1:5)

conds <- list(c("foo", "bar"), "blah", "invalid", character(0), NULL)
remove_ill_conditions(conds, d)
#> [[1]]
#> [1] "foo" "bar"
#> 
#> [[2]]
#> [1] "blah"
#> 
#> [[3]]
#> character(0)
#> 
#> [[4]]
#> NULL
#> 
# keeps "foo","bar"; "blah"; empty; NULL
```

# Check whether a list of character vectors contains valid conditions

A valid condition is a character vector of predicate names, where each
predicate corresponds to a column name in a given data frame or matrix.
This function verifies that each element of a list `x` contains only
valid predicates that match column names of `data`.

Special cases:

- An empty character vector (`character(0)`) is considered a valid
  condition and always passes the check.

- A `NULL` element is treated the same as an empty character vector,
  i.e., it is also a valid condition.

## Usage

``` r
is_condition(x, data)
```

## Arguments

- x:

  A list of character vectors, each representing a condition.

- data:

  A matrix or data frame whose column names define valid predicates.

## Value

A logical vector with one element for each condition in `x`. An element
is `TRUE` if the corresponding condition is valid, i.e. all of its
predicates are column names of `data`. Otherwise, it is `FALSE`.

## See also

[`remove_ill_conditions()`](https://beerda.github.io/nuggets/reference/remove_ill_conditions.md),
[`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md)

## Author

Michal Burda

## Examples

``` r
d <- data.frame(foo = 1:5, bar = 1:5, blah = 1:5)

is_condition(list("foo"), d)
#> [1] TRUE
is_condition(list(c("bar", "blah"), NULL, c("foo", "bzz")), d)
#> [1]  TRUE  TRUE FALSE
```

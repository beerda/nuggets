# Dig ancestors of an association rule

**\[experimental\]**

Searches for all association rules that are ancestors of the given
association rule, i.e. all rules whose antecedent is a subset of the
antecedent of the given rule and whose consequent is equal to the
consequent of the given rule. The search is performed using the same
`disjoint`, `excluded`, and `t_norm` parameters as the original search
that produced the given rule.

## Usage

``` r
# S3 method for class 'associations'
dig_ancestors(x, data, ...)

dig_ancestors(x, data, ...)
```

## Arguments

- x:

  A nugget of flavour `associations` containing a single association
  rule. (Typically created with
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).)

- data:

  a matrix or data frame with data to search in. The matrix must be
  numeric (double) or logical. If `x` is a data frame then each column
  must be either numeric (double) or logical.

- ...:

  further arguments (currently not used).

## Value

A nugget of flavour `associations` containing all association rules that
are ancestors of the given rule `x`.

## See also

[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)

## Author

Michal Burda

## Examples

``` r
d <- partition(mtcars, .breaks = 2)
rules <- dig_associations(d,
                          antecedent = !starts_with("mpg"),
                          consequent = starts_with("mpg"),
                          min_support = 0.3,
                          min_confidence = 0.8)
r <- rules[1, ]  # get first rule
anc <- dig_ancestors(r, d)
```

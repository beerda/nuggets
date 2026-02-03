# Obtain truth-degrees of conditions

Given a data frame or matrix of truth values for predicates, compute the
truth values of a set of conditions expressed as elementary
conjunctions.

Each element of `condition` must be a character string of the format
`"{p1,p2,p3}"`, where `"p1"`, `"p2"`, and `"p3"` are predicate names.
The data object `x` must contain columns whose names correspond exactly
to all predicates referenced in the conditions. Each condition is
evaluated for every row of `x` as a conjunction of its predicates, with
the conjunction operation determined by the `t_norm` argument. An empty
condition (`"{}"`) is always evaluated as 1 (i.e., fully true).

## Usage

``` r
fire(x, condition, t_norm = "goguen")
```

## Arguments

- x:

  A matrix or data frame containing predicate truth values. If `x` is a
  matrix, it must be numeric (double) or logical. If `x` is a data
  frame, all columns must be numeric (double) or logical.

- condition:

  A character vector of conditions, each formatted according to
  [`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md).
  For example, `"{p1,p2,p3}"` represents a condition composed of three
  predicates `"p1"`, `"p2"`, and `"p3"`. Every predicate mentioned in
  `condition` must be present as a column in `x`.

- t_norm:

  A string specifying the triangular norm (t-norm) used to compute
  conjunctions of predicate values. Must be one of `"goedel"` (minimum
  t-norm), `"goguen"` (product t-norm), or `"lukas"` (Łukasiewicz
  t-norm).

## Value

A numeric matrix with entries in the interval \\\[0, 1\]\\ giving the
truth degrees of the conditions. The matrix has `nrow(x)` rows and
`length(condition)` columns. The element in row *i* and column *j*
corresponds to the truth degree of the *j*-th condition evaluated on the
*i*-th row of `x`.

## See also

[`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md),
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md)

## Author

Michal Burda

## Examples

``` r
d <- data.frame(
  a = c(1, 0.8, 0.5, 0.2, 0),
  b = c(0.5, 1, 0.5, 0, 1),
  c = c(0.9, 0.9, 0.1, 0.8, 0.7)
)

# Evaluate conditions with different t-norms
fire(d, c("{a,c}", "{}", "{a,b,c}"), t_norm = "goguen")
#>      [,1] [,2]  [,3]
#> [1,] 0.90    1 0.450
#> [2,] 0.72    1 0.720
#> [3,] 0.05    1 0.025
#> [4,] 0.16    1 0.000
#> [5,] 0.00    1 0.000
fire(d, c("{a,c}", "{a,b}"), t_norm = "goedel")
#>      [,1] [,2]
#> [1,]  0.9  0.5
#> [2,]  0.8  0.8
#> [3,]  0.1  0.5
#> [4,]  0.2  0.0
#> [5,]  0.0  0.0
fire(d, c("{b,c}"), t_norm = "lukas")
#>      [,1]
#> [1,]  0.4
#> [2,]  0.9
#> [3,]  0.0
#> [4,]  0.0
#> [5,]  0.7
```

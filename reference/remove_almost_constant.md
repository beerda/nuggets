# Remove almost constant columns from a data frame

Test all columns specified by `.what` and remove those that are almost
constant. A column is considered almost constant if the proportion of
its most frequent value is greater than or equal to the threshold
specified by `.threshold`. See
[`is_almost_constant()`](https://beerda.github.io/nuggets/reference/is_almost_constant.md)
for further details.

## Usage

``` r
remove_almost_constant(
  .data,
  .what = everything(),
  ...,
  .threshold = 1,
  .na_rm = FALSE,
  .verbose = FALSE
)
```

## Arguments

- .data:

  A data frame.

- .what:

  A tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the columns to process.

- ...:

  Additional tidyselect expressions selecting more columns.

- .threshold:

  Numeric scalar in the interval \\\[0,1\]\\ giving the minimum required
  proportion of the most frequent value for a column to be considered
  almost constant.

- .na_rm:

  Logical; if `TRUE`, `NA` values are removed before computing
  proportions. If `FALSE`, `NA` is treated as a regular value. See
  [`is_almost_constant()`](https://beerda.github.io/nuggets/reference/is_almost_constant.md)
  for details.

- .verbose:

  Logical; if `TRUE`, print a message listing the removed columns.

## Value

A data frame with all selected columns removed that meet the definition
of being almost constant.

## See also

[`is_almost_constant()`](https://beerda.github.io/nuggets/reference/is_almost_constant.md),
[`remove_ill_conditions()`](https://beerda.github.io/nuggets/reference/remove_ill_conditions.md)

## Author

Michal Burda

## Examples

``` r
d <- data.frame(a1 = 1:10,
                a2 = c(1:9, NA),
                b1 = "b",
                b2 = NA,
                c1 = rep(c(TRUE, FALSE), 5),
                c2 = rep(c(TRUE, NA), 5),
                d  = c(rep(TRUE, 4), rep(FALSE, 4), NA, NA))

# Remove columns that are constant (threshold = 1)
remove_almost_constant(d, .threshold = 1.0, .na_rm = FALSE)
#> # A tibble: 10 × 5
#>       a1    a2 c1    c2    d    
#>    <int> <int> <lgl> <lgl> <lgl>
#>  1     1     1 TRUE  TRUE  TRUE 
#>  2     2     2 FALSE NA    TRUE 
#>  3     3     3 TRUE  TRUE  TRUE 
#>  4     4     4 FALSE NA    TRUE 
#>  5     5     5 TRUE  TRUE  FALSE
#>  6     6     6 FALSE NA    FALSE
#>  7     7     7 TRUE  TRUE  FALSE
#>  8     8     8 FALSE NA    FALSE
#>  9     9     9 TRUE  TRUE  NA   
#> 10    10    NA FALSE NA    NA   
remove_almost_constant(d, .threshold = 1.0, .na_rm = TRUE)
#> # A tibble: 10 × 4
#>       a1    a2 c1    d    
#>    <int> <int> <lgl> <lgl>
#>  1     1     1 TRUE  TRUE 
#>  2     2     2 FALSE TRUE 
#>  3     3     3 TRUE  TRUE 
#>  4     4     4 FALSE TRUE 
#>  5     5     5 TRUE  FALSE
#>  6     6     6 FALSE FALSE
#>  7     7     7 TRUE  FALSE
#>  8     8     8 FALSE FALSE
#>  9     9     9 TRUE  NA   
#> 10    10    NA FALSE NA   

# Remove columns where the majority value occurs in >= 50% of rows
remove_almost_constant(d, .threshold = 0.5, .na_rm = FALSE)
#> # A tibble: 10 × 3
#>       a1    a2 d    
#>    <int> <int> <lgl>
#>  1     1     1 TRUE 
#>  2     2     2 TRUE 
#>  3     3     3 TRUE 
#>  4     4     4 TRUE 
#>  5     5     5 FALSE
#>  6     6     6 FALSE
#>  7     7     7 FALSE
#>  8     8     8 FALSE
#>  9     9     9 NA   
#> 10    10    NA NA   
remove_almost_constant(d, .threshold = 0.5, .na_rm = TRUE)
#> # A tibble: 10 × 2
#>       a1    a2
#>    <int> <int>
#>  1     1     1
#>  2     2     2
#>  3     3     3
#>  4     4     4
#>  5     5     5
#>  6     6     6
#>  7     7     7
#>  8     8     8
#>  9     9     9
#> 10    10    NA

# Restrict check to a subset of columns
remove_almost_constant(d, a1:b2, .threshold = 0.5, .na_rm = TRUE)
#> # A tibble: 10 × 5
#>       a1    a2 c1    c2    d    
#>    <int> <int> <lgl> <lgl> <lgl>
#>  1     1     1 TRUE  TRUE  TRUE 
#>  2     2     2 FALSE NA    TRUE 
#>  3     3     3 TRUE  TRUE  TRUE 
#>  4     4     4 FALSE NA    TRUE 
#>  5     5     5 TRUE  TRUE  FALSE
#>  6     6     6 FALSE NA    FALSE
#>  7     7     7 TRUE  TRUE  FALSE
#>  8     8     8 FALSE NA    FALSE
#>  9     9     9 TRUE  TRUE  NA   
#> 10    10    NA FALSE NA    NA   
```

# Generate all permutations of a vector

This function generates all possible permutations of the elements in a
given vector `x`. The result is returned as a matrix, where each row
represents a unique permutation of the input vector.

## Usage

``` r
permute(x)
```

## Arguments

- x:

  A vector of elements to permute. The elements can be of any type, but
  they should be unique for meaningful permutations.

## Value

A matrix where each row is a unique permutation of the input vector `x`.

## See also

[`utils::combn()`](https://rdrr.io/r/utils/combn.html) for combinations
of elements.

## Author

Michal Burda

## Examples

``` r
permute(c(1, 2, 3))
#>      [,1] [,2] [,3]
#> [1,]    1    2    3
#> [2,]    1    3    2
#> [3,]    2    1    3
#> [4,]    2    3    1
#> [5,]    3    1    2
#> [6,]    3    2    1
permute(c("a", "b", "c"))
#>      [,1] [,2] [,3]
#> [1,] "a"  "b"  "c" 
#> [2,] "a"  "c"  "b" 
#> [3,] "b"  "a"  "c" 
#> [4,] "b"  "c"  "a" 
#> [5,] "c"  "a"  "b" 
#> [6,] "c"  "b"  "a" 
```

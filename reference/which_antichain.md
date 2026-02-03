# Return indices of first elements of the list, which are incomparable with preceding elements.

The function returns indices of elements from the given list `x`, which
are incomparable (i.e., it is neither subset nor superset) with any
preceding element. The first element is always selected. The next
element is selected only if it is incomparable with all previously
selected elements.

## Usage

``` r
which_antichain(x, distance = 0)
```

## Arguments

- x:

  a list of integerish vectors

- distance:

  a non-negative integer, which specifies the allowed discrepancy
  between compared sets

## Value

an integer vector of indices of selected (incomparable) elements.

## Author

Michal Burda

## Examples

``` r
# Create a list of integerish vectors
x <- list(c(1, 2), c(1, 2, 3), c(2, 3), c(1, 3), c(4, 5))

# Find incomparable elements
which_antichain(x)
#> [1] 1 3 4 5
```

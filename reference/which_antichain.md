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

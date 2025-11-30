# Create an association matrix from a nugget of flavour `associations`.

The association matrix is a matrix where rows correspond to antecedents,
columns correspond to consequents, and the values are taken from a
specified column of the nugget. Missing values are filled with zeros.

## Usage

``` r
association_matrix(
  x,
  value,
  error_context = list(arg_x = "x", arg_value = "value", call = current_env())
)
```

## Arguments

- x:

  A nugget of flavour `associations`.

- value:

  A tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the column to use for filling the matrix values.

- error_context:

  A list of details to be used in error messages. It must contain: -
  `arg_x`: the name of the `x` argument; - `arg_value`: the name of the
  `value` argument; - `call`: an environment in which to evaluate the
  error messages. Defaults to the current environment.

## Value

A numeric matrix with row names corresponding to antecedents and column
names corresponding to consequents. Values are taken from the column
specified by `value`. Missing values are filled with zeros.

## Details

A pair of antecedent and consequent must be unique in the nugget. If
there are multiple rows with the same pair, an error is raised.

## Author

Michal Burda

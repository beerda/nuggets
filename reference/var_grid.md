# Create a tibble of combinations of selected column names

The `xvars` and `yvars` arguments are tidyselect expressions (see
[tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
that specify the columns of `x` whose names will be used to form
combinations.

If `yvars` is `NULL`, the function creates a tibble with one column,
`var`, enumerating all column names selected by the `xvars` expression.

If `yvars` is not `NULL`, the function creates a tibble with two
columns, `xvar` and `yvar`, whose rows enumerate all combinations of
column names specified by `xvars` and `yvars`.

It is allowed to specify the same column in both `xvars` and `yvars`. In
such cases, self-combinations (a column paired with itself) are removed
from the result.

In other words, the function creates a grid of all possible pairs \\(xx,
yy)\\ where \\xx \in xvars\\, \\yy \in yvars\\, and \\xx \neq yy\\.

## Usage

``` r
var_grid(
  x,
  xvars = everything(),
  yvars = everything(),
  allow = "all",
  disjoint = var_names(colnames(x)),
  xvar_name = if (quo_is_null(enquo(yvars))) "var" else "xvar",
  yvar_name = "yvar",
  error_context = list(arg_x = "x", arg_xvars = "xvars", arg_yvars = "yvars", arg_allow =
    "allow", arg_disjoint = "disjoint", arg_xvar_name = "xvar_name", arg_yvar_name =
    "yvar_name", call = current_env())
)
```

## Arguments

- x:

  A data frame or matrix.

- xvars:

  A tidyselect expression specifying the columns of `x` whose names will
  be used in the first position (`xvar`) of the combinations.

- yvars:

  `NULL` or a tidyselect expression specifying the columns of `x` whose
  names will be used in the second position (`yvar`) of the
  combinations.

- allow:

  A character string specifying which columns may be selected by `xvars`
  and `yvars`. Possible values are:

  - `"all"` – all columns may be selected;

  - `"numeric"` – only numeric columns may be selected.

- disjoint:

  An atomic vector of length equal to the number of columns in `x` that
  specifies disjoint groups of predicates. Columns belonging to the same
  group (i.e. having the same value in `disjoint`) will not appear
  together in a single combination of `xvars` and `yvars`. Ignored if
  `yvars` is `NULL`.

- xvar_name:

  A character string specifying the name of the first column (`xvar`) in
  the output tibble.

- yvar_name:

  A character string specifying the name of the second column (`yvar`)
  in the output tibble. This column is omitted if `yvars` is `NULL`.

- error_context:

  A list providing details for error messages. This is useful when
  `var_grid()` is called from another function, allowing error messages
  to reference the caller’s argument names. The list must contain:

  - `arg_x` – name of the argument `x`;

  - `arg_xvars` – name of the argument `xvars`;

  - `arg_yvars` – name of the argument `yvars`;

  - `arg_allow` – name of the argument `allow`;

  - `arg_xvar_name` – name of the `xvar` column in the output;

  - `arg_yvar_name` – name of the `yvar` column in the output;

  - `call` – the calling environment for evaluating error messages.

## Value

If `yvars` is `NULL`, a tibble with a single column (`var`). If `yvars`
is not `NULL`, a tibble with two columns (`xvar`, `yvar`) enumerating
all valid combinations of column names selected by `xvars` and `yvars`.
The order of variables in the result follows the order in which they are
selected by `xvars` and `yvars`.

## Details

`var_grid()` is typically used when a function requires a systematic
list of variables or variable pairs to analyze. For example, it can be
used to generate all pairs of variables for correlation, association, or
contrast analysis. The flexibility of `xvars` and `yvars` makes it
possible to restrict the grid to specific subsets of variables while
ensuring that invalid or redundant combinations (e.g., self-pairs or
disjoint groups) are excluded automatically.

The `allow` argument can be used to restrict the selection of columns to
numeric columns only. This is useful when the resulting variable
combinations will be used in analyses that require numeric data, such as
correlation or contrast tests.

The `disjoint` argument allows specifying groups of columns that should
not appear together in a single combination. This is useful when certain
columns represent mutually exclusive categories or measurements that
should not be analyzed together. For example, if `disjoint` groups
columns by measurement type, the function will ensure that no
combination includes two columns from the same type.

## Author

Michal Burda

## Examples

``` r
# Grid of all pairwise column combinations in CO2
var_grid(CO2)
#> # A tibble: 10 × 2
#>    xvar      yvar     
#>    <chr>     <chr>    
#>  1 Plant     Type     
#>  2 Plant     Treatment
#>  3 Plant     conc     
#>  4 Plant     uptake   
#>  5 Type      Treatment
#>  6 Type      conc     
#>  7 Type      uptake   
#>  8 Treatment conc     
#>  9 Treatment uptake   
#> 10 conc      uptake   

# Grid of combinations where the first column is Plant, Type, or Treatment,
# and the second column is conc or uptake
var_grid(CO2, xvars = Plant:Treatment, yvars = conc:uptake)
#> # A tibble: 6 × 2
#>   xvar      yvar  
#>   <chr>     <chr> 
#> 1 Plant     conc  
#> 2 Plant     uptake
#> 3 Type      conc  
#> 4 Type      uptake
#> 5 Treatment conc  
#> 6 Treatment uptake

# Prevent variables from the same disjoint group from being paired together
d <- data.frame(a = 1:5, b = 6:10, c = 11:15, d = 16:20)
# Group (a, b) together and (c, d) together
var_grid(d, xvars = everything(), yvars = everything(),
         disjoint = c(1, 1, 2, 2))
#> # A tibble: 4 × 2
#>   xvar  yvar 
#>   <chr> <chr>
#> 1 a     c    
#> 2 a     d    
#> 3 b     c    
#> 4 b     d    
```

# Create a nugget object of a given flavour

Construct a nugget object, which is an S3 object used to store and
represent results (e.g., rules or patterns) in the `nuggets` framework.

## Usage

``` r
nugget(x, flavour, call_function, call_data, call_args)
```

## Arguments

- x:

  An object with rules or patterns, typically a tibble or data frame. If
  `NULL`, it will be converted to an empty tibble.

- flavour:

  A character string specifying the flavour of the nugget, or `NULL` if
  no flavour should be assigned. If given, the returned object will
  inherit from both `"nugget"` and the specified flavour class.

- call_function:

  A character scalar giving the name of the function that created the
  nugget. Stored as an attribute for provenance.

- call_data:

  A list containing information about the data that was passed to the
  function which created the nugget. Stored as an attribute for
  reproducibility.

- call_args:

  A list of arguments that were passed to the function which created the
  nugget. Stored as an attribute for reproducibility.

## Value

A tibble object that is an S3 subclass of `"nugget"` and, if specified,
the given `flavour` class. The object also contains attributes
`"call_function"` and `"call_args"` describing its provenance.

## Details

A nugget is technically a tibble (or data frame) that inherits from both
the `"nugget"` class and, optionally, a flavour-specific S3 class. This
allows distinguishing different types of nuggets (flavours) while still
supporting generic methods for all nuggets.

Each nugget stores additional provenance information in attributes:

- `"call_function"` — the name of the function that created the nugget.

- `"call_args"` — the list of arguments passed to that function.

These attributes make it possible to reconstruct or track how the nugget
was created, which supports reproducibility, transparency, and
debugging. For example, one can inspect `attr(n, "call_args")` to
recover the original parameters used to mine the patterns.

## See also

[`is_nugget()`](https://beerda.github.io/nuggets/reference/is_nugget.md)

## Author

Michal Burda

## Examples

``` r
df <- data.frame(lhs = c("a", "b"), rhs = c("c", "d"))
n <- nugget(df,
            flavour = "rules",
            call_function = "example_function",
            call_data = list(ncol = 2,
                             nrow = 2,
                             colnames = c("lhs", "rhs")),
            call_args = list(data = "mydata"))

inherits(n, "nugget")      # TRUE
#> [1] TRUE
inherits(n, "rules")       # TRUE
#> [1] TRUE
attr(n, "call_function")   # "dig_example_function"
#> [1] "example_function"
attr(n, "call_args")       # list(data = "mydata")
#> $data
#> [1] "mydata"
#> 
```

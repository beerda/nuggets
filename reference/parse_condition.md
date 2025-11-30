# Convert condition strings into lists of predicate vectors

Parse a character vector of conditions into a list of predicate vectors.
Each element of the list corresponds to one condition. A condition is a
string of predicates separated by commas and enclosed in curly braces,
as produced by
[`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md).
The function splits each string into its component predicates.

## Usage

``` r
parse_condition(..., .sort = FALSE)
```

## Arguments

- ...:

  One or more character vectors of conditions to be parsed.

- .sort:

  Logical flag indicating whether the predicates in each result should
  be sorted alphabetically. Defaults to `FALSE`.

## Value

A list of character vectors, where each element corresponds to one
condition and contains the parsed predicates.

## Details

If multiple vectors of conditions are provided via `...`, they are
combined element-wise. The result is a single list where each element is
formed by merging the predicates from the corresponding elements of all
input vectors. If the input vectors differ in length, shorter ones are
recycled.

Empty conditions (`"{}"`) are parsed as empty character vectors
(`character(0)`).

## See also

[`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md),
[`is_condition()`](https://beerda.github.io/nuggets/reference/is_condition.md),
[`fire()`](https://beerda.github.io/nuggets/reference/fire.md)

## Author

Michal Burda

## Examples

``` r
parse_condition(c("{a}", "{x=1, z=2, y=3}", "{}"))
#> [[1]]
#> [1] "a"
#> 
#> [[2]]
#> [1] "x=1" "z=2" "y=3"
#> 
#> [[3]]
#> character(0)
#> 

# Merge conditions from multiple vectors element-wise
parse_condition(c("{b}", "{x=1, z=2, y=3}", "{q}", "{}"),
                c("{a}", "{v=10, w=11}",    "{}",  "{r,s,t}"))
#> [[1]]
#> [1] "b" "a"
#> 
#> [[2]]
#> [1] "x=1"  "z=2"  "y=3"  "v=10" "w=11"
#> 
#> [[3]]
#> [1] "q"
#> 
#> [[4]]
#> [1] "r" "s" "t"
#> 

# Sorting predicates within each condition
parse_condition("{z,y,x}", .sort = TRUE)
#> [[1]]
#> [1] "x" "y" "z"
#> 
```

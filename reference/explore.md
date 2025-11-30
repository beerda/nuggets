# Show interactive application to explore association rules

**\[experimental\]**

Launches an interactive Shiny application for visual exploration of
mined association rules. The explorer provides tools for inspecting rule
quality, comparing interestingness measures, and interactively filtering
subsets of rules. When the original dataset is supplied, the application
also allows for contextual exploration of rules with respect to the
underlying data.

## Usage

``` r
# S3 method for class 'associations'
explore(x, data = NULL, ...)
```

## Arguments

- x:

  An object of S3 class `associations`, typically created with
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).

- data:

  An optional data frame containing the dataset from which the rules
  were mined. Providing this enables additional contextual features in
  the explorer, such as examining supporting records.

- ...:

  Currently ignored.

## Value

An object of class `shiny.appobj` representing the Shiny application.
When "printed" in an interactive R session, the application is launched
immediately in the default web browser.

## See also

[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)

## Author

Michal Burda

## Examples

``` r
if (FALSE) { # \dontrun{
data("iris")
# convert all columns into dummy logical variables
part <- partition(iris, .breaks = 3)

# find association rules
rules <- dig_associations(part)

# launch the interactive explorer
explore(rules, data = part)
} # }
```

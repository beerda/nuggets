# Show interactive application to explore conditional correlations

**\[experimental\]**

Launches an interactive Shiny application for visual exploration of
conditional correlation patterns. The explorer provides tools for
inspecting pattern quality, comparing measures, and interactively
filtering subsets of patterns. When the original dataset is supplied,
the application also allows for contextual exploration of correlations
with respect to the underlying data.

## Usage

``` r
# S3 method for class 'correlations'
explore(x, data = NULL, ...)
```

## Arguments

- x:

  An object of S3 class `correlations`, typically created with
  [`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md).

- data:

  An optional data frame containing the dataset from which the
  correlations were computed. Providing this enables additional
  contextual features in the explorer, such as examining supporting
  records.

- ...:

  Currently ignored.

## Value

An object of class `shiny.appobj` representing the Shiny application.
When "printed" in an interactive R session, the application is launched
immediately in the default web browser.

## See also

[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)

## Author

Michal Burda

## Examples

``` r
if (FALSE) { # \dontrun{
d <- partition(iris, Species)
res <- dig_correlations(d,
                        condition = where(is.logical),
                        xvars = Sepal.Length:Petal.Width,
                        yvars = Sepal.Length:Petal.Width)

# launch the interactive explorer
explore(res, data = d)
} # }
```

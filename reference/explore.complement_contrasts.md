# Show interactive application to explore complement contrasts

**\[experimental\]**

Launches an interactive Shiny application for visual exploration of
complement contrast patterns. The explorer provides tools for inspecting
pattern quality, comparing measures, and interactively filtering subsets
of patterns. When the original dataset is supplied, the application also
allows for contextual exploration of contrasts with respect to the
underlying data.

## Usage

``` r
# S3 method for class 'complement_contrasts'
explore(x, data = NULL, ...)
```

## Arguments

- x:

  An object of S3 class `complement_contrasts`, typically created with
  [`dig_complement_contrasts()`](https://beerda.github.io/nuggets/reference/dig_complement_contrasts.md).

- data:

  An optional data frame containing the dataset from which the contrasts
  were computed. Providing this enables additional contextual features
  in the explorer, such as examining supporting records.

- ...:

  Currently ignored.

## Value

An object of class `shiny.appobj` representing the Shiny application.
When "printed" in an interactive R session, the application is launched
immediately in the default web browser.

## See also

[`dig_complement_contrasts()`](https://beerda.github.io/nuggets/reference/dig_complement_contrasts.md)

## Author

Michal Burda

## Examples

``` r
if (FALSE) { # \dontrun{
d <- partition(mtcars, .breaks = 2, .keep = TRUE)
res <- dig_complement_contrasts(d,
                                condition = where(is.logical),
                                vars = where(is.numeric),
                                min_support = 0.3,
                                max_length = 2)

# launch the interactive explorer
explore(res, data = d)
} # }
```

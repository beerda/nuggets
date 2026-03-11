# Show interactive application to explore paired baseline contrasts

**\[experimental\]**

Launches an interactive Shiny application for visual exploration of
paired baseline contrast patterns. The explorer provides tools for
inspecting pattern quality, comparing measures, and interactively
filtering subsets of patterns. When the original dataset is supplied,
the application also allows for contextual exploration of contrasts with
respect to the underlying data.

## Usage

``` r
# S3 method for class 'paired_baseline_contrasts'
explore(x, data = NULL, ...)
```

## Arguments

- x:

  An object of S3 class `paired_baseline_contrasts`, typically created
  with
  [`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md).

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

[`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md)

## Author

Michal Burda

## Examples

``` r
if (FALSE) { # \dontrun{
crispIris <- iris
crispIris$Sepal.Ratio <- iris$Sepal.Length / iris$Sepal.Width
crispIris$Petal.Ratio <- iris$Petal.Length / iris$Petal.Width
crispIris <- partition(crispIris, Species)
res <- dig_paired_baseline_contrasts(crispIris,
                                     condition = where(is.logical),
                                     xvars = Sepal.Ratio,
                                     yvars = Petal.Ratio,
                                     method = "t",
                                     min_support = 0.1)

# launch the interactive explorer
explore(res, data = crispIris)
} # }
```

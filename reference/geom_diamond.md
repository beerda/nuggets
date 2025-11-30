# Geom for drawing diamond plots of lattice structures

Create a custom `ggplot2` geom for visualizing lattice structures as
*diamond plots*. This geom is particularly useful for displaying
association rules and their ancestor–descendant relationships in a
clear, compact graphical form.

## Usage

``` r
geom_diamond(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  linetype = "solid",
  linewidth = NA,
  nudge_x = 0,
  nudge_y = 0.125,
  show.legend = NA,
  inherit.aes = TRUE,
  ...
)
```

## Arguments

- mapping:

  Aesthetic mappings, usually created with
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

- data:

  A data frame representing the lattice structure to plot.

- stat:

  Statistical transformation to apply; defaults to `"identity"`.

- position:

  Position adjustment for the geom; defaults to `"identity"`.

- na.rm:

  Logical; if `TRUE`, missing values are silently removed.

- linetype:

  Line type for edges; defaults to `"solid"`.

- linewidth:

  Width of edges connecting parent and child nodes. If set to `NA`, edge
  widths are determined by the `linewidth` aesthetic. If no aesthetic is
  provided, a default width of `0.5` is used.

- nudge_x:

  Horizontal nudge applied to labels.

- nudge_y:

  Vertical nudge applied to labels.

- show.legend:

  Logical; whether to include a legend. Defaults to `FALSE`.

- inherit.aes:

  Logical; whether to inherit aesthetics from the plot. Defaults to
  `TRUE`.

- ...:

  Additional arguments passed to
  [`ggplot2::layer()`](https://ggplot2.tidyverse.org/reference/layer.html).

## Value

A `ggplot2` layer object that adds a diamond lattice visualization to an
existing plot.

## Details

In a diamond plot, nodes (diamonds) represent items or conditions within
the lattice, while edges denote inclusion (subset) relationships between
them. The geom combines node and edge rendering with flexible control
over aesthetics such as labels, color, and size.

**Concept overview**

A *lattice* represents inclusion relationships between conditions. Each
node corresponds to a condition, and a line connects a condition to its
direct descendants:

           {a}          <- ancestor (parent)
          /   \
      {a,b}   {a,c}     <- direct descendants (children)
         \     /
         {a,b,c}        <- leaf condition

The layout positions broader (more general) conditions above their
descendants. This helps visualize hierarchical structures such as those
produced by association rule mining or subset lattices.

**Supported aesthetics**

- `condition` – character vector of conditions formatted with
  [`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md).
  Each condition defines one node in the lattice. The hierarchy is
  determined by subset inclusion: a condition \\X\\ is a descendant of
  \\Y\\ if \\Y \subset X\\. Each condition must be unique.

- `label` – optional text label for each node. If omitted, the condition
  string is used.

- `colour` – border color of the node.

- `fill` – interior color of the node.

- `size` – size of nodes.

- `shape` – node shape.

- `alpha` – transparency of nodes.

- `stroke` – border line width of nodes.

- `linewidth` – edge width between parent and child nodes, computed as
  the difference of this aesthetic between them.

## Author

Michal Burda

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)

# Prepare data by partitioning numeric columns into fuzzy or crisp sets
part <- partition(iris, .breaks = 3)

# Find all antecedents with "Sepal" for rules with consequent "Species=setosa"
rules <- dig_associations(part,
                          antecedent = starts_with("Sepal"),
                          consequent = `Species=setosa`,
                          min_length = 0,
                          max_length = Inf,
                          min_coverage = 0,
                          min_support = 0,
                          min_confidence = 0,
                          measures = c("lift", "conviction"),
                          max_results = Inf)

# Add abbreviated labels for readability
rules$abbrev <- shorten_condition(rules$antecedent)

# Plot the lattice of rules as a diamond diagram
ggplot(rules) +
  aes(condition = antecedent,
      fill = confidence,
      linewidth = confidence,
      size = coverage,
      label = abbrev) +
  geom_diamond()
} # }
```

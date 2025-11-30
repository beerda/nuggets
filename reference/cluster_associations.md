# Cluster association rules

This function clusters association rules based on the selected numeric
attribute `by` (e.g., confidence or lift) and summarizes the clusters.
The clustering is performed using the k-means algorithm.

## Usage

``` r
cluster_associations(
  x,
  n,
  by,
  algorithm = "Hartigan-Wong",
  predicates_in_label = 2
)
```

## Arguments

- x:

  A nugget of flavour `associations`, typically the output of
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).

- n:

  The number of clusters to create. Must be a positive integer.

- by:

  A tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) specifying
  the numeric column to use for clustering.

- algorithm:

  The k-means algorithm to use. One of `"Hartigan-Wong"` (the default),
  `"Lloyd"`, `"Forgy"`, or `"MacQueen"`. See
  [`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html) for details.

- predicates_in_label:

  The number of most common predicates to include in the cluster label.
  The default is 2.

## Value

A tibble with one row per cluster. The columns are:

- `cluster`: the cluster number;

- `cluster_label`: a label for the cluster, consisting of the number of
  rules in the cluster and the most common predicates in the antecedents
  of those rules;

- `consequent`: consequents of the rules;

- other numeric columns from the input nugget, aggregated by mean within
  each cluster.

## Details

Each cluster is represented by a label consisting of the number of rules
in the cluster and the most common predicates in the antecedents of
those rules.

## See also

[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md),
[`association_matrix()`](https://beerda.github.io/nuggets/reference/association_matrix.md)
[`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html)

## Author

Michal Burda

## Examples

``` r
# Prepare the data
cars <- mtcars |>
    partition(cyl, vs:gear, .method = "dummy") |>
    partition(carb, .method = "crisp", .breaks = c(0, 3, 10)) |>
    partition(mpg, disp:qsec, .method = "triangle", .breaks = 3)

# Search for associations
rules <- dig_associations(cars,
                          antecedent = everything(),
                          consequent = everything(),
                          max_length = 3,
                          min_support = 0.2,
                          measures = c("lift", "conviction"))
#> Warning: The `measures` argument of `dig_associations()` is deprecated as of nuggets
#> 2.1.0.
#> ℹ The `measures` argument is deprecated and will be removed in future versions.
#>   Use the `add_interest()` function on the result of
#>   `dig_associations(contingency_table = TRUE)` to compute additional measures.

# Cluster the found rules
clu <- cluster_associations(rules, 10, "lift")

if (FALSE) { # \dontrun{
# Plot the clustered rules
library(ggplot2)

ggplot(clu) +
   aes(x = cluster_label, y = consequent, color = lift, size = support) +
   geom_point() +
   xlab("predicates in antecedent groups") +
   scale_y_discrete(limits = rev) +
   theme(axis.text.x = element_text(angle = 45, hjust = 1))
} # }
```

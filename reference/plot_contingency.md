# Plot a mosaic plot for a contingency table

This function creates a mosaic plot for a contingency table defined by
the counts of true positives, false positives, false negatives, and true
negatives. The plot visually represents the distribution of these counts
in a 2x2 grid. The area of each rectangle in the plot corresponds to the
count of the respective category. Vertical and horizontal lines are
added to the plot to indicate the expected proportions of the counts
under the assumption of independence between the antecedent and the
consequent.

## Usage

``` r
# S3 method for class 'data.frame'
plot_contingency(d, ...)

# Default S3 method
plot_contingency(pp, pn, np, nn, ...)

plot_contingency(...)
```

## Arguments

- d:

  A data frame with exactly one row and columns named `pp`, `pn`, `np`,
  and `nn`, representing the counts of true positives, false positives,
  false negatives, and true negatives, respectively. All values must be
  greater or equal to zero.

- ...:

  Additional arguments (currently ignored).

- pp:

  The count of true positives (antecedent and consequent both true).
  Value must be greater or equal to zero.

- pn:

  The count of false positives (antecedent true, consequent false).
  Value must be greater or equal to zero.

- np:

  The count of false negatives (antecedent false, consequent true).
  Value must be greater or equal to zero.

- nn:

  The count of true negatives (antecedent and consequent both false).
  Value must be greater or equal to zero.

## Value

A ggplot object representing the mosaic plot of the contingency table.

## Author

Michal Burda

## Examples

``` r
plot_contingency(pp = 30, pn = 10, np = 20, nn = 40)
```

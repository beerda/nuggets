# Package index

## Data Preparation

Functions for transformation of input data into the format suitable for
pattern extraction.

- [`is_almost_constant()`](https://beerda.github.io/nuggets/reference/is_almost_constant.md)
  : Test whether a vector is almost constant
- [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
  : Convert columns of a data frame to Boolean or fuzzy sets
  (triangular, trapezoidal, or raised-cosine)
- [`remove_almost_constant()`](https://beerda.github.io/nuggets/reference/remove_almost_constant.md)
  : Remove almost constant columns from a data frame
- [`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
  : Find tautologies or "almost tautologies" in a dataset

## Pre-defined Pattern Extraction

Functions for extraction of pre-defined patterns from input data.

- [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
  **\[experimental\]** : Search for association rules
- [`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
  **\[experimental\]** : Search for conditional correlations
- [`dig_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_baseline_contrasts.md)
  **\[experimental\]** : Search for conditions that yield in
  statistically significant one-sample test in selected variables.
- [`dig_complement_contrasts()`](https://beerda.github.io/nuggets/reference/dig_complement_contrasts.md)
  **\[experimental\]** : Search for conditions that provide significant
  differences in selected variables to the rest of the data table
- [`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md)
  **\[experimental\]** : Search for conditions that provide significant
  differences between paired variables

## Custom Pattern Extraction

Functions for extraction of custom patterns from input data.

- [`dig()`](https://beerda.github.io/nuggets/reference/dig.md) : Search
  for patterns of a custom type
- [`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
  **\[experimental\]** : Search for grid-based rules

## Pattern Post-processing

Functions for post-processing of extracted patterns.

- [`association_matrix()`](https://beerda.github.io/nuggets/reference/association_matrix.md)
  :

  Create an association matrix from a nugget of flavour `associations`.

- [`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md)
  **\[experimental\]** : Add additional interest measures for
  association rules

- [`cluster_associations()`](https://beerda.github.io/nuggets/reference/cluster_associations.md)
  : Cluster association rules

- [`explore(`*`<associations>`*`)`](https://beerda.github.io/nuggets/reference/explore.md)
  **\[experimental\]** : Show interactive application to explore
  association rules

- [`geom_diamond()`](https://beerda.github.io/nuggets/reference/geom_diamond.md)
  : Geom for drawing diamond plots of lattice structures

- [`remove_ill_conditions()`](https://beerda.github.io/nuggets/reference/remove_ill_conditions.md)
  : Remove invalid conditions from a list

- [`which_antichain()`](https://beerda.github.io/nuggets/reference/which_antichain.md)
  : Return indices of first elements of the list, which are incomparable
  with preceding elements.

## Tools and Helper Functions

Other functions that can be useful in the pattern extraction process.

- [`bound_range()`](https://beerda.github.io/nuggets/reference/bound_range.md)
  : Bound a range of numeric values
- [`fire()`](https://beerda.github.io/nuggets/reference/fire.md) :
  Obtain truth-degrees of conditions
- [`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md)
  : Format a vector of predicates into a condition string
- [`is_condition()`](https://beerda.github.io/nuggets/reference/is_condition.md)
  : Check whether a list of character vectors contains valid conditions
- [`is_degree()`](https://beerda.github.io/nuggets/reference/is_degree.md)
  : Test whether an object contains numeric values from the interval
  \\\[0,1\]\\
- [`is_logicalish()`](https://beerda.github.io/nuggets/reference/is_logicalish.md)
  : Check if an object is logical or numeric with only 0s and 1s
- [`is_nugget()`](https://beerda.github.io/nuggets/reference/is_nugget.md)
  : Test whether an object is a nugget
- [`is_subset()`](https://beerda.github.io/nuggets/reference/is_subset.md)
  : Determine whether one vector is a subset of another
- [`nugget()`](https://beerda.github.io/nuggets/reference/nugget.md) :
  Create a nugget object of a given flavour
- [`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md)
  : Convert condition strings into lists of predicate vectors
- [`shorten_condition()`](https://beerda.github.io/nuggets/reference/shorten_condition.md)
  : Shorten predicates within conditions
- [`values()`](https://beerda.github.io/nuggets/reference/values.md) :
  Extract values from predicate names
- [`var_grid()`](https://beerda.github.io/nuggets/reference/var_grid.md)
  : Create a tibble of combinations of selected column names
- [`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md)
  : Extract variable names from predicate names

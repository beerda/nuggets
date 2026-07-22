# Changelog

## nuggets 2.2.2

- released: 2026-07-22
- optimized [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
  on sparse crisp data (by implementing sparse bit chain)
- added clustering characteristics to
  [`explore()`](https://generics.r-lib.org/reference/explore.html) for
  association rules
- fixed handling of axioms in
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md) and
  `dig_*()` function (arg `excluded`)
- fixed handling of NA values in
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)

## nuggets 2.2.1

- released: 2026-06-10
- fixed failing unit tests because of upstream fixes in R’s
  [`wilcox.test()`](https://rdrr.io/r/stats/wilcox.test.html)
- enhanced placement of nodes in
  [`geom_diamond()`](https://beerda.github.io/nuggets/reference/geom_diamond.md)
  to reduce edge crossing
- added `.subsets` argument to
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
  that enables partitioning by subsets of factor levels

## nuggets 2.2.0

- released: 2026-03-11
- fixed bugs in
  [`explore()`](https://generics.r-lib.org/reference/explore.html)
- added special value highlighting in
  [`explore()`](https://generics.r-lib.org/reference/explore.html)’s
  table of rules
- added contingency table view to
  [`explore.associations()`](https://beerda.github.io/nuggets/reference/explore.associations.md)
- added [`explore()`](https://generics.r-lib.org/reference/explore.html)
  methods for baseline contrasts, complement contrasts, paired baseline
  contrasts, and correlations
- added
  [`dig_ancestors()`](https://beerda.github.io/nuggets/reference/dig_ancestors.md)
- added
  [`plot_contingency()`](https://beerda.github.io/nuggets/reference/plot_contingency.md)
- enhanced info and error messages
- added arguments for line type and colour to
  [`geom_diamond()`](https://beerda.github.io/nuggets/reference/geom_diamond.md)
- enhanced `dig_*_contrasts()` - statistical test errors are now stored
  in the `"comment"` column in the returned data frame

## nuggets 2.1.2

- released: 2026-02-04
- added
  [`is_logicalish()`](https://beerda.github.io/nuggets/reference/is_logicalish.md)
  to check if a vector is logical or can be coerced to logical
- fixed issue with required version of R (\>= 4.4.0)
- fixed critical bug in
  [`explore()`](https://generics.r-lib.org/reference/explore.html)

## nuggets 2.1.1

- released: 2026-02-03
- performance improvements
- updated XSIMD library to 14.0.0
- moved Shiny-related packages (shiny, shinyjs, shinyWidgets, DT,
  htmltools, htmlwidgets, jsonlite) from `Imports` to `Suggests`
- removed deprecated measures argument from
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
  and
  [`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
- deprecated argument `contingency_table` in
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
  and
  [`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
- removed dependency on BH and RcppThread

## nuggets 2.1.0

- released: 2025-11-05
- added
  [`cluster_associations()`](https://beerda.github.io/nuggets/reference/cluster_associations.md)
  to cluster association rules
- added
  [`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md)
  for associations flavour of nugget to compute additional interest
  measures (GUHA and arules measures)
- deprecated measures argument in
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
  and
  [`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
- [`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md)
  rewritten in C++ for better performance
- enhanced UI layout of
  [`explore()`](https://generics.r-lib.org/reference/explore.html) for
  associations
- added “Cluster” tab to
  [`explore()`](https://generics.r-lib.org/reference/explore.html) for
  associations
- added selection of columns to show in
  [`explore()`](https://generics.r-lib.org/reference/explore.html) for
  associations
- fixed rchk protection stack imbalance in `CombinatorialProgress`
  constructor

## nuggets 2.0.2

- released: 2025-10-31
- attempt to fix rchk protection stack imbalance in
  `CombinatorialProgress` constructor
- created vignette “Data Preparation”
- updated main vignette

## nuggets 2.0.1

- released: 2025-10-13
- fixed problem with C++20 and testthat by downgrading system
  requirements to C++17
- added
  [`association_matrix()`](https://beerda.github.io/nuggets/reference/association_matrix.md)

## nuggets 2.0.0

- released: 2025-10-13
- completely rewritten the core algorithm in
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
- all `dig_*()` functions now return nugget S3 objects
- added
  [`is_almost_constant()`](https://beerda.github.io/nuggets/reference/is_almost_constant.md),
  [`remove_almost_constant()`](https://beerda.github.io/nuggets/reference/remove_almost_constant.md),
  [`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md),
  [`fire()`](https://beerda.github.io/nuggets/reference/fire.md),
  [`is_condition()`](https://beerda.github.io/nuggets/reference/is_condition.md),
  [`remove_ill_conditions()`](https://beerda.github.io/nuggets/reference/remove_ill_conditions.md),
  [`shorten_condition()`](https://beerda.github.io/nuggets/reference/shorten_condition.md)
- added
  [`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
- added
  [`geom_diamond()`](https://beerda.github.io/nuggets/reference/geom_diamond.md)
- added `.span` and `.inc` arguments to
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
- added various styles (quantile, k-means, hclust, bclust, …) of crisp
  partitioning to
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
- added [`explore()`](https://generics.r-lib.org/reference/explore.html)
  function for interactive exploration of patterns
- added `exclude` argument to
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md) and other
  `dig_*()` functions
- added support for the disjoint parameter to
  [`var_grid()`](https://beerda.github.io/nuggets/reference/var_grid.md)
  and
  [`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
- added progress bar to the
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md) function
- added `"dummy"` method to
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)

## nuggets 1.4.0

- released: 2025-01-08
- added
  [`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md),
  [`dig_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_baseline_contrasts.md),
  [`dig_complement_contrasts()`](https://beerda.github.io/nuggets/reference/dig_complement_contrasts.md)
- `dig_contrasts()` renamed to
  [`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md)
- `dig_implications()` renamed to
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
- `dichotomize()` is deprecated (use
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
  instead)
- added `max_support` argument to
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
- added `max_results` argument to
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
- optimized performance of
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
- added `min_conditional_focus_support` argument to
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
- fixed handling of NULL returned by a callback function in
  [`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
- argument `d` of the callback function in
  [`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
  renamed to `pd`
- added handling of `nd` argument of the callback function in
  [`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
- added `max_p_value` argument to
  [`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md)
- improved error messages
- added nuggets vignette
- started using lifecycle and pkgdown

## nuggets 1.3.0

- released: 2024-11-13
- added
  [`is_degree()`](https://beerda.github.io/nuggets/reference/is_degree.md),
  `dig_contrasts()`,
  [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
- implemented fuzzy variant of
  [`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
- fixed crash when mixing logical (crisp) and numeric (fuzzy) inputs to
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)

## nuggets 1.2.0

- released: 2024-10-11
- added
  [`var_grid()`](https://beerda.github.io/nuggets/reference/var_grid.md),
  [`dig_grid()`](https://beerda.github.io/nuggets/reference/dig_grid.md)
- added the measures argument to `dig_implications()`
- fixed contingency table arguments computation (pp, pn, np, nn) -
  previously, they were computed as relative frequencies, now they are
  computed as counts
- fixed new-delete-type-mismatch ASAN error caused by wrong
  implementation of `AlignedAllocator`
- fixed memory leaks

## nuggets 1.1.0

- released: 2024-10-08
- added `.other` argument to `dichotomize()`
- fixed handling of `xvars`, `yvars` tidy-selectors in
  [`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md))
- added filtering of foci by their support
- added handling of callback function arguments related to contingency
  tables (pp, pn, np, nn arguments)

## nuggets 1.0.2

- released: 2024-01-09
- fixed handling of arguments `min_coverage` and `min_support` in
  `dig_implications()`
- attempt to fix LTO error related to `run_testthat_tests()` - fixed by
  using an RC version of Rcpp (1.0.11.6)

## nuggets 1.0.1

- released: 2023-11-29
- attempt to fix tests failing on R-devel

## nuggets 1.0.0

- released: 2023-11-28
- first version of the package
- implemented: `dichotomize()`,
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md),
  `dig_implications()`,
  [`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md),
  [`which_antichain()`](https://beerda.github.io/nuggets/reference/which_antichain.md),
  [`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md),
  [`is_subset()`](https://beerda.github.io/nuggets/reference/is_subset.md)

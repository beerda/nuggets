# nuggets 2.1.2
- released: 2026-02-04
- added is_logicalish()
- fixed issue with required version of R (>= 4.4.0)
- fixed critical bug in explore()

# nuggets 2.1.1
- released: 2026-02-03
- performance improvements
- updated XSIMD library to 14.0.0
- moved Shiny-related packages (shiny, shinyjs, shinyWidgets, DT, htmltools,
  htmlwidgets, jsonlite) from Imports to Suggests
- removed deprecated measures argument from dig_associations() and
  dig_tautologies()
- deprecated argument contingency_table in dig_associations() and
  dig_tautologies()
- removed dependency on BH and RcppThread

# nuggets 2.1.0
- released: 2025-11-05
- added cluster_associations()
- added add_interest() for associations flavour of nugget to compute
  additional interest measures (GUHA and arules measures)
- deprecated measures argument in dig_associations() and dig_tautologies()
- parse_condition() rewritten in C++ for better performance
- enhanced UI layout of explore() for associations
- added "Cluster" tab to explore() for associations
- added selection of columns to show in explore() for associations
- fixed rchk protection stack imbalance in CombinatorialProgress constructor

# nuggets 2.0.2
- released: 2025-10-31
- attempt to fix rchk protection stack imbalance in CombinatorialProgress constructor
- created vignette "Data Preparation"
- updated main vignette

# nuggets 2.0.1
- released: 2025-10-13
- fixed problem with C++20 and testthat by downgrading system requirements
  to C++17
- added association_matrix()

# nuggets 2.0.0
- released: 2025-10-13
- completely rewritten the core algorithm in dig()
- all dig_*() functions now return nugget S3 objects
- added is_almost_constant(), remove_almost_constant(), parse_condition(),
  fire(), is_condition(), remove_ill_conditions(), shorten_condition()
- added dig_tautologies()
- added geom_diamond()
- added .span and .inc arguments to partition()
- added various styles (quantile, k-means, hclust, bclust, ...) of crisp
  partitioning to partition()
- added explore() function for interactive exploration of patterns
- added exclude argument to dig() and other dig_*() functions
- added support for the disjoint parameter to var_grid() and dig_grid()
- added progress bar to the dig() function
- added "dummy" method to partition()

# nuggets 1.4.0
- released: 2025-01-08
- added var_names(), dig_baseline_contrasts(), dig_complement_contrasts()
- dig_contrasts() renamed to dig_paired_baseline_contrasts()
- dig_implications() renamed to dig_associations()
- dichotomize() is deprecated (use partition() instead)
- added max_support argument to dig()
- added max_results argument to dig()
- optimized performance of dig()
- added min_conditional_focus_support argument to dig()
- fixed handling of NULL returned by a callback function in dig_grid()
- argument d of the callback function in dig_grid() renamed to pd
- added handling of nd argument of the callback function in dig_grid()
- added max_p_value argument to dig_paired_baseline_contrasts()
- improved error messages
- added nuggets vignette
- started using lifecycle and pkgdown

# nuggets 1.3.0
- released: 2024-11-13
- added is_degree(), dig_contrasts(), partition()
- implemented fuzzy variant of dig_grid()
- fixed crash when mixing logical (crisp) and numeric (fuzzy) inputs to dig()

# nuggets 1.2.0
- released: 2024-10-11
- added var_grid(), dig_grid()
- added the measures argument to dig_implications()
- fixed contingency table arguments computation (pp, pn, np, nn) - previously,
  they were computed as relative frequencies, now they are computed as counts
- fixed new-delete-type-mismatch ASAN error caused by wrong implementation of
  AlignedAllocator
- fixed memory leaks

# nuggets 1.1.0
- released: 2024-10-08
- added .other argument to dichotomize()
- fixed handling of xvars, yvars tidy-selectors in dig_correlations()
- added filtering of foci by their support
- added handling of callback function arguments related to contingency tables
  (pp, pn, np, nn arguments)

# nuggets 1.0.2
- released: 2024-01-09
- fixed handling of arguments min_coverage and min_support in dig_implications()
- attempt to fix LTO error related to run_testthat_tests() - fixed by using
  an RC version of Rcpp (1.0.11.6)

# nuggets 1.0.1
- released: 2023-11-29
- attempt to fix tests failing on R-devel

# nuggets 1.0.0
- released: 2023-11-28
- first version of the package
- implemented: dichotomize(), dig(), dig_implications(), dig_correlations(),
  which_antichain(), format_condition(), is_subset()

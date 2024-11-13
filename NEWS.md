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
- released: 2024-10-07
- added .other argument to dichotomize()
- fixed handling of xvars, yvars tidy-selectors in dig_correlations()
- added filtering of foci by their support
- added handling of callback function arguments related to contingency tables
  (pp, pn, np, nn arguments)

# nuggets 1.0.2
- released: 2024-01-08
- fixed handling of arguments min_coverage and min_support in dig_implications()
- attempt to fix LTO error related to run_testhat_tests() - fixed by using
  an RC version of Rcpp (1.0.11.6)

# nuggets 1.0.1
- released: 2023-11-29
- attempt to fix tests failing on R-devel

# nuggets 1.0.0
- released: 2023-11-28
- first version of the package
- implemented: dichotomize(), dig(), dig_implications(), dig_correlations(),
  which_antichain(), format_condition(), is_subset()

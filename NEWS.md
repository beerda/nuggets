# nuggets ???
- released: ???
- added .other argument to dichotomize()
- fixed handling of xvars, yvars tidy-selectors in dig_correlations()
- added the handling of callback function arguments related to contingency tables
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

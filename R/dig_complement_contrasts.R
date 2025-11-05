#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


#' Search for conditions that provide significant differences in selected
#' variables to the rest of the data table
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Complement contrast patterns identify conditions under which there is
#' a significant difference in some numerical variable between elements
#' that satisfy the identified condition and the rest of the data table.
#'
#' \describe{
#'   \item{Scheme:}{`(var | C) != (var | not C)`\cr\cr
#'     There is a statistically significant difference in variable `var` between
#'     group of elements that satisfy condition `C` and a group of elements that
#'     do not satisfy condition `C`.}
#'   \item{Example:}{`(life_expectancy | smoker) < (life_expectancy | non-smoker)`\cr\cr
#'     The life expectancy in people that smoke cigarettes is in average
#'     significantly lower than in people that do not smoke.}
#' }
#'
#' The complement contrast is computed using a two-sample statistical test,
#' which is specified by the `method` argument. The function computes the
#' complement contrast in all variables specified by the `vars` argument.
#' Complement contrasts are computed based on sub-data corresponding
#' to conditions generated from the `condition` columns and the rest of the
#' data table. Function #' `dig_complement_contrasts()` supports crisp
#' conditions only, i.e., the condition columns in `x` must be logical.
#'
#' @param x a matrix or data frame with data to search the patterns in.
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates
#' @param vars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use for computation of contrasts
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [var_names()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
#' @param excluded NULL or a list of character vectors, where each character vector
#'      contains the names of columns that must not appear together in a single
#'      condition.
#' @param min_length the minimum size (the minimum number of predicates) of the
#'      condition to be generated (must be greater or equal to 0). If 0, the
#'      empty condition is generated in the first place.
#' @param max_length The maximum size (the maximum number of predicates) of the
#'      condition to be generated. If equal to Inf, the maximum length of
#'      conditions is limited only by the number of available predicates.
#' @param min_support the minimum support of a condition to trigger the callback
#'      function for it. The support of the condition is the relative frequency
#'      of the condition in the dataset `x`. For logical data, it equals to the
#'      relative frequency of rows such that all condition predicates are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values.
#' @param max_support the maximum support of a condition to trigger the callback
#'      function for it. See argument `min_support` for details of what is the
#'      support of a condition.
#' @param method a character string indicating which contrast to compute.
#'      One of `"t"`, for parametric, or `"wilcox"`, for non-parametric test on
#'      equality in position, and `"var"` for F-test on comparison of variances
#'      of two populations.
#' @param alternative indicates the alternative hypothesis and must be one of
#'      `"two.sided"`, `"greater"` or `"less"`. `"greater"` corresponds to
#'      positive association, `"less"` to negative association.
#' @param h0 a numeric value specifying the null hypothesis for the test. For
#'      the `"t"` method, it is the difference in means. For the `"wilcox"` method,
#'      it is the difference in medians. For the `"var"` method, it is the
#'      hypothesized ratio of the population variances. The default value is 1
#'      for `"var"` method, and 0 otherwise.
#' @param conf_level a numeric value specifying the level of the confidence
#'      interval. The default value is 0.95.
#' @param max_p_value the maximum p-value of a test for the pattern to be considered
#'      significant. If the p-value of the test is greater than `max_p_value`, the
#'      pattern is not included in the result.
#' @param t_var_equal (used for the `"t"` method only) a logical value indicating
#'      whether the variances of the two samples are assumed to be equal. If
#'      `TRUE`, the pooled variance is used to estimate the variance in the t-test.
#'      If `FALSE`, the Welch (or Satterthwaite) approximation to the degrees of
#'      freedom is used. See [t.test()] and its `var.equal` argument for more
#'      information.
#' @param wilcox_exact (used for the `"wilcox"` method only) a logical value
#'      indicating whether the exact p-value should be computed. If `NULL`, the
#'      exact p-value is computed for sample sizes less than 50. See [wilcox.test()]
#'      and its `exact` argument for more information. Contrary to the behavior
#'      of [wilcox.test()], the default value is `FALSE`.
#' @param wilcox_correct (used for the `"wilcox"` method only) a logical value
#'      indicating whether the continuity correction should be applied in the
#'      normal approximation for the p-value, if `wilcox_exact` is `FALSE`. See
#'      [wilcox.test()] and its `correct` argument for more information.
#' @param wilcox_tol_root (used for the `"wilcox"` method only) a numeric value
#'      specifying the tolerance for the root-finding algorithm used to compute
#'      the exact p-value. See [wilcox.test()] and its `tol.root` argument for
#'      more information.
#' @param wilcox_digits_rank (used for the `"wilcox"` method only) a numeric value
#'      specifying the number of digits to round the ranks to. See [wilcox.test()]
#'      and its `digits.rank` argument for more information.
#' @param max_results the maximum number of generated conditions to execute the
#'      callback function on. If the number of found conditions exceeds
#'      `max_results`, the function stops generating new conditions and returns
#'      the results. To avoid long computations during the search, it is recommended
#'      to set `max_results` to a reasonable positive value. Setting `max_results`
#'      to `Inf` will generate all possible conditions.
#' @param verbose a logical scalar indicating whether to print progress messages.
#' @param threads the number of threads to use for parallel computation.
#' @return An S3 object which is an instance of `complement_contrasts` and `nugget`
#'      classes and which is a tibble with found patterns in rows. The following
#'      columns are always present:
#'      \item{condition}{the condition of the pattern as a character string
#'        in the form `{p1 & p2 & ... & pn}` where `p1`, `p2`, ..., `pn` are
#'        `x`'s column names.}
#'      \item{support}{the support of the condition, i.e., the relative
#'        frequency of the condition in the dataset `x`.}
#'      \item{var}{the name of the contrast variable.}
#'      \item{estimate}{the estimate value (see the underlying test.}
#'      \item{statistic}{the statistic of the selected test.}
#'      \item{p_value}{the p-value of the underlying test.}
#'      \item{n_x}{the number of rows in the sub-data corresponding to
#'        the condition.}
#'      \item{n_y}{the number of rows in the sub-data corresponding to
#'        the negation of the condition.}
#'      \item{conf_int_lo}{the lower bound of the confidence interval of the estimate.}
#'      \item{conf_int_hi}{the upper bound of the confidence interval of the estimate.}
#'      \item{alternative}{a character string indicating the alternative
#'        hypothesis. The value must be one of `"two.sided"`, `"greater"`, or
#'        `"less"`.}
#'      \item{method}{a character string indicating the method used for the
#'        test.}
#'      \item{comment}{a character string with additional information about the
#'        test (mainly error messages on failure).}
#'      For the `"t"` method, the following additional columns are also
#'      present (see also [t.test()]):
#'      \item{df}{the degrees of freedom of the t test.}
#'      \item{stderr}{the standard error of the mean difference.}
#' @author Michal Burda
#' @seealso [dig_baseline_contrasts()], [dig_paired_baseline_contrasts()],
#'      [dig()], [dig_grid()],
#'      [stats::t.test()], [stats::wilcox.test()], [stats::var.test()]
#' @export
dig_complement_contrasts <- function(x,
                                     condition = where(is.logical),
                                     vars = where(is.numeric),
                                     disjoint = var_names(colnames(x)),
                                     excluded = NULL,
                                     min_length = 0L,
                                     max_length = Inf,
                                     min_support = 0.0,
                                     max_support = 1.0 - min_support,
                                     method = "t",
                                     alternative = "two.sided",
                                     h0 = if (method == "var") 1 else 0,
                                     conf_level = 0.95,
                                     max_p_value = 0.05,
                                     t_var_equal = FALSE,
                                     wilcox_exact = FALSE,
                                     wilcox_correct = TRUE,
                                     wilcox_tol_root = 1e-4,
                                     wilcox_digits_rank = Inf,
                                     max_results = Inf,
                                     verbose = FALSE,
                                     threads = 1L) {
    .must_be_enum(method, c("t", "wilcox", "var"))
    .must_be_enum(alternative, c("two.sided", "less", "greater"))
    .must_be_double_scalar(h0)
    .must_be_double_scalar(conf_level)
    .must_be_in_range(conf_level, c(0, 1))
    .must_be_double_scalar(max_p_value)
    .must_be_in_range(max_p_value, c(0, 1))
    .must_be_flag(t_var_equal)
    .must_be_flag(wilcox_exact, null = TRUE)
    .must_be_flag(wilcox_correct)
    .must_be_double_scalar(wilcox_tol_root)
    .must_be_double_scalar(wilcox_digits_rank)

    condition <- enquo(condition)
    vars <- enquo(vars)

    if (method == "t") {
        f <- function(pd, nd) {
            .t_test(x = pd[[1]],
                    y = nd[[1]],
                    alternative = alternative,
                    mu = h0,
                    paired = FALSE,
                    var_equal = t_var_equal,
                    conf_level = conf_level,
                    max_p_value = max_p_value)
        }

    } else if (method == "wilcox") {
        f <- function(pd, nd) {
            .wilcox_test(x = pd[[1]],
                         y = nd[[1]],
                         alternative = alternative,
                         mu = h0,
                         paired = FALSE,
                         exact = wilcox_exact,
                         correct = wilcox_correct,
                         conf_level = conf_level,
                         tol_root = wilcox_tol_root,
                         digits_rank = wilcox_digits_rank,
                         max_p_value = max_p_value)
        }

    } else if (method == "var") {
        f <- function(pd, nd) {
            .var_test(x = pd[[1]],
                      y = nd[[1]],
                      alternative = alternative,
                      ratio = h0,
                      conf_level = conf_level,
                      max_p_value = max_p_value)
        }

    } else {
        stop("Internal error - unknown method: ", method)
    }

    res <- dig_grid(x = x,
                    f = f,
                    condition = !!condition,
                    xvars = !!vars,
                    yvars = NULL,
                    disjoint = disjoint,
                    excluded = excluded,
                    allow = "numeric",
                    na_rm = TRUE,
                    type = "crisp",
                    min_length = min_length,
                    max_length = max_length,
                    min_support = min_support,
                    max_support = max_support,
                    max_results = max_results,
                    verbose = verbose,
                    threads = threads,
                    error_context = list(arg_x = "x",
                                         arg_condition = "condition",
                                         arg_xvars = "vars",
                                         arg_yvars = "yvars",
                                         arg_disjoint = "disjoint",
                                         arg_excluded = "excluded",
                                         arg_min_length = "min_length",
                                         arg_max_length = "max_length",
                                         arg_min_support = "min_support",
                                         arg_max_support = "max_support",
                                         arg_max_results = "max_results",
                                         arg_verbose = "verbose",
                                         arg_threads = "threads",
                                         call = current_env()))
    digattr <- attributes(res)

    nugget(res,
           flavour = "complement_contrasts",
           call_function = "dig_complement_contrasts",
           call_data = list(nrow = nrow(x),
                            ncol = ncol(x),
                            colnames = as.character(colnames(x))),
           call_args = list(x = deparse(substitute(x)),
                            condition = digattr$call_args$condition,
                            vars = digattr$call_args$xvars,
                            disjoint = digattr$call_args$disjoint,
                            excluded = digattr$call_args$excluded,
                            min_length = digattr$call_args$min_length,
                            max_length = digattr$call_args$max_length,
                            min_support = digattr$call_args$min_support,
                            max_support = digattr$call_args$max_support,
                            method = method,
                            alternative = alternative,
                            h0 = h0,
                            conf_level = conf_level,
                            max_p_value = max_p_value,
                            t_var_equal = t_var_equal,
                            wilcox_exact = wilcox_exact,
                            wilcox_correct = wilcox_correct,
                            wilcox_tol_root = wilcox_tol_root,
                            wilcox_digits_rank = wilcox_digits_rank,
                            max_results = digattr$call_args$max_results,
                            verbose = digattr$call_args$verbose,
                            threads = digattr$call_args$threads))
}

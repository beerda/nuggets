#' Search for conditions that provide significant differences between paired
#' variables
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Paired baseline contrast patterns identify conditions under which there is
#' a significant difference in some statistical feature between two paired
#' numeric variables.
#'
#' \describe{
#'   \item{Scheme:}{`(xvar - yvar) != 0 | C`\cr\cr
#'     There is a statistically significant difference between paired variables
#'     `xvar` and `yvar` under the condition `C`.}
#'   \item{Example:}{`(daily_ice_cream_income - daily_tea_income) > 0 | sunny`\cr\cr
#'     Under the condition of *sunny weather*, the paired test shows that
#'     *daily ice-cream income* is significantly higher than the
#'     *daily tea income*.}
#' }
#'
#' The paired baseline contrast  is computed using a paired version of a statistical test,
#' which is specified by the `method` argument. The function computes the paired
#' contrast between all pairs of variables, where the first variable is
#' specified by the `xvars` argument and the second variable is specified by the
#' `yvars` argument. Paired baseline contrasts are computed in sub-data corresponding
#' to conditions generated from the `condition` columns. Function
#' `dig_paired_baseline_contrasts()` supports crisp conditions only, i.e.,
#' the condition columns in `x` must be logical.
#'
#' @param x a matrix or data frame with data to search the patterns in.
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates
#' @param xvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use for computation of contrasts
#' @param yvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use for computation of contrasts
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [var_names()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
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
#'      equality in position.
#' @param alternative indicates the alternative hypothesis and must be one of
#'      `"two.sided"`, `"greater"` or `"less"`. `"greater"` corresponds to
#'      positive association, `"less"` to negative association.
#' @param h0 a numeric value specifying the null hypothesis for the test. For
#'      the `"t"` method, it is the difference in means. For the `"wilcox"` method,
#'      it is the difference in medians. The default value is 0.
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
#' @param threads the number of threads to use for parallel computation.
#' @return A tibble with found patterns in rows. The following columns are always
#'      present:
#'      \item{condition}{the condition of the pattern as a character string
#'        in the form `{p1 & p2 & ... & pn}` where `p1`, `p2`, ..., `pn` are
#'        `x`'s column names.}
#'      \item{support}{the support of the condition, i.e., the relative
#'        frequency of the condition in the dataset `x`.}
#'      \item{xvar}{the name of the first variable in the contrast.}
#'      \item{yvar}{the name of the second variable in the contrast.}
#'      \item{estimate}{the estimated difference of variable `var`.}
#'      \item{statistic}{the statistic of the selected test.}
#'      \item{p_value}{the p-value of the underlying test.}
#'      \item{n}{the number of rows in the sub-data corresponding to
#'        the condition.}
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
#' @seealso [dig_baseline_contrasts()], [dig_complement_contrasts()],
#'      [dig()], [dig_grid()],
#'      [stats::t.test()], [stats::wilcox.test()]
#' @examples
#' # Compute ratio of sepal and petal length and width for iris dataset
#' crispIris <- iris
#' crispIris$Sepal.Ratio <- iris$Sepal.Length / iris$Sepal.Width
#' crispIris$Petal.Ratio <- iris$Petal.Length / iris$Petal.Width
#'
#' # Create predicates from the Species column
#' crispIris <- partition(crispIris, Species)
#'
#' # Compute paired contrasts for ratios of sepal and petal length and width
#' dig_paired_baseline_contrasts(crispIris,
#'                               condition = where(is.logical),
#'                               xvars = Sepal.Ratio,
#'                               yvars = Petal.Ratio,
#'                               method = "t",
#'                               min_support = 0.1)
#' @export
dig_paired_baseline_contrasts <- function(x,
                                          condition = where(is.logical),
                                          xvars = where(is.numeric),
                                          yvars = where(is.numeric),
                                          disjoint = var_names(colnames(x)),
                                          min_length = 0L,
                                          max_length = Inf,
                                          min_support = 0.0,
                                          max_support = 1.0,
                                          method = "t",
                                          alternative = "two.sided",
                                          h0 = 0,
                                          conf_level = 0.95,
                                          max_p_value = 1,
                                          t_var_equal = FALSE,
                                          wilcox_exact = FALSE,
                                          wilcox_correct = TRUE,
                                          wilcox_tol_root = 1e-4,
                                          wilcox_digits_rank = Inf,
                                          threads = 1) {
    .must_be_enum(method, c("t", "wilcox"))
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
    xvars <- enquo(xvars)
    yvars <- enquo(yvars)

    if (method == "t") {
        f <- function(pd) {
            .t_test(x = pd[[1]],
                    y = pd[[2]],
                    alternative = alternative,
                    mu = h0,
                    paired = TRUE,
                    var_equal = t_var_equal,
                    conf_level = conf_level,
                    max_p_value = max_p_value)
        }

    } else if (method == "wilcox") {
        f <- function(pd) {
            .wilcox_test(x = pd[[1]],
                         y = pd[[2]],
                         alternative = alternative,
                         mu = h0,
                         paired = TRUE,
                         exact = wilcox_exact,
                         correct = wilcox_correct,
                         conf_level = conf_level,
                         tol_root = wilcox_tol_root,
                         digits_rank = wilcox_digits_rank,
                         max_p_value = max_p_value)
        }

    } else {
        stop("Internal error - unknown method: ", method)
    }

    dig_grid(x = x,
             f = f,
             condition = !!condition,
             xvars = !!xvars,
             yvars = !!yvars,
             disjoint = disjoint,
             allow = "numeric",
             na_rm = TRUE,
             type = "crisp",
             min_length = min_length,
             max_length = max_length,
             min_support = min_support,
             max_support = max_support,
             threads = threads,
             error_context = list(arg_x = "x",
                                  arg_condition = "condition",
                                  arg_xvars = "xvars",
                                  arg_yvars = "yvars",
                                  arg_min_length = "min_length",
                                  arg_max_length = "max_length",
                                  arg_min_support = "min_support",
                                  arg_max_support = "max_support",
                                  arg_threads = "threads",
                                  call = current_env()))
}

#' Search for paired contrast patterns
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Contrast patterns are a generalization of association rules that allow
#' for the specification of a condition under which there is a significant
#' difference in some statistical feature between two numeric variables.
#'
#' \describe{
#'   \item{Scheme:}{`theta(xvar) >> theta(yvar) | C`\cr\cr
#'     The feature `theta` of the first variable `xvar` is significantly higher
#'     than the feature `theta` of the second variable `yvar` under the
#'     condition `C`.}
#'   \item{Example:}{`mean(daily_ice_cream_income) >> mean(daily_tea_income) | sunny`\cr\cr
#'     The *mean* of *daily ice-cream income* is significantly higher than
#'     the *mean* of *daily tea income* under the condition of *sunny weather*.}
#' }
#'
#' The contrast is computed using
#' a statistical test, which is specified by the `method` argument. The
#' function computes the contrast between all pairs of variables, where the
#' first variable is specified by the `xvars` argument and the second variable
#' is specified by the `yvars` argument. The contrast is computed in sub-data
#' corresponding to conditions generated from the `condition` columns. The
#' `dig_contrasts()` function supports crisp conditions only, i.e., the
#' condition columns must be logical.
#'
#' @param x a matrix or data frame with data to search in.
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates
#' @param xvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use for computation of contrasts
#' @param yvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use for computation of contrasts
#' @param method a character string indicating which contrast to compute.
#'      One of `"t"`, `"wilcox"`, or `"var"`. `"t"` (resp. `"wilcos"`) compute
#'      a parametric (resp. non-parametric) test on equality in position, and
#'      `"var"` performs the F-test on equality of variance.
#' @param alternative indicates the alternative hypothesis and must be one of
#'      `"two.sided"`, `"greater"` or `"less"`. `"greater"` corresponds to
#'      positive association, `"less"` to negative association.
#' @param min_length the minimum size (the minimum number of predicates) of the
#'      condition to be generated (must be greater or equal to 0). If 0, the empty
#'      condition is generated in the first place.
#' @param max_length The maximum size (the maximum number of predicates) of the
#'      condition to be generated. If equal to Inf, the maximum length of conditions
#'      is limited only by the number of available predicates.
#' @param min_support the minimum support of a condition to trigger the callback
#'      function for it. The support of the condition is the relative frequency
#'      of the condition in the dataset `x`. For logical data, it equals to the
#'      relative frequency of rows such that all condition predicates are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values.
#' @param max_p_value the maximum p-value of a test for the pattern to be considered
#'     significant. If the p-value of the test is greater than `max_p_value`, the
#'     pattern is not included in the result.
#' @param threads the number of threads to use for parallel computation.
#' @param ... Further arguments passed to the underlying test function
#'      ([t.test()], [wilcox.test()], or [var.test()] accordingly to the
#'      selected method).
#' @return A tibble with found patterns in rows. The following columns are always
#'      present:
#'      \item{condition}{the condition of the pattern as a character string
#'        in the form `{p1 & p2 & ... & pn}` where `p1`, `p2`, ..., `pn` are
#'        `x`'s column names.}
#'      \item{support}{the support of the condition, i.e., the relative
#'        frequency of the condition in the dataset `x`.}
#'      \item{xvar}{the name of the first variable in the contrast.}
#'      \item{yvar}{the name of the second variable in the contrast.}
#'      \item{p_value}{the p-value of the underlying test.}
#'      \item{rows}{the number of rows in the sub-data corresponding to
#'        the condition.}
#'      \item{alternative}{a character string indicating the alternative
#'        hypothesis.}
#'      \item{method}{a character string indicating the method used for the
#'        test.}
#'      For the `"t"` method, the following additional columns are also
#'      present (see also [t.test()]):
#'      \item{estimate_x}{the estimated mean of variable `xvar`.}
#'      \item{estimate_y}{the estimated mean of variable `yvar`.}
#'      \item{t_statistic}{the t-statistic of the t test.}
#'      \item{df}{the degrees of freedom of the t test.}
#'      \item{conf_int_lo}{the lower bound of the confidence interval.}
#'      \item{conf_int_hi}{the upper bound of the confidence interval.}
#'      \item{stderr}{the standard error of the mean difference.}
#'      For the `"wilcox"` method, the following additional columns are also
#'      present (see also [wilcox.test()]):
#'      \item{estimate}{the estimate of the location parameter.}
#'      \item{W_statistic}{the Wilcoxon rank sum statistic.}
#'      \item{conf_int_lo}{the lower bound of the confidence interval.}
#'      \item{conf_int_hi}{the upper bound of the confidence interval.}
#'      For the `"var"` method, the following additional columns are also
#'      present (see also [var.test()]):
#'      \item{estimate}{the ratio of the sample variances of variables
#'        `xvar` and `yvar`.}
#'      \item{F_statistic}{the value of the F test statistic.}
#'      \item{df1}{the numerator degrees of freedom.}
#'      \item{df2}{the denominator degrees of freedom.}
#'      \item{conf_int_lo}{the lower bound of the confidence interval for the
#'        ratio of the population variances.}
#'      \item{conf_int_hi}{the upper bound of the confidence interval for the
#'        ratio of the population variances.}
#' @author Michal Burda
#' @seealso [dig()], [dig_grid()], [stats::t.test()], [stats::wilcox.test()], [stats::var.test()]
#' @keywords internal
#' @export
dig_contrasts <- function(x,
                         condition = where(is.logical),
                         xvars = where(is.numeric),
                         yvars = where(is.numeric),
                         method = "t",
                         alternative = "two.sided",
                         min_length = 0L,
                         max_length = Inf,
                         min_support = 0.0,
                         max_p_value = 0.05,
                         threads = 1,
                         ...) {
    lifecycle::deprecate_stop("1.4.0", "dig_contrasts()", with = "dig_paired_baseline_contrasts()")
}

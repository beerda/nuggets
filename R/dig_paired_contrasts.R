#' Search for paired contrast patterns
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Contrast patterns identify conditions under which there is a significant
#' difference in some statistical feature between two paired numeric variables.
#'
#' \describe{
#'   \item{Scheme:}{`xvar >> yvar | C`\cr\cr
#'     There is a statistically significant difference between variables `xvar`
#'     and `yvar` under the condition `C`.}
#'   \item{Example:}{`daily_ice_cream_income >> daily_tea_income | sunny`\cr\cr
#'     Under the condition of *sunny weather*, the paired test shows that
#'     *daily ice-cream income* is significantly higher than the
#'     *daily tea income*.}
#' }
#'
#' The paired contrast is computed using a paired version of a statistical test,
#' which is specified by the `method` argument. The function computes the paired
#' contrast between all pairs of variables, where the first variable is
#' specified by the `xvars` argument and the second variable is specified by the
#' `yvars` argument. Paired contrasts are computed in sub-data corresponding
#' to conditions generated from `condition` columns. Function
#' `dig_paired_contrasts()` supports crisp conditions only, i.e., the condition
#' columns must be logical.
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
#'      [partition()], using the [varnames()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
#' @param method a character string indicating which contrast to compute.
#'      One of `"t"`, `"wilcox"`, or `"var"`. `"t"` (resp. `"wilcos"`) compute
#'      a parametric (resp. non-parametric) test on equality in position, and
#'      `"var"` performs the F-test on equality of variance.
#' @param alternative indicates the alternative hypothesis and must be one of
#'      `"two.sided"`, `"greater"` or `"less"`. `"greater"` corresponds to
#'      positive association, `"less"` to negative association.
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
#'        hypothesis. The value must be one of `"two.sided"`, `"greater"`, or
#'        `"less"`.}
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
#' @seealso [dig()], [dig_grid()], [stats::t.test()], [stats::wilcox.test()],
#'      [stats::var.test()]
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
#' dig_paired_contrasts(crispIris,
#'                      condition = where(is.logical),
#'                      xvars = Sepal.Ratio,
#'                      yvars = Petal.Ratio,
#'                      method = "t",
#'                      min_support = 0.1)
#' @export
dig_paired_contrasts <- function(x,
                                 condition = where(is.logical),
                                 xvars = where(is.numeric),
                                 yvars = where(is.numeric),
                                 disjoint = varnames(colnames(x)),
                                 method = "t",
                                 alternative = "two.sided",
                                 min_length = 0L,
                                 max_length = Inf,
                                 min_support = 0.0,
                                 max_p_value = 0.05,
                                 threads = 1,
                                 ...) {
    .must_be_enum(method, c("t", "wilcox", "var"))
    .must_be_enum(alternative, c("two.sided", "less", "greater"))

    condition <- enquo(condition)
    xvars <- enquo(xvars)
    yvars <- enquo(yvars)

    f <- list()
    f[["t"]] <- function(d) {
        fit <- try(t.test(d[[1]],
                          d[[2]],
                          alternative = alternative,
                          paired = TRUE,
                          ...),
                   silent = TRUE)
        if (inherits(fit, "try-error")) {
            return(list(estimate_x = NA,
                        estimate_y = NA,
                        t_statistic = NA,
                        df = NA,
                        p_value = NA,
                        rows = nrow(d),
                        conf_int_lo = NA,
                        conf_int_hi = NA,
                        stderr = NA,
                        alternative = NA,
                        method = "error"))
        } else if (fit$p.value > max_p_value) {
            return(NULL)
        } else {
            return(list(estimate_x = fit$estimate[1],
                        estimate_y = fit$estimate[2],
                        t_statistic = fit$statistic,
                        df = fit$parameter,
                        p_value = fit$p.value,
                        rows = nrow(d),
                        conf_int_lo = fit$conf.int[1],
                        conf_int_hi = fit$conf.int[2],
                        stderr = fit$stderr,
                        alternative = fit$alternative,
                        method = fit$method))
        }
    }
    f[["wilcox"]] <- function(d) {
        fit <- try(wilcox.test(d[[1]],
                               d[[2]],
                               alternative = alternative,
                               paired = TRUE,
                               conf.int = TRUE,
                               exact = FALSE,
                               ...),
                   silent = TRUE)
        if (inherits(fit, "try-error")) {
            return(list(estimate = NA,
                        W_statistic = NA,
                        p_value = NA,
                        rows = nrow(d),
                        conf_int_lo = NA,
                        conf_int_hi = NA,
                        alternative = NA,
                        method = "error"))
        } else if (fit$p.value > max_p_value) {
            return(NULL)
        } else {
            return(list(estimate = fit$estimate[1],
                        W_statistic = fit$statistic,
                        p_value = fit$p.value,
                        rows = nrow(d),
                        conf_int_lo = fit$conf.int[1],
                        conf_int_hi = fit$conf.int[2],
                        alternative = fit$alternative,
                        method = fit$method))
        }
    }
    f[["var"]] <- function(d) {
        fit <- try(var.test(d[[1]],
                            d[[2]],
                            alternative = alternative,
                            ...),
                   silent = TRUE)
        if (inherits(fit, "try-error")) {
            return(list(estimate = NA,
                        W_statistic = NA,
                        p_value = NA,
                        rows = nrow(d),
                        conf_int_lo = NA,
                        conf_int_hi = NA,
                        alternative = NA,
                        method = "error"))
        } else if (fit$p.value > max_p_value) {
            return(NULL)
        } else {
            return(list(estimate = fit$estimate[1],
                        F_statistic = fit$statistic,
                        df1 = fit$parameter[1],
                        df2 = fit$parameter[2],
                        p_value = fit$p.value,
                        rows = nrow(d),
                        conf_int_lo = fit$conf.int[1],
                        conf_int_hi = fit$conf.int[2],
                        alternative = fit$alternative,
                        method = fit$method))
        }
    }

    dig_grid(x = x,
             f = f[[method]],
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
             threads = threads,
             error_context = list(arg_x = "x",
                                  arg_condition = "condition",
                                  arg_xvars = "xvars",
                                  arg_yvars = "yvars",
                                  arg_min_length = "min_length",
                                  arg_max_length = "max_length",
                                  arg_min_support = "min_support",
                                  arg_threads = "threads",
                                  call = current_env()),
             ...)
}

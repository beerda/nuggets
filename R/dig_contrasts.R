#' Search for contrast patterns
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
#' @param threads the number of threads to use for parallel computation.
#' @param ... Further arguments passed to the underlying test function
#'      ([t.test()], [wilcox.test()], or [var.test()] accordingly to the
#'      selected method).
#' @return A tibble with found rules.
#' @author Michal Burda
#' @seealso [dig()], [dig_grid()], [stats::t.test()], [stats::wilcox.test()], [stats::var.test()]
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
                               conf.int = TRUE,
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
             na_rm = TRUE,
             method = "bool",
             min_length = min_length,
             max_length = max_length,
             min_support = min_support,
             threads = threads,
             ...)
}

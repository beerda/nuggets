#' Search for conditional correlations
#'
#' Compute correlation between all combinations of `xvars` and `yvars` columns
#' of `x` in subdata corresponding to conditions generated from `condition`
#' columns.
#'
#' @param x a matrix or data frame with data to search in.
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates
#' @param xvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use for computation of correlations
#' @param yvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use for computation of correlations
#' @param method a character string indicating which correlation coefficient is
#'      to be used for the test. One of `"pearson"`, `"kendall"`, or `"spearman"`
#' @param alternative indicates the alternative hypothesis and must be one of
#'      `"two.sided"`, `"greater"` or `"less"`. `"greater"` corresponds to
#'      positive association, `"less"` to negative association.
#' @param exact a logical indicating whether an exact p-value should be computed.
#'      Used for Kendall's *tau* and Spearman's *rho*. See [stats::cor.test()] for
#'      more information.
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
#' @param ... Further arguments, currently unused.
#' @return A tibble with found rules.
#' @author Michal Burda
#' @seealso [dig()], [stats::cor.test()]
#' @export
dig_correlations <- function(x,
                             condition = where(is.logical),
                             xvars = where(is.numeric),
                             yvars = where(is.numeric),
                             method = "pearson",
                             alternative = "two.sided",
                             exact = NULL,
                             min_length = 0L,
                             max_length = Inf,
                             min_support = 0.0,
                             threads = 1,
                             ...) {
    .must_be_enum(method, c("pearson", "kendall", "spearman"))
    .must_be_enum(alternative, c("two.sided", "less", "greater"))

    condition <- enquo(condition)
    xvars <- enquo(xvars)
    yvars <- enquo(yvars)

    f <- function(dd) {
        fit <- cor.test(dd[[1]],
                        dd[[2]],
                        alternative = alternative,
                        method = method,
                        exact = exact)
        return(list(estimate = fit$estimate,
                    p_value = fit$p.value,
                    rows = nrow(dd)))
    }

    dig_grid(x = x,
             f = f,
             condition = !!condition,
             xvars = !!xvars,
             yvars = !!yvars,
             na_rm = TRUE,
             min_length = min_length,
             max_length = max_length,
             min_support = min_support,
             threads = threads,
             ...)
}

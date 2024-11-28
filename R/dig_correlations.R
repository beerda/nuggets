#' Search for conditional correlations
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Conditional correlations are patterns that identify strong relationships
#' between pairs of numeric variables under specific conditions.
#'
#' \describe{
#'   \item{Scheme:}{`xvar ~ yvar | C`\cr\cr
#'     `xvar` and `yvar` highly correlates in data that satisfy the condition
#'     `C`.}
#'   \item{Example:}{`study_time ~ test_score | hard_exam`\cr\cr
#'     For *hard exams*, the amount of *study time* is highly correlated with
#'     the obtained exam's *test score*.}
#' }
#'
#' The function computes correlations between all combinations of `xvars` and
#' `yvars` columns of `x` in multiple sub-data corresponding to conditions
#' generated from `condition` columns.
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
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [varnames()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
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
#' @examples
#' # convert iris$Species into dummy logical variables
#' d <- partition(iris, Species)
#'
#' # find conditional correlations between all pairs of numeric variables
#' res <- dig_correlations(d,
 #'                        condition = where(is.logical),
#'                         xvars = Sepal.Length:Petal.Width,
#'                         yvars = Sepal.Length:Petal.Width)
#'
#' # With `condition = NULL`, dig_correlations() computes correlations between
#' # all pairs of numeric variables on the whole dataset only, which is an
#' # alternative way of computing the correlation matrix
#' res <- dig_correlations(iris,
#'                         condition = NULL,
#'                         xvars = Sepal.Length:Petal.Width,
#'                         yvars = Sepal.Length:Petal.Width)
#' @export
dig_correlations <- function(x,
                             condition = where(is.logical),
                             xvars = where(is.numeric),
                             yvars = where(is.numeric),
                             disjoint = varnames(colnames(x)),
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
    .must_be_flag(exact, null = TRUE)

    condition <- enquo(condition)
    xvars <- enquo(xvars)
    yvars <- enquo(yvars)

    f <- function(d) {
        fit <- cor.test(d[[1]],
                        d[[2]],
                        alternative = alternative,
                        method = method,
                        exact = exact)
        return(list(estimate = fit$estimate,
                    p_value = fit$p.value,
                    method = fit$method,
                    alternative = fit$alternative,
                    rows = nrow(d)))
    }

    dig_grid(x = x,
             f = f,
             condition = !!condition,
             xvars = !!xvars,
             yvars = !!yvars,
             disjoint = disjoint,
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

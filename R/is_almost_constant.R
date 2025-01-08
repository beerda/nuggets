#' Tests if almost all values in a vector are the same.
#'
#' Function tests if almost all values in a vector are the same. The function
#' returns `TRUE` if the proportion of the most frequent value is greater or
#' equal to the `threshold` argument.
#'
#' @param x a vector to be tested
#' @param threshold a double scalar in the interval \eqn{[0,1]} that specifies
#'      the threshold for the proportion of the most frequent value
#' @param na_rm a flag indicating whether to remove `NA` values before testing
#'      the proportion of the most frequent value. That is, if `na_rm` is `TRUE`,
#'      the proportion is calculated from non-`NA` values only. If `na_rm` is
#'      `FALSE`, the proportion is calculated from all values and the value `NA`
#'      is considered as a normal value (i.e., too much `NA`s can make the vector
#'      almost constant too).
#' @return If `x` is empty or has only one value, the function returns `TRUE`.
#'      If `x` contains only `NA` values, the function returns `TRUE`.
#'      If the proportion of the most frequent value is greater or equal to the
#'      `threshold` argument, the function returns `TRUE`. Otherwise, the function
#'      returns `FALSE`.
#' @author Michal Burda
#' @examples
#' is_almost_constant(1)
#' is_almost_constant(1:10)
#' is_almost_constant(c(NA, NA, NA), na_rm = TRUE)
#' is_almost_constant(c(NA, NA, NA), na_rm = FALSE)
#' is_almost_constant(c(NA, NA, NA, 1, 2), threshold = 0.5, na_rm = FALSE)
#' is_almost_constant(c(NA, NA, NA, 1, 2), threshold = 0.5, na_rm = TRUE)
#' @export
is_almost_constant <- function(x,
                               threshold = 1.0,
                               na_rm = FALSE) {
    .must_be_vector_or_factor(x, null = TRUE)
    .must_be_flag(na_rm)
    .must_be_double_scalar(threshold)
    .must_be_in_range(threshold, c(0, 1))

    if (length(x) <= 1) {
        return(TRUE)
    }

    tab <- table(x, useNA = "no")
    if (length(tab) <= 0) {
        return(TRUE)
    }

    max_count <- max(tab)

    if (na_rm) {
        maxrel_count <- max_count / sum(tab)

    } else {
        na_count <- sum(is.na(x))
        max_count <- max(max_count, na_count)
        maxrel_count <- max_count / length(x)
    }

    maxrel_count >= threshold
}

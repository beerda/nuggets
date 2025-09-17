#' Bound a range of numeric values
#'
#' This function computes the range of numeric values in a vector and adjusts
#' the bounds to "nice" rounded numbers. Specifically, it rounds the lower
#' bound downwards (similar to [floor()]) and the upper bound upwards (similar
#' to [ceiling()]) to the specified number of digits. This can be useful when
#' preparing data ranges for axis labels, plotting, or reporting. The function
#' returns a numeric vector of length two, containing the adjusted lower and
#' upper bounds.
#'
#' @param x A numeric vector to be bounded.
#' @param digits An integer scalar specifying the number of digits to round the
#'   bounds to. A positive value determines the number of decimal places used.
#'   A negative value rounds to the nearest 10, 100, etc. If `digits` is
#'   `NULL`, no rounding is performed and the exact range is returned.
#' @param na_rm A logical flag indicating whether `NA` values should be removed
#'   before computing the range. If `TRUE`, the range is computed from non-`NA`
#'   values only. If `FALSE` and `x` contains any `NA` values, the function
#'   returns `c(NA, NA)`.
#'
#' @return A numeric vector of length two with the rounded lower and upper
#'   bounds of the range of `x`. The lower bound is always rounded down, and
#'   the upper bound is always rounded up. If `x` is `NULL` or has length zero,
#'   the function returns `NULL`.
#'
#' @seealso [floor()], [ceiling()]
#' @author Michal Burda
#'
#' @examples
#' bound_range(c(1.9, 2, 3.1), digits = 0)      # returns c(1, 4)
#' bound_range(c(190, 200, 301), digits = -2)   # returns c(100, 400)
#'
#' @export
bound_range <- function(x,
                        digits = 0,
                        na_rm = FALSE) {
    .must_be_numeric_vector(x, null = TRUE)
    .must_be_integerish_scalar(digits, null = TRUE)
    .must_be_flag(na_rm)

    if (is.null(x) || length(x) == 0) {
        return(NULL)
    }

    if (is.null(digits)) {
        return(range(x, na.rm = na_rm))
    }

    lo <- min(x, na.rm = na_rm)
    hi <- max(x, na.rm = na_rm)

    ex <- 10^digits
    lo <- floor(lo * ex) / ex
    hi <- ceiling(hi * ex) / ex

    c(lo, hi)
}

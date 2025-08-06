#' Bound a range of numeric values
#'
#' Function computes a range of numeric values and rounds the lower bound down
#' (like [floor()] and the upper bound up (like [ceiling()]) to the specified
#' number of digits. The function returns a numeric vector of length 2
#' with the lower and upper bounds of the range.
#'
#' @param x a numeric vector to be bounded
#' @param digits integer scalar specifying the number of digits
#'      to round the bounds to. Positive value determines the number of
#'      decimal points to round the bounds to. If `digits` is negative,
#'      the bounds are rounded to the nearest 10, 100, etc.
#' @param na_rm a flag indicating whether to remove `NA` values
#'      before computing the range. If `na_rm` is `TRUE`, the function
#'      computes the range from non-`NA` values only. If `na_rm` is `FALSE`,
#'      and `x` contains `NA` values, the function returns `c(NA, NA)`.
#' @return a numeric vector of length 2 with the lower and upper bounds
#'      of the range of `x` rounded to the specified number of digits.
#'      The lower bound is rounded down and the upper bound is rounded up.
#'      If `x` is `NULL` or has length 0, the function returns `NULL`.
#' @seealso [floor()], [ceiling()]
#' @author Michal Burda
#' @examples
#' bound_range(c(1.9, 2, 3.1), digits = 0)     # returns c(1, 4)
#' bound_range(c(190, 200, 301, digits = -2))  # returns c(100, 400)
#' @export
bound_range <- function(x,
                        digits = 0,
                        na_rm = FALSE) {
    .must_be_numeric_vector(x, null = TRUE)
    .must_be_integerish_scalar(digits)
    .must_be_flag(na_rm)

    if (is.null(x) || length(x) == 0) {
        return(NULL)
    }

    lo <- min(x, na.rm = na_rm)
    hi <- max(x, na.rm = na_rm)

    ex <- 10^digits
    lo <- floor(lo * ex) / ex
    hi <- ceiling(hi * ex) / ex

    c(lo, hi)
}

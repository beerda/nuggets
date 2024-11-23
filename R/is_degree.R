#' Tests whether the given argument is a numeric value from the interval
#' \eqn{[0,1]}
#'
#' @param x the value to be tested
#' @param na_rm whether to ignore `NA` values
#' @return `TRUE` if `x` is a numeric vector, matrix or array with values
#'      between 0 and 1, otherwise, `FALSE` is returned. If `na_rm` is `TRUE`,
#'      `NA` values are treated as valid values. If `na_rm` is `FALSE` and `x`
#'      contains `NA` values, `FALSE` is returned.
#' @author Michal Burda
#' @export
is_degree <- function(x, na_rm = FALSE) {
    .must_be_flag(na_rm)

    if (!is.numeric(x))
        return(FALSE)

    if (na_rm)
        x[is.na(x)] <- 0
    else
        if (any(is.na(x)))
            return(FALSE)

    all(x >= 0.0 & x <= 1.0)
}

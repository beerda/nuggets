#' Test whether an object contains numeric values from the interval \eqn{[0,1]}
#'
#' Check if the input consists only of numeric values between 0 and 1,
#' inclusive. This is often useful when validating truth degrees, membership
#' values in fuzzy sets, or probabilities.
#'
#' @param x The object to be tested. Can be a numeric vector, matrix, or array.
#' @param na_rm Logical; whether to ignore `NA` values. If `TRUE`, `NA`s are
#'   treated as valid values. If `FALSE` and `x` contains any `NA`s, the
#'   function immediately returns `FALSE`.
#'
#' @return A logical scalar. Returns `TRUE` if all (non-`NA`) elements of `x`
#'   are numeric and lie within the closed interval \eqn{[0,1]}. Returns
#'   `FALSE` if:
#'   * `x` contains any `NA` values and `na_rm = FALSE`
#'   * any element is outside the interval \eqn{[0,1]}
#'   * `x` is not numeric
#'   * `x` is empty (`length(x) == 0`)
#'
#' @seealso [is.numeric()]
#'
#' @author Michal Burda
#'
#' @examples
#' is_degree(0.5)
#' is_degree(c(0, 0.2, 1))
#' is_degree(c(0.5, NA), na_rm = TRUE)   # TRUE
#' is_degree(c(0.5, NA), na_rm = FALSE)  # FALSE
#' is_degree(c(-0.1, 0.5))               # FALSE
#' is_degree(numeric(0))                 # FALSE
#'
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

#' Determine whether the first vector is a subset of the second vector
#'
#' @param x the first vector
#' @param y the second vector
#' @return `TRUE` if `x` is a subset of `y`, or `FALSE` otherwise. `x` is
#'      considered a subset of `y` if all elements of `x` are also in `y`,
#'      i.e., if `setdiff(x, y)` is a vector of length 0.
#' @author Michal Burda
#' @export
is_subset <- function(x, y) {
    .must_be_vector(x, null = TRUE)
    .must_be_vector(y, null = TRUE)

    length(setdiff(x, y)) == 0L
}

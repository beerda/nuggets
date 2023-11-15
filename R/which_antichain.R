#' Return indices of first elements of the list, which are incomparable with preceding
#' elements.
#'
#' The function returns indices of elements from the given list `x`, which are incomparable
#' (i.e., it is neither subset nor superset) with any preceding element. The first element
#' is always selected. The next element is selected only if it is incomparable with all
#' previously selected elements.
#'
#' @param x a list of integerish vectors
#' @param distance a non-negative integer, which specifies the allowed discrepancy between compared sets
#' @return an integer vector of indices of selected (incomparable) elements.
#' @author Michal Burda
#' @export
which_antichain <- function(x, distance = 0) {
    .must_be_list_of_integerishes(x)
    .must_be_integerish_scalar(distance)
    .must_be_greater_eq(distance, 0)

    x <- lapply(x, as.integer)

    which_antichain_(x, as.integer(distance))
}

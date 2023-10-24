#' Return indices of first elements in a list, which are incomparable with preceding
#' elements.
#'
#' The function returns indices of elements from the given list `x`, for which the
#' given binary function `comparison` returns `FALSE` for all previously selected
#' elements.
#'
#' In other words, the function returns indices of selected elemnts from `x`. The
#' first element is always selected. The next element is selected only if all calls
#' of `comparable(a, b)` return `FALSE`, where `a` is the currently considered element
#' and `b` are all previously selected elements.
#'
#' @param x a list of elements
#' @param comparison a binary comparison function that must return a scalar logical
#'      value, i.e. `TRUE` or `FALSE`
#' @return an integer vector of indices of selected elements.
#' @author Michal Burda
#' @export
which_incomparable <- function(x,
                               comparison) {
    .must_be_list(x)
    .must_be_function(comparison)

    f <- function(i, j) {
        comparison(x[[i + 1]], x[[j + 1]])
    }

    res <- which_incomparable_(length(x), f)

    res + 1L
}

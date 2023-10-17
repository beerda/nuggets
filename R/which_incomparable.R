#'
#' @return
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

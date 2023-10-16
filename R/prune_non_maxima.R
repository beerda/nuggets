#'
#' @return
#' @author Michal Burda
#' @export
prune_non_maxima <- function(x, comparison) {
    .must_be_list(x)
    .must_be_function(comparison)

    res <- prune_non_maxima_(x, comparison)

    x[res + 1]
}

#'
#' @return
#' @author Michal Burda
#' @export
dig <- function(x, ...) {
    UseMethod("dig")
}


#' @rdname dig
#' @export
dig.default <- function(x, ...) {
    stop(paste0("'dig' is not implemented for class '", class(x), "'"))
}


#' @rdname dig
#' @export
dig.matrix <- function(x, ...) {
    assert_that(is.matrix(x))

    config <- list();
    cols <- lapply(seq_len(ncol(x)), function(i) x[, i])

    if (is.logical(x)) {
        dig_(cols, list(), config)
    } else if (is.double(x)) {
        dig_(list(), cols, config)
    } else {
        stop(paste0("'dig' is not implemented for non-double and non-logical matrices"))
    }
}

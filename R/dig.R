#'
#' @return
#' @author Michal Burda
#' @export
dig <- function(x, f, ...) {
    UseMethod("dig")
}


#' @rdname dig
#' @export
dig.default <- function(x, f, ...) {
    stop(paste0("'dig' is not implemented for class '", class(x), "'"))
}


#' @rdname dig
#' @export
dig.matrix <- function(x, f, ...) {
    assert_that(is.matrix(x))
    assert_that(is.function(f))

    config <- list(arguments = formalArgs(f),
                   predicates = seq_len(ncol(x)));

    cols <- lapply(seq_len(ncol(x)), function(i) x[, i])

    fun <- function(l) {
        do.call(f, l)
    }

    if (is.logical(x)) {
        dig_(cols, list(), config, fun)
    } else if (is.double(x)) {
        dig_(list(), cols, config, fun)
    } else {
        stop(paste0("'dig' is not implemented for non-double and non-logical matrices"))
    }
}

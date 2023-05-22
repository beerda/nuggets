#'
#' @return
#' @author Michal Burda
#' @export
dig <- function(x, f, max_length = -1, ...) {
    UseMethod("dig")
}


#' @rdname dig
#' @export
dig.default <- function(x, ...) {
    stop(paste0("'dig' is not implemented for class '", class(x), "'"))
}


if_null <- function(x, value) {
    if (is.null(x))
        value
    else
        x
}


#' @rdname dig
#' @export
dig.matrix <- function(x, f, max_length = -1L, ...) {
    assert_that(is.matrix(x))
    assert_that(is.function(f))
    assert_that(is.number(max_length))

    config <- list(arguments = if_null(formalArgs(f), ""),
                   predicates = seq_len(ncol(x)),
                   maxLength = as.integer(max_length));

    cols <- lapply(seq_len(ncol(x)), function(i) x[, i])

    fun <- function(l) {
        do.call(f, c(l, list(...)))
    }

    if (is.logical(x)) {
        dig_(cols, list(), config, fun)
    } else if (is.double(x)) {
        dig_(list(), cols, config, fun)
    } else {
        stop(paste0("'dig' is not implemented for non-double and non-logical matrices"))
    }
}

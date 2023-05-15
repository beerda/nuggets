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
    .stop(paste0("'dig' is not implemented for class '", class(x), "'"))
}


#' @rdname dig
#' @export
dig.matrix <- function(x, ...) {
    dig_(x, list())
}

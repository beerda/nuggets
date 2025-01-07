.msg <- function(verbose, message, ...) {
    if (isTRUE(verbose)) {
        message(message, ...)
    }
}

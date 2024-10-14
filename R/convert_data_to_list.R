.convert_data_to_list <- function(x) {
    if (is.data.frame(x)) {
        cols <- as.list(x)

    } else if (is.matrix(x)) {
        cols <- lapply(seq_len(ncol(x)), function(i) x[, i])
        names(cols) <- colnames(x)

    } else {
        cli_abort(c("{.var x} must be a matrix or a data frame.",
                    "x" = "You've supplied a {.cls {class(x)}}."),
                  call = caller_env(2))
    }

    if (is.null(names(cols))) {
        names(cols) <- seq_len(length(cols))
    }

    cols
}

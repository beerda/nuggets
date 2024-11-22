# Return the columns of `x` as a list. Also check that `x` is:
# - a matrix or a data frame;
# - has at least one column;
# - has at least one row.
#
# @param x A matrix or a data frame.
# @param arg The name of the `x` argument (used for error messages).
# @param call An environment in which to evaluate the error messages.
# @return A list of columns of `x`.
# @author Michal Burda
.convert_data_to_list <- function(x,
                                  arg = caller_arg(x),
                                  call = caller_env()) {
    if (is.data.frame(x)) {
        cols <- as.list(x)

    } else if (is.matrix(x)) {
        cols <- lapply(seq_len(ncol(x)), function(i) x[, i])
        names(cols) <- colnames(x)

    } else {
        cli_abort(c("{.arg {arg}} must be a matrix or a data frame.",
                    "x" = "You've supplied a {.cls {class(x)}}."),
                  call = call)
    }

    .must_have_some_cols(x, arg = arg, call = call)
    .must_have_some_rows(x, arg = arg, call = call)

    if (is.null(names(cols))) {
        names(cols) <- seq_len(length(cols))
    }

    cols
}

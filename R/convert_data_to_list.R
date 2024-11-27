# Return the columns of `x` as a list. Also check that `x` is:
# - a matrix or a data frame;
# - has at least one column;
# - has at least one row.
#
# @param x A matrix or a data frame.
# @param error_context A list of details to be used in error messages.
#       It must contain:
#       - `arg_x`: the name of the `x` argument;
#       - `call`: an environment in which to evaluate the error messages.
# @return A list of columns of `x`.
# @author Michal Burda
.convert_data_to_list <- function(x,
                                  error_context = list(arg_x = caller_arg(x),
                                                       call = caller_env())) {
    if (is.data.frame(x)) {
        cols <- as.list(x)

    } else if (is.matrix(x)) {
        cols <- lapply(seq_len(ncol(x)), function(i) x[, i])
        names(cols) <- colnames(x)

    } else {
        cli_abort(c("{.arg {error_context$arg_x}} must be a matrix or a data frame.",
                    "x" = "You've supplied a {.cls {class(x)}}."),
                  call = error_context$call)
    }

    .must_have_some_cols(x, arg = error_context$arg_x, call = error_context$call)
    .must_have_some_rows(x, arg = error_context$arg_x, call = error_context$call)

    if (is.null(names(cols))) {
        names(cols) <- seq_len(length(cols))
    }

    cols
}

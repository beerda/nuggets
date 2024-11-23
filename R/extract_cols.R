# Select elements from a list `cols` of columns by a tidyselect expression
# `selection`. Also check that all selected columns are logical or numeric
# from the interval [0,1].
#
# @param cols A list of columns.
# @param selection A tidyselect expression selecting the columns to be extracted.
# @param allow_numeric Whether to allow numeric columns in the selection.
# @param allow_empty Whether to allow empty selection.
# @param error_context A list of details to be used in error messages.
#       It must contain:
#       - `arg_selection`: the name of the `selection` argument;
#       - `call`: an environment in which to evaluate the error messages.
# @return A list with three elements:
# \itemize{
#   \item{logicals}{A list of logical columns.}
#   \item{doubles}{A list of numeric columns from the interval [0,1].}
#   \item{indices}{A vector of indices of selected columns in `cols`.}
# }
# @author Michal Burda
.extract_cols <- function(cols,
                          selection,
                          allow_numeric,
                          allow_empty,
                          error_context = list(arg_selection = caller_arg(selection),
                                               call = caller_env())) {
    selection <- enquo(selection)
    indices <- eval_select(expr = selection,
                           data = cols,
                           allow_rename = FALSE,
                           allow_empty = allow_empty,
                           error_call = error_context$call)
    cols <- cols[indices]
    logicals <- vapply(cols, is.logical, logical(1))
    doubles <- vapply(cols, is_degree, logical(1))
    test <- if (allow_numeric) logicals | doubles else logicals

    if (!all(test)) {
        errors <- c()
        for (i in which(!test)) {
            msg2 <- if (is.numeric(cols[[i]]))
                " with values less than 0 or greater than 1" else ""
            errors <- c(errors,
                        paste0("Column {.var ", names(cols)[i],
                               "} is of type {.cls ", typeof(cols[[i]]), "}{msg2}."))
        }

        msg <- if (allow_numeric) " or numeric from the interval [0,1]" else ""
        cli_abort(c("All columns selected by {.arg {error_context$arg_selection}} must be logical{msg}.",
                    ..error_details(errors)),
                  call = error_context$call)
    }

    list(logicals = cols[logicals],
         doubles = cols[doubles],
         indices = c(indices[logicals], indices[doubles]))
}



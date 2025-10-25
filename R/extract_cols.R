#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


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
#   \item{selected}{A logical vector of the same length as `cols` indicating
#       which columns were selected.}
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
                           allow_empty = TRUE,
                           error_call = error_context$call)

    if (!allow_empty && length(indices) <= 0) {
        cli_abort(c("{.arg {error_context$arg_selection}} must select non-empty list of columns.",
                    "x" = "{.arg {error_context$arg_selection}} resulted in an empty list."),
                  call = error_context$call)
    }

    selected <- rep(FALSE, length(cols))
    selected[indices] <- TRUE

    cols <- cols[indices]
    logicals <- vapply(cols, is.logical, logical(1))
    doubles <- vapply(cols, is_degree, logical(1))
    test <- if (allow_numeric) logicals | doubles else logicals

    if (!all(test)) {
        errors <- c()
        for (i in which(!test)) {
            msg2 <- if (allow_numeric && is.numeric(cols[[i]]))
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
         indices = c(indices[logicals], indices[doubles]),
         selected = selected)
}



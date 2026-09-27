#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2026 Michal Burda
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


# Select a single element from a list `cols` of columns by a tidyselect expression
# `selection` that is intended for weights. Also check that the
# selected column is numeric and greater than zero.
#
# @param cols A list of columns.
# @param selection A tidyselect expression selecting the weights column.
# @param error_context A list of details to be used in error messages.
#       It must contain:
#       - `arg_selection`: the name of the `selection` argument;
#       - `call`: an environment in which to evaluate the error messages.
# @return A numeric vector. If the selection is NULL, the numeric vector is empty.
# @author Michal Burda
.extract_weights <- function(cols,
                             selection,
                             error_context = list(arg_selection = caller_arg(selection),
                                                  call = caller_env())) {
    selection <- enquo(selection)
    indices <- eval_select(expr = selection,
                           data = cols,
                           allow_rename = FALSE,
                           allow_empty = TRUE,
                           error_call = error_context$call)

    if (length(indices) <= 0) {
        return(list(name = NULL, value = numeric()))
    } else if (length(indices) > 1) {
        cli_abort(c("{.arg {error_context$arg_selection}} must select at most one column.",
                    "x" = "{.arg {error_context$arg_selection}} resulted in {length(indices)} columns: {.field {names(cols[indices])}}."),
                  call = error_context$call)
    }

    res <- cols[[indices]]

    if (!is.numeric(res) || !all(is.finite(res)) || any(res <= 0)) {
        cli_abort("{.arg {error_context$arg_selection}} must be numeric with all values finite and greater than 0.")
    }

    list(name = names(cols)[indices],
         value = res)
}



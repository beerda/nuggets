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


#' @title Create an association matrix from a nugget of flavour `associations`.
#'
#' @description
#' The association matrix is a matrix where rows correspond to antecedents,
#' columns correspond to consequents, and the values are taken from a specified
#' column of the nugget. Missing values are filled with zeros.
#'
#' A pair of antecedent and consequent must be unique in the nugget. If there are
#' multiple rows with the same pair, an error is raised.
#'
#' @param x A nugget of flavour `associations`.
#' @param value A tidyselect expression (see
#'     [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'     specifying the column to use for filling the matrix values.
#' @param error_context A list of details to be used in error messages.
#'      It must contain:
#'      - `arg_x`: the name of the `x` argument;
#'      - `arg_value`: the name of the `value` argument;
#'      - `call`: an environment in which to evaluate the error messages.
#'        Defaults to the current environment.
#' @return A numeric matrix with row names corresponding to antecedents and
#'    column names corresponding to consequents. Values are taken from the
#'    column specified by `value`. Missing values are filled with zeros.
#'
#' @author Michal Burda
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' rules <- dig_associations(d,
#'                           antecedent = everything(),
#'                           consequent = everything(),
#'                           min_support = 0.3)
#' association_matrix(rules, confidence)
#' @export
association_matrix <- function(x,
                               value,
                               error_context = list(arg_x = "x",
                                                    arg_value = "value",
                                                    call = current_env())) {
    .must_be_nugget(x, "associations")
    .must_have_character_column(x,
                                "antecedent",
                                arg_x = error_context$arg_x,
                                call = error_context$call)
    .must_have_character_column(x,
                                "consequent",
                                arg_x = error_context$arg_x,
                                call = error_context$call)

    value <- enquo(value)
    value_col <- eval_select(expr = value,
                             data = x,
                             allow_rename = FALSE,
                             allow_empty = TRUE, # we test for empty selection later
                             allow_predicates = TRUE,
                             error_call = error_context$call)
    if (length(value_col) <= 0) {
        cli_abort(c("{.arg {error_context$arg_value}} must select a single column.",
                    "x" = "{.arg {error_context$arg_value}} resulted in an empty list."),
                  call = error_context$call)
    }
    if (length(value_col) > 1) {
        cli_abort(c("{.arg {error_context$arg_value}} must select a single column.",
                    "x" = "{.arg {error_context$arg_value}} resulted in multiple columns."),
                  call = error_context$call)
    }
    .must_have_column(x,
                      names(value_col),
                      arg_x = error_context$arg_x,
                      call = error_context$call)
    if (!is.numeric(x[[value_col]])) {
        cli_abort(c("{.arg {error_context$arg_value}} must select a numeric column.",
                    "x" = "{.arg {error_context$arg_value}} selects column {.field {names(value_col)}} which is of type {.cls {typeof(x[[value_col]])}}."),
                  call = error_context$call)
    }

    res <- pivot_wider(x,
                       id_cols = "antecedent",
                       names_from = "consequent",
                       values_from = !!value,
                       values_fill = 0,
                       values_fn = .na_on_dupl)

    if (any(is.na(res))) {
        wh <- which(is.na(res), arr.ind = TRUE)[1, , drop = TRUE]
        ante <- res[wh[1], "antecedent"]
        cons <- colnames(res)[wh[2]]
        cli_abort(c("Multiple values for the same cell in the association matrix.",
                    "x" = "Pairs of {.field antecedent} and {.field consequent} must be unique in {.arg {error_context$arg_x}}.",
                    "i" = "Combination of {.field antecedent} = {.val {ante}} and {.field consequent} = {.val {cons}} occurs multiple times in {.arg {error_context$arg_x}}."),
                  call = error_context$call)
    }

    row_names <- res$antecedent
    res$antecedent <- NULL
    res <- as.matrix(res)
    rownames(res) <- row_names

    res
}


.na_on_dupl <- function(x) {
    if (length(x) > 1) return(NA) else return(x)
}

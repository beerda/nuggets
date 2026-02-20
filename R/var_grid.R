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


#' @title Create a tibble of combinations of selected column names
#'
#' @description
#' The `xvars` and `yvars` arguments are tidyselect expressions (see
#' [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html)) that
#' specify the columns of `x` whose names will be used to form combinations.
#'
#' If `yvars` is `NULL`, the function creates a tibble with one column, `var`,
#' enumerating all column names selected by the `xvars` expression.
#'
#' If `yvars` is not `NULL`, the function creates a tibble with two columns,
#' `xvar` and `yvar`, whose rows enumerate all combinations of column names
#' specified by `xvars` and `yvars`.
#'
#' It is allowed to specify the same column in both `xvars` and `yvars`. In
#' such cases, self-combinations (a column paired with itself) are removed
#' from the result.
#'
#' In other words, the function creates a grid of all possible pairs
#' \eqn{(xx, yy)} where \eqn{xx \in xvars}, \eqn{yy \in yvars}, and
#' \eqn{xx \neq yy}.
#'
#' @details
#' `var_grid()` is typically used when a function requires a systematic list
#' of variables or variable pairs to analyze. For example, it can be used to
#' generate all pairs of variables for correlation, association, or contrast
#' analysis. The flexibility of `xvars` and `yvars` makes it possible to
#' restrict the grid to specific subsets of variables while ensuring that
#' invalid or redundant combinations (e.g., self-pairs or disjoint groups) are
#' excluded automatically.
#'
#' The `allow` argument can be used to restrict the selection of columns to
#' numeric columns only. This is useful when the resulting variable combinations
#' will be used in analyses that require numeric data, such as correlation or
#' contrast tests.
#'
#' The `disjoint` argument allows specifying groups of columns that should not
#' appear together in a single combination. This is useful when certain columns
#' represent mutually exclusive categories or measurements that should not be
#' analyzed together. For example, if `disjoint` groups columns by measurement
#' type, the function will ensure that no combination includes two columns from
#' the same type.
#'
#' @param x A data frame or matrix.
#' @param xvars A tidyselect expression specifying the columns of `x` whose
#'   names will be used in the first position (`xvar`) of the combinations.
#' @param yvars `NULL` or a tidyselect expression specifying the columns of
#'   `x` whose names will be used in the second position (`yvar`) of the
#'   combinations.
#' @param allow A character string specifying which columns may be selected by
#'   `xvars` and `yvars`. Possible values are:
#'   \itemize{
#'     \item `"all"` – all columns may be selected;
#'     \item `"numeric"` – only numeric columns may be selected.
#'   }
#' @param disjoint An atomic vector of length equal to the number of columns
#'   in `x` that specifies disjoint groups of predicates. Columns belonging to
#'   the same group (i.e. having the same value in `disjoint`) will not appear
#'   together in a single combination of `xvars` and `yvars`. Ignored if
#'   `yvars` is `NULL`.
#' @param xvar_name A character string specifying the name of the first column
#'   (`xvar`) in the output tibble.
#' @param yvar_name A character string specifying the name of the second
#'   column (`yvar`) in the output tibble. This column is omitted if
#'   `yvars` is `NULL`.
#' @param error_context A list providing details for error messages. This is
#'   useful when `var_grid()` is called from another function, allowing error
#'   messages to reference the caller’s argument names. The list must contain:
#'   \itemize{
#'     \item `arg_x` – name of the argument `x`;
#'     \item `arg_xvars` – name of the argument `xvars`;
#'     \item `arg_yvars` – name of the argument `yvars`;
#'     \item `arg_allow` – name of the argument `allow`;
#'     \item `arg_xvar_name` – name of the `xvar` column in the output;
#'     \item `arg_yvar_name` – name of the `yvar` column in the output;
#'     \item `call` – the calling environment for evaluating error messages.
#'   }
#'
#' @return If `yvars` is `NULL`, a tibble with a single column (`var`).
#'   If `yvars` is not `NULL`, a tibble with two columns (`xvar`, `yvar`)
#'   enumerating all valid combinations of column names selected by `xvars`
#'   and `yvars`. The order of variables in the result follows the order in
#'   which they are selected by `xvars` and `yvars`.
#'
#' @author Michal Burda
#'
#' @examples
#' # Grid of all pairwise column combinations in CO2
#' var_grid(CO2)
#'
#' # Grid of combinations where the first column is Plant, Type, or Treatment,
#' # and the second column is conc or uptake
#' var_grid(CO2, xvars = Plant:Treatment, yvars = conc:uptake)
#'
#' # Prevent variables from the same disjoint group from being paired together
#' d <- data.frame(a = 1:5, b = 6:10, c = 11:15, d = 16:20)
#' # Group (a, b) together and (c, d) together
#' var_grid(d, xvars = everything(), yvars = everything(),
#'          disjoint = c(1, 1, 2, 2))
#' @export
var_grid <- function(x,
                     xvars = everything(),
                     yvars = everything(),
                     allow = "all",
                     disjoint = var_names(colnames(x)),
                     xvar_name = if (quo_is_null(enquo(yvars))) "var" else "xvar",
                     yvar_name = "yvar",
                     error_context = list(arg_x = "x",
                                          arg_xvars = "xvars",
                                          arg_yvars = "yvars",
                                          arg_allow = "allow",
                                          arg_disjoint = "disjoint",
                                          arg_xvar_name = "xvar_name",
                                          arg_yvar_name = "yvar_name",
                                          call = current_env())) {
    .must_be_enum(allow, c("all", "numeric"),
                  arg = error_context$arg_allow,
                  call = error_context$call)
    .must_be_character_scalar(xvar_name,
                              arg = error_context$arg_xvar_name,
                              call = error_context$call)
    .must_be_character_scalar(yvar_name,
                              arg = error_context$arg_yvar_name,
                              call = error_context$call)

    cols <- .convert_data_to_list(x,
                                  error_context = list(arg_x = error_context$arg_x,
                                                       call = error_context$call))

    .must_be_vector_or_factor(disjoint,
                              null = TRUE,
                              arg = error_context$arg_disjoint,
                              call = error_context$call)
    if (!isTRUE(length(disjoint) == 0 || length(disjoint) == ncol(x))) {
        cli_abort(c("The length of {.arg {error_context$arg_disjoint}} must be 0 or must be equal to the number of columns in {.arg {error_context$arg_x}}.",
                    "x" = "The number of columns in {.arg {error_context$arg_x}} is {.val {ncol(x)}}.",
                    "x" = "The length of {.arg {error_context$arg_disjoint}} is {.val {length(disjoint)}}."),
                  call = error_context$call)
    }

    if (length(disjoint) > 0) {
        disjoint <- as.integer(as.factor(disjoint))
    } else {
        disjoint <- seq_along(cols)
    }

    xvars <- eval_select(expr = enquo(xvars),
                         data = cols,
                         allow_rename = FALSE,
                         allow_empty = TRUE, # we test for empty selection later
                         allow_predicates = TRUE,
                         error_call = error_context$call)


    if (length(xvars) <= 0) {
        cli_abort(c("{.arg {error_context$arg_xvars}} must select non-empty list of columns.",
                    "x" = "{.arg {error_context$arg_xvars}} resulted in an empty list."),
                  call = error_context$call)
    }

    has_yvars <- !quo_is_null(enquo(yvars))
    if (has_yvars) {
        yvars <- eval_select(expr = enquo(yvars),
                             data = cols,
                             allow_rename = FALSE,
                             allow_empty = TRUE, # we test for empty selection later
                             allow_predicates = TRUE,
                             error_call = error_context$call)

        if (length(yvars) <= 0) {
            cli_abort(c("{.arg {error_context$arg_yvars}} must select non-empty list of columns.",
                        "x" = "{.arg {error_context$arg_yvars}} resulted in an empty list."),
                      call = error_context$call)
        }
        if (length(xvars) == 1 && length(yvars) == 1 && xvars == yvars) {
            cli_abort(c("{.arg {error_context$arg_xvars}} and {.arg {error_context$arg_yvars}} can't select the same single column.",
                        "i" = "{.arg {error_context$arg_xvars}} results in column: {paste(names(cols)[xvars], collapse = ', ')}.",
                        "i" = "{.arg {error_context$arg_yvars}} results in column: {paste(names(cols)[yvars], collapse = ', ')}."),
                      call = error_context$call)
        }
    }

    if (allow == "numeric") {
        .all_selected_must_be(cols[xvars],
                              error_context$arg_xvars,
                              is.numeric,
                              "numeric",
                              error_context$call)
        if (has_yvars) {
            .all_selected_must_be(cols[yvars],
                                  error_context$arg_yvars,
                                  is.numeric,
                                  "numeric",
                                  error_context$call)
        }
    }

    if (has_yvars) {
        grid <- expand_grid(xvar = xvars, yvar = yvars)
        grid <- grid[disjoint[grid$xvar] != disjoint[grid$yvar], ]
        dup <- apply(grid, 1, function(row) paste(sort(row), collapse = " "))
        grid <- grid[!duplicated(dup), ]
        grid$xvar <- names(cols)[grid$xvar]
        grid$yvar <- names(cols)[grid$yvar]
        colnames(grid) <- c(xvar_name, yvar_name)

    } else {
        grid <- expand_grid(xvar = xvars)
        grid$xvar <- names(cols)[grid$xvar]
        colnames(grid) <- xvar_name
    }

    res <- as_tibble(grid)
    attr(res, "xvars") <- names(cols)[xvars]
    if (has_yvars) {
        attr(res, "yvars") <- names(cols)[yvars]
    } else {
        attr(res, "yvars") <- NULL
    }

    res
}


.all_selected_must_be <- function(x, arg, test_fun, test_type, call) {
    test <- vapply(x, test_fun, logical(1))
    if (!all(test)) {
        types <- sapply(x, function(i) class(i)[1])
        details <- paste0("Column {.field ", names(x), "} is a {.cls ", types, "}.")
        details <- details[!test]
        cli_abort(c("All columns selected by {.arg {arg}} must be {test_type}.",
                    ..error_details(details)),
                  call = call)
    }
}

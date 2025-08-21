#' Create a tibble of combinations of selected column names
#'
#' @description
#' `xvars` and `yvars` arguments are tidyselect expressions (see
#' [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html)) that
#' specify the columns of `x` whose names will be used as a domain for
#' combinations.
#'
#' If `yvars` is `NULL`, the function creates a tibble with one column `var`
#' enumerating all column names specified by the `xvars` argument.
#'
#' If `yvars` is not `NULL`, the function creates a tibble with two columns,
#' `xvar` and `yvar`, whose rows enumerate all combinations of column names
#' specified by the `xvars` and `yvars` argument.
#'
#' It is allowed to specify the same column in both `xvars` and `yvars`
#' arguments. In such a case, the combinations of the same column with itself
#' are removed from the result.
#'
#' In other words, the function creates a grid of all possible pairs
#' \eqn{(xx, yy)} where \eqn{xx \in xvars}, \eqn{yy \in yvars},
#' and \eqn{xx \neq yy}.
#'
#' @param x either a data frame or a matrix
#' @param xvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the first place (xvar)
#' @param yvars `NULL` or a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the second place (yvar)
#' @param allow a character string specifying which columns are allowed to be
#'      selected by `xvars` and `yvars` arguments. Possible values are:
#'      \itemize{
#'      \item `"all"` - all columns are allowed to be selected
#'      \item `"numeric"` - only numeric columns are allowed to be selected
#'      }
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single combination of `xvars` and `yvars`. If
#'      `yvars` is `NULL`, the `disjoint` argument is ignored.
#' @param xvar_name the name of the first column in the resulting tibble.
#' @param yvar_name the name of the second column in the resulting tibble.
#'      The column does not exist if `yvars` is `NULL`.
#' @param error_context A list of details to be used in error messages.
#'      This argument is useful when `var_grid()` is called from another
#'      function to provide error messages, which refer to arguments of the
#'      calling function. The list must contain the following elements:
#'      \itemize{
#'      \item `arg_x` - the name of the argument `x` as a character string
#'      \item `arg_xvars` - the name of the argument `xvars` as a character string
#'      \item `arg_yvars` - the name of the argument `yvars` as a character string
#'      \item `arg_allow` - the name of the argument `allow` as a character string
#'      \item `arg_xvar_name` - the name of the `xvar` column in the output tibble
#'      \item `arg_yvar_name` - the name of the `yvar` column in the output tibble
#'      \item `call` - an environment in which to evaluate the error messages.
#'      }
#' @return if `yvars` is `NULL`, the function returns a tibble with a single
#'      column (`var`). If `yvars` is a non-`NULL` expression, the function
#'      returns two columns (`xvar` and `yvar`) with rows enumerating
#'      all combinations of column names specified by tidyselect expressions
#'      in `xvars` and `yvars` arguments.
#' @author Michal Burda
#' @examples
#' # Create a grid of combinations of all pairs of columns in the CO2 dataset:
#' var_grid(CO2)
#'
#' # Create a grid of combinations of all pairs of columns in the CO2 dataset
#' # such that the first, i.e., `xvar` column is `Plant`, `Type`, or
#' # `Treatment`, and the second, i.e., `yvar` column is `conc` or `uptake`:
#' var_grid(CO2, xvars = Plant:Treatment, yvars = conc:uptake)
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
                    "x" = "The number of columns in {.arg {error_context$arg_x}} is {ncol(x)}.",
                    "x" = "The length of {.arg {error_context$arg_disjoint}} is {length(disjoint)}."),
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
        details <- paste0("Column {.var ", names(x), "} is a {.cls ", types, "}.")
        details <- details[!test]
        cli_abort(c("All columns selected by {.arg {arg}} must be {test_type}.",
                    ..error_details(details)),
                  call = call)
    }
}

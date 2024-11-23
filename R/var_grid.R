#' Create a tibble of combinations of xvar/yvar variable pairs.
#'
#' The function creates a tibble with two columns, `xvar` and `yvar`, whose
#' rows enumerate all combinations of column names specified by the `xvars`
#' and `yvars` argument. These arguments are tidyselect expressions (see
#' [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html)).
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
#' @param yvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the second place (yvar)
#' @param error_context A list of details to be used in error messages.
#'      This argument is useful when `var_grid()` is called from another
#'      function to provide error messages, which refer to arguments of the
#'      calling function. The list must contain the following elements:
#'      - `arg_x` - the name of the argument `x` as a character string
#'      - `arg_xvars` - the name of the argument `xvars` as a character string
#'      - `arg_yvars` - the name of the argument `yvars` as a character string
#'      - `call` - an environment in which to evaluate the error messages.
#' @return a tibble with two columns (`xvar` and `yvar`) with rows enumerating
#'      all combinations of column names specified by tidyselect expressions
#'      in `xvars` and `yvars` arguments.
#' @author Michal Burda
#' @examples
#' # Create a grid of combinations of all pairs of columns in the CO2 dataset:
#' var_grid(CO2)
#'
#' # Create a grid of combinations of all pairs of columns in the CO2 dataset
#' # such that the first, i.e., `xvar` column is `Plant`, `Type`, or
#' `Treatment`, and the second, i.e., `yvar` column is `conc` or `uptake`:
#' var_grid(CO2, xvars = Plant:Treatment, yvars = conc:uptake)
#' @export
var_grid <- function(x,
                     xvars = everything(),
                     yvars = everything(),
                     error_context = list(arg_x = "x",
                                          arg_xvars = "xvars",
                                          arg_yvars = "yvars",
                                          call = current_env())) {
    cols <- .convert_data_to_list(x,
                                  error_context = list(arg = error_context$arg_x,
                                                       call = error_context$call))

    xvars <- eval_select(expr = enquo(xvars),
                         data = cols,
                         allow_rename = FALSE,
                         allow_empty = TRUE, # we test for empty selection later
                         allow_predicates = TRUE,
                         error_call = error_context$call)
    yvars <- eval_select(expr = enquo(yvars),
                         data = cols,
                         allow_rename = FALSE,
                         allow_empty = TRUE, # we test for empty selection later
                         allow_predicates = TRUE,
                         error_call = error_context$call)

    if (length(xvars) <= 0) {
        cli_abort(c("{.arg {error_context$arg_xvars}} must specify the list of columns.",
                    "x" = "{.arg {error_context$arg_xvars}} resulted in an empty list."),
                  call = error_context$call)
    }
    if (length(yvars) <= 0) {
        cli_abort(c("{.arg {error_context$arg_yvars}} must specify the list of columns.",
                    "x" = "{.arg {error_context$arg_yvars}} resulted in an empty list."),
                  call = error_context$call)
    }
    if (length(xvars) == 1 && length(yvars) == 1 && xvars == yvars) {
        cli_abort(c("{.arg {error_context$arg_xvars}} and {.arg {error_context$arg_yvars}} must specify different columns.",
                    "x" = "{.arg {error_context$arg_xvars}} and {.arg {error_context$arg_yvars}} are the same.",
                    "i" = "{.arg {error_context$arg_xvars}} results in columns: {paste(names(cols)[xvars], collapse = ', ')}.",
                    "i" = "{.arg {error_context$arg_yvars}} results in columns: {paste(names(cols)[yvars], collapse = ', ')}."),
                  call = error_context$call)
    }

    grid <- expand_grid(xvar = xvars, yvar = yvars)
    grid <- grid[grid$xvar != grid$yvar, ]
    dup <- apply(grid, 1, function(row) paste(sort(row), collapse = " "))
    grid <- grid[!duplicated(dup), ]
    grid$xvar <- names(cols)[grid$xvar]
    grid$yvar <- names(cols)[grid$yvar]

    as_tibble(grid)
}

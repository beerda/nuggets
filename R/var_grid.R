#' Create a tibble of combinations of xvar/yvar variable pairs.
#'
#' The function creates a tibble with two columns, `xvar` and `yvar`, whose
#' rows enumerate all combinations of column names specified in the `xvars`
#' and `yvars` argument. The column names to create the combinations from are
#' specified using a tidyselect expression (see
#' [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html)).
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
#' @param call an environment in which to evaluate the error messages. This
#'      argument is useful when `var_grid()` is called from another function,
#'      which too has the arguments `x`, `xvars`, and `yvars`. In such a case,
#'      the `call` argument should be explicitly set to `current_env()`.
#' @return a tibble with two columns (`xvar` and `yvar`) with rows enumerating
#'      all combinations of column names specified by tidyselect expressions
#'      in `xvars` and `yvars` arguments.
#' @author Michal Burda
#'
#' @examples
#' var_grid(CO2)
#' var_grid(CO2, xvars = Plant:Treatment, yvars = conc:uptake)
#'
#' @export
var_grid <- function(x,
                     xvars = everything(),
                     yvars = everything(),
                     call = current_env()) {
    xvars <- enquo(xvars)
    yvars <- enquo(yvars)

    cols <- .convert_data_to_list(x, call = call)

    xvars <- eval_select(xvars, cols)
    yvars <- eval_select(yvars, cols)

    if (length(xvars) <= 0) {
        cli_abort(c("{.var xvars} must specify the list of columns.",
                    "x" = "{.var xvars} resulted in an empty list."),
                  call = call)
    }
    if (length(yvars) <= 0) {
        cli_abort(c("{.var yvars} must specify the list of columns.",
                    "x" = "{.var yvars} resulted in an empty list."),
                  call = call)
    }
    if (length(xvars) == 1 && length(yvars) == 1 && xvars == yvars) {
        cli_abort(c("{.var xvars} and {.var yvars} must specify different columns.",
                    "x" = "{.var xvars} and {.var yvars} are the same."),
                  call = call)
    }

    grid <- expand_grid(xvar = xvars, yvar = yvars)
    grid <- grid[grid$xvar != grid$yvar, ]
    dup <- apply(grid, 1, function(row) paste(sort(row), collapse = " "))
    grid <- grid[!duplicated(dup), ]
    grid$xvar <- names(cols)[grid$xvar]
    grid$yvar <- names(cols)[grid$yvar]

    as_tibble(grid)
}

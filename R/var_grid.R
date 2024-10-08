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
                     call = caller_env()) {
    xvars <- enquo(xvars)
    yvars <- enquo(yvars)

    if (is.matrix(x)) {
        cols <- lapply(seq_len(ncol(x)), function(i) x[, i])
        names(cols) <- colnames(x)
        if (is.null(names(cols))) {
            names(cols) <- seq_len(length(cols))
        }
    } else if (is.data.frame(x)) {
        cols <- as.list(x)
        if (is.null(names(cols))) {
            names(cols) <- seq_len(length(cols))
        }
    } else {
        cli_abort(c("{.var x} must be a matrix or a data frame.",
                    "x" = "You've supplied a {.cls {class(x)}}."))
    }

    xvars <- eval_select(xvars, cols)
    yvars <- eval_select(yvars, cols)

    if (length(xvars) <= 0) {
        cli_abort(c("{.var xvars} must specify the list of numeric columns.",
                    "x" = "{.var xvars} resulted in an empty list."))
    }
    if (length(yvars) <= 0) {
        cli_abort(c("{.var yvars} must specify the list of numeric columns.",
                    "x" = "{.var yvars} resulted in an empty list."))
    }

    grid <- expand_grid(xvar = xvars, yvar = yvars)
    grid <- grid[grid$xvar != grid$yvar, ]
    dup <- apply(grid, 1, function(row) paste(sort(row), collapse = " "))
    grid <- grid[!duplicated(dup), ]
    grid$xvar <- names(cols)[grid$xvar]
    grid$yvar <- names(cols)[grid$yvar]

    as_tibble(grid)
}

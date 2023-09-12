#' Create dummy columns from logicals or factors in a data frame
#'
#' Create dummy logical columns from selected columns of the data frame.
#' Dummy columns may be created for logical or factor columns as follows:
#'
#' - for logical column `col`, a pair of columns is created named `col=T`
#'   and `col=F` where the former (resp. latter) is equal to the original
#'   (resp. negation of the original);
#' - for factor column `col`, a new logical column is created for each
#'   level `l` of the factor `col` and named as `col=l` with a value set
#'   to TRUE wherever the original column is equal to `l`.
#'
#' @param .data a data frame to be processed
#' @param what a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      selecting the columns to be processed
#' @param ... further tidyselect expressions for selecting the columns to
#'      be processed
#' @param .keep whether to keep the original columns. If FALSE, the original
#'      columns are removed from the result.
#' @returns A tibble with selected columns replaced with dummy columns.
#' @export
#' @author Michal Burda
dichotomize <- function(.data, what = everything(), ..., .keep = FALSE) {
    .must_be_data_frame(.data)
    .must_be_flag(.keep)

    sel <- enquos(what, ...)
    sel <- lapply(sel, eval_select, .data)
    sel <- unlist(sel)
    emptydf <- as_tibble(data.frame(matrix(NA, nrow = nrow(.data), ncol = 0)))
    call <- current_env()

    res <- lapply(seq_along(sel), function(i) {
        colname <- names(sel)[i]
        colindex <- sel[i]
        res <- emptydf
        x <- .data[[colindex]]

        if (is.logical(x)) {
            res <- tibble(a=x, b=!x)
            colnames(res) <- paste0(colname, "=", c("T", "F"))
        } else if (is.factor(x)) {
            res <- lapply(levels(x), function(lev) x == lev)
            names(res) <- paste0(colname, "=", levels(x))
            res <- as_tibble(res)
        } else {
            cli_abort(c("Unable to dichotomize the column {.var {colname}}.",
                       "i"="Column to dichotomize must be a factor or logical.",
                       "x"="The column {.var {colname}} is a {.cls {class(x)}}."),
                      call = call)
        }

        if (.keep) {
            res <- cbind(.data[colindex], res)
        }

        res
    })

    as_tibble(do.call(cbind, res))
}

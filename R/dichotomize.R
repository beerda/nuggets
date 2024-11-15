#' Create dummy columns from logicals or factors in a data frame
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because [partition()] is more general and
#' can be used to create dummy columns as well.
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
#' @param .other whether to put into result the rest of columns that were not
#'      specified for dichotomization in `what` argument.
#' @returns A tibble with selected columns replaced with dummy columns.
#' @examples
#' dichotomize(CO2, Plant:Treatment, .other = TRUE)
#' # ->
#' partition(CO2, Plant:Treatment)
#' @export
#' @keywords internal
#' @author Michal Burda
dichotomize <- function(.data,
                        what = everything(),
                        ...,
                        .keep = FALSE,
                        .other = FALSE) {
    lifecycle::deprecate_soft("1.3.0", "dichotomize()", with = "partition()")

    .must_be_data_frame(.data)
    .must_be_flag(.keep)
    .must_be_flag(.other)

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
            cli_abort(c("Unable to dichotomize column {.var {colname}}.",
                       "i"="Column to dichotomize must be a factor or logical.",
                       "x"="The column {.var {colname}} is a {.cls {class(x)}}."),
                      call = call)
        }

        if (.keep) {
            res <- cbind(.data[colindex], res)
        }

        res
    })

    res <- do.call(cbind, res)

    if (.other) {
        res <- cbind(.data[, -sel, drop = FALSE], res)
    }

    as_tibble(res)
}

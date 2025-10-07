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
#' # dichotomize(CO2, Plant:Treatment, .other = TRUE)
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
    lifecycle::deprecate_stop("1.4.0", "dichotomize()", with = "partition()")
}

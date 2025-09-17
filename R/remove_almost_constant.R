#' Remove almost constant columns from a data frame
#'
#' Test all columns specified by `.what` and remove those that are almost
#' constant. A column is considered almost constant if the proportion of its
#' most frequent value is greater than or equal to the threshold specified by
#' `.threshold`. See [is_almost_constant()] for further details.
#'
#' @param .data A data frame.
#' @param .what A tidyselect expression (see
#'   [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'   specifying the columns to process.
#' @param ... Additional tidyselect expressions selecting more columns.
#' @param .threshold Numeric scalar in the interval \eqn{[0,1]} giving the
#'   minimum required proportion of the most frequent value for a column to be
#'   considered almost constant.
#' @param .na_rm Logical; if `TRUE`, `NA` values are removed before computing
#'   proportions. If `FALSE`, `NA` is treated as a regular value. See
#'   [is_almost_constant()] for details.
#' @param .verbose Logical; if `TRUE`, print a message listing the removed
#'   columns.
#'
#' @return A data frame with all selected columns removed that meet the
#'   definition of being almost constant.
#'
#' @seealso [is_almost_constant()], [remove_ill_conditions()]
#'
#' @author Michal Burda
#'
#' @examples
#' d <- data.frame(a1 = 1:10,
#'                 a2 = c(1:9, NA),
#'                 b1 = "b",
#'                 b2 = NA,
#'                 c1 = rep(c(TRUE, FALSE), 5),
#'                 c2 = rep(c(TRUE, NA), 5),
#'                 d  = c(rep(TRUE, 4), rep(FALSE, 4), NA, NA))
#'
#' # Remove columns that are constant (threshold = 1)
#' remove_almost_constant(d, .threshold = 1.0, .na_rm = FALSE)
#' remove_almost_constant(d, .threshold = 1.0, .na_rm = TRUE)
#'
#' # Remove columns where the majority value occurs in ≥ 50% of rows
#' remove_almost_constant(d, .threshold = 0.5, .na_rm = FALSE)
#' remove_almost_constant(d, .threshold = 0.5, .na_rm = TRUE)
#'
#' # Restrict check to a subset of columns
#' remove_almost_constant(d, a1:b2, .threshold = 0.5, .na_rm = TRUE)
#'
#' @export
remove_almost_constant <- function(.data,
                                   .what = everything(),
                                   ...,
                                   .threshold = 1.0,
                                   .na_rm = FALSE,
                                   .verbose = FALSE) {
    .must_be_data_frame(.data)
    .must_be_double_scalar(.threshold)
    .must_be_in_range(.threshold, c(0, 1))
    .must_be_flag(.verbose)

    .data <- as_tibble(.data)
    sel <- enquos(.what, ...)
    sel <- lapply(sel,
                  eval_select,
                  data = .data,
                  allow_rename = FALSE,
                  allow_empty = TRUE,
                  error_call = current_env())
    sel <- unlist(sel)

    if (length(sel) <= 0) {
        return(.data)
    }

    const <- vapply(sel,
                    function(s) is_almost_constant(.data[[s]],
                                                   threshold = .threshold,
                                                   na_rm = .na_rm),
                    logical(1))
    const <- sel[const]
    res <- setdiff(seq_len(ncol(.data)), const)

    if (.verbose) {
        if (is.null(names(.data))) {
            message("Removing (almost) constant columns: ",
                    paste(const, collapse = ", "))
        } else {
            message("Removing (almost) constant columns: ",
                    paste(names(.data)[const], collapse = ", "))
        }
    }

    .data[res]
}

#' Remove almost constant columns from a data frame
#'
#' Function tests all columns that are specified by the `.what` argument
#' and removes those that are almost constant. A column is considered
#' almost constant if the proportion of the most frequent value is greater
#' than the threshold specified by the `.threshold` argument. See
#' [is_almost_constant()] for details.
#'
#' @param .data a data frame
#' @param .what a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      selecting the columns to be processed
#' @param ... optional other tidyselect expressions selecting additional
#'      columns to be processed
#' @param .threshold a numeric scalar in the range \eqn{[0, 1]} specifying the
#'      threshold for the proportion of the most frequent value
#' @param .na_rm a logical scalar indicating whether to remove `NA` values
#'      before computing the proportion of the most frequent value. See
#'      [is_almost_constant()] for details of how `NA` values are handled.
#' @param .verbose a logical scalar indicating whether to print a message
#'      about removed columns
#' @return A data frame with removed all columns specified by the `.what`
#'      argument that are also (almost) constant
#' @author Michal Burda
#' @seealso [is_almost_constant()]
#' @examples
#' d <- data.frame(a1 = 1:10,
#'                 a2 = c(1:9, NA),
#'                 b1 = "b",
#'                 b2 = NA,
#'                 c1 = rep(c(TRUE, FALSE), 5),
#'                 c2 = rep(c(TRUE, NA), 5),
#'                 d = c(rep(TRUE, 4), rep(FALSE, 4), NA, NA))
#' remove_almost_constant(d, .threshold = 1.0, .na_rm = FALSE)
#' remove_almost_constant(d, .threshold = 1.0, .na_rm = TRUE)
#' remove_almost_constant(d, .threshold = 0.5, .na_rm = FALSE)
#' remove_almost_constant(d, .threshold = 0.5, .na_rm = TRUE)
#' remove_almost_constant(d, a1:b2, .threshold = 0.5, .na_rm = TRUE)
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

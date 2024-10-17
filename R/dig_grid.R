#' Search for grid-based rules
#'
#' This function creates a grid of combinations of pairs of columns specified
#' by `xvars` and `yvars` (see also [var_grid()]). After that, it enumerates all
#' conditions created from data in `x` (by calling [dig()]) and for each such
#' condition and for each row of the grid of combinations, a user-defined
#' function `f` is executed on each sub-data created from `x` by selecting all
#' rows of `x` that satisfy the generated condition and by selecting the
#' columns in the grid's row.
#'
#' @param x a matrix or data frame with data to search in.
#' @param f the callback function to be executed on a data frame that is passed
#'      to the function as the first argument. The data frame consists from two
#'      columns (a combination of `xvars`/`yvars` columns) and from all rows
#'      of `x` that satisfy the generated condition. The function must return
#'      a list of scalar values, which will be converted into a single row
#'      of result of final tibble.
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates. The selected
#'      columns must be logical or numeric. If numeric, fuzzy conditions are
#'      considered.
#' @param xvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the first place (xvar)
#' @param yvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the second place (yvar)
#' @param na_rm a logical value indicating whether to remove rows with missing
#'      values from sub-data before the callback function `f` is called
#' @param min_length the minimum size (the minimum number of predicates) of the
#'      condition to be generated (must be greater or equal to 0). If 0, the empty
#'      condition is generated in the first place.
#' @param max_length the maximum size (the maximum number of predicates) of the
#'      condition to be generated. If equal to Inf, the maximum length of conditions
#'      is limited only by the number of available predicates.
#' @param min_support the minimum support of a condition to trigger the callback
#'      function for it. The support of the condition is the relative frequency
#'      of the condition in the dataset `x`. For logical data, it equals to the
#'      relative frequency of rows such that all condition predicates are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values.
#' @param threads the number of threads to use for parallel computation.
#' @param ... Further arguments, currently unused.
#' @return A tibble with found rules. Each row represents a single call of
#'      the callback function `f`.
#' @author Michal Burda
#' @seealso [dig()], [var_grid()], and [dig_correlations()], as it is using this
#'     function internally
#' @export
dig_grid <- function(x,
                     f,
                     condition = where(is.logical),
                     xvars = where(is.numeric),
                     yvars = where(is.numeric),
                     na_rm = FALSE,
                     min_length = 0L,
                     max_length = Inf,
                     min_support = 0.0,
                     threads = 1,
                     ...) {
    .must_be_flag(na_rm)

    condition <- enquo(condition)

    cols <- .convert_data_to_list(x)
    .extract_cols_and_check(cols,
                            !!condition,
                            varname = "condition",
                            numeric_allowed = FALSE)

    xvars <- enquo(xvars)
    yvars <- enquo(yvars)
    grid <- var_grid(x, !!xvars, !!yvars)

    ff <- function(condition, support, indices) {
        cond <- format_condition(names(condition))
        d <- x[indices, , drop = FALSE]

        result <- apply(grid, 1, function(row) {
            dd <- d[, row, drop = FALSE]
            if (na_rm)
                dd <- na.omit(dd)

            f(dd)
        })

        result <- lapply(result, as_tibble)
        result <- do.call(rbind, result)

        cbind(condition = rep(cond, nrow(grid)),
              support = support,
              grid,
              result)
    }

    res <- dig(x = x,
               f = ff,
               condition = !!condition,
               min_length = min_length,
               max_length = max_length,
               min_support = min_support,
               threads = threads,
               ...)

    res <- do.call(rbind, res)

    as_tibble(res)
}

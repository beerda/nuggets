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
#' @param f the callback function to be executed for each generated condition.
#'      The arguments of the callback function differ based on the value of the
#'      `type` argument (see below). If `type = "bool"`, the callback function
#'      `f` must accept a single argument `d` of type `data.frame` with two
#'      columns (xvar and yvar). It is a subset of the original data frame
#'      with all rows that satisfy the generated condition. If `type = "fuzzy"`,
#'      the callback function `f` must accept an argument `d` of type
#'      `data.frame` with two columns (xvar and yvar) and a numeric `weights`
#'      argument with the same length as the number of rows in `d`. The
#'      `weights` argument contains the truth degree of the generated condition
#'      for each row of `d`. The truth degree is a number in the interval
#'      \eqn{[0, 1]} that represents the degree of satisfaction of the condition
#'      for the row.
#'      In all cases, the function must return a list of scalar values, which
#'      will be converted into a single row of result of final tibble.
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
#' @param type a character string specifying the type of conditions to be processed.
#'      The `"bool"` type accepts only logical columns as condition predicates.
#'      The `"fuzzy"` type accepts both logical and numeric columns as condition
#'      predicates where numeric data are in the interval \eqn{[0, 1]}. The
#'      callback function `f` differs based on the value of the `type` argument
#'      (see the description of `f` above).
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
                     type = "bool",
                     min_length = 0L,
                     max_length = Inf,
                     min_support = 0.0,
                     threads = 1,
                     ...) {
    .must_be_flag(na_rm)
    .must_be_enum(type, c("bool", "fuzzy"))

    .must_be_function(f)
    required_args <- if (type == "bool") c("d") else c("d", "weights")
    required_args_msg <- paste0("`", paste0(required_args, collapse = '`, `'), "`")
    unrecognized_args <- setdiff(formalArgs(f), required_args)
    if (length(unrecognized_args) > 0) {
        details <- paste0("The argument {.var ", unrecognized_args, "} is not allowed.")
        cli_abort(c("The function {.var f} must have the following arguments: {required_args_msg}.",
                    ..error_details(details)))
    }
    unrecognized_args <- setdiff(required_args, formalArgs(f))
    if (length(unrecognized_args) > 0) {
        details <- paste0("The argument {.var ", unrecognized_args, "} is missing.")
        cli_abort(c("The function {.var f} must have the following arguments: {required_args_msg}.",
                    ..error_details(details)))
    }

    condition <- enquo(condition)

    cols <- .convert_data_to_list(x)
    .extract_cols_and_check(cols,
                            !!condition,
                            varname = "condition",
                            numeric_allowed = (type == "fuzzy"))

    xvars <- enquo(xvars)
    yvars <- enquo(yvars)
    grid <- var_grid(x, !!xvars, !!yvars)

    fbool <- function(condition, support, indices) {
        cond <- format_condition(names(condition))
        d <- x[indices, , drop = FALSE]

        result <- apply(grid, MARGIN = 1, simplify = FALSE, FUN = function(row) {
            dd <- d[, row, drop = FALSE]
            if (na_rm)
                dd <- na.omit(dd)

            f(d = dd)
        })

        isnull <- sapply(result, is.null)
        result <- lapply(result[!isnull], as_tibble)
        result <- do.call(rbind, result)
        gr <- grid[!isnull, ]

        if (!is.null(result)) {
            result <- cbind(condition = rep(cond, nrow(gr)),
                            support = support,
                            gr,
                            result)
        }

        result
    }

    ffuzzy <- function(condition, support, weights) {
        cond <- format_condition(names(condition))

        result <- apply(grid, 1, function(row) {
            dd <- x[, row, drop = FALSE]
            if (na_rm) {
                dd <- na.omit(dd)
                weights <- weights[attr(dd, "na.action")]
            }

            f(d = dd, weights = weights)
        })

        result <- lapply(result, as_tibble)
        result <- do.call(rbind, result)

        cbind(condition = rep(cond, nrow(grid)),
              support = support,
              grid,
              result)
    }

    ff <- ifelse(type == "bool", fbool, ffuzzy)

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

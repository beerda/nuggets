#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


#' @title Search for grid-based rules
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function creates a grid column names specified
#' by `xvars` and `yvars` (see [var_grid()]). After that, it enumerates all
#' conditions created from data in `x` (by calling [dig()]) and for each such
#' condition and for each row of the grid of combinations, a user-defined
#' function `f` is executed on each sub-data created from `x` by selecting all
#' rows of `x` that satisfy the generated condition and by selecting the
#' columns in the grid's row.
#'
#' Function is useful for searching for patterns that are based on the
#' relationships between pairs of columns, such as in [dig_correlations()].
#'
#' @param x a matrix or data frame with data to search in.
#' @param f the callback function to be executed for each generated condition.
#'      The arguments of the callback function differ based on the value of the
#'      `type` argument (see below):
#'      \itemize{
#'      \item If `type = "crisp"` (that is, boolean),
#'      the callback function `f` must accept a single argument `pd` of type
#'      `data.frame` with single (if `yvars == NULL`) or two (if `yvars != NULL`)
#'      columns, accessible as `pd[[1]]` and `pd[[2]]`. Data frame `pd` is
#'      a subset of the original
#'      data frame `x` with all rows that satisfy the generated condition.
#'      Optionally, the callback function may accept an argument `nd` that
#'      is a subset of the original data frame `x` with all rows that do not
#'      satisfy the generated condition.
#'      \item If `type = "fuzzy"`, the callback function `f` must accept an argument
#'      `d` of type `data.frame` with single (if `yvars == NULL`) or two (if
#'      `yvars != NULL`) columns, accessible as `d[[1]]` and `d[[2]]`, and
#'      a numeric argument `weights` with the same length as the number of rows
#'      in `d`. The `weights` argument contains the truth degree
#'      of the generated condition for each row of `d`. The truth degree is
#'      a number in the interval \eqn{[0, 1]} that represents the degree of
#'      satisfaction of the condition in the original data row.
#'      }
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
#' @param yvars `NULL` or a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the second place (yvar)
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NEITHER be
#'      present together in a single condition NOR in a single combination of
#'      `xvars` and `yvars`. If `x` is prepared with
#'      [partition()], using the [var_names()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
#' @param excluded NULL or a list of character vectors, where each character vector
#'      contains the names of columns that must not appear together in a single
#'      condition.
#' @param allow a character string specifying which columns are allowed to be
#'      selected by `xvars` and `yvars` arguments. Possible values are:
#'      \itemize{
#'      \item `"all"` - all columns are allowed to be selected
#'      \item `"numeric"` - only numeric columns are allowed to be selected
#'      }
#' @param na_rm a logical value indicating whether to remove rows with missing
#'      values from sub-data before the callback function `f` is called
#' @param type a character string specifying the type of conditions to be processed.
#'      The `"crisp"` type accepts only logical columns as condition predicates.
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
#' @param max_support the maximum support of a condition to trigger the callback
#'      function for it. See argument `min_support` for details of what is the
#'      support of a condition.
#' @param max_results the maximum number of generated conditions to execute the
#'      callback function on. If the number of found conditions exceeds
#'      `max_results`, the function stops generating new conditions and returns
#'      the results. To avoid long computations during the search, it is recommended
#'      to set `max_results` to a reasonable positive value. Setting `max_results`
#'      to `Inf` will generate all possible conditions.
#' @param verbose a logical scalar indicating whether to print progress messages.
#' @param threads the number of threads to use for parallel computation.
#' @param error_context a list of details to be used in error messages.
#'      This argument is useful when `dig_grid()` is called from another
#'      function to provide error messages, which refer to arguments of the
#'      calling function. The list must contain the following elements:
#'      \itemize{
#'      \item `arg_x` - the name of the argument `x` as a character string
#'      \item `arg_condition` - the name of the argument `condition` as a character
#'         string
#'      \item `arg_xvars` - the name of the argument `xvars` as a character string
#'      \item `arg_yvars` - the name of the argument `yvars` as a character string
#'      \item `call` - an environment in which to evaluate the error messages.
#'      }
#' @return An S3 object, which is an instance of `nugget` class, and which is
#'      a tibble with found patterns. Each row represents a single call of
#'      the callback function `f`.
#' @author Michal Burda
#' @seealso [dig()], [var_grid()]; see also [dig_correlations()] and
#'     [dig_paired_baseline_contrasts()], as they are using this function internally.
#' @examples
#' # *** Example of crisp (boolean) patterns:
#' # dichotomize iris$Species
#' crispIris <- partition(iris, Species)
#'
#' # a simple callback function that computes mean difference of `xvar` and `yvar`
#' f <- function(pd) {
#'     list(m = mean(pd[[1]] - pd[[2]]),
#'          n = nrow(pd))
#'     }
#'
#' # call f() for each condition created from column `Species`
#' dig_grid(crispIris,
#'          f,
#'          condition = starts_with("Species"),
#'          xvars = starts_with("Sepal"),
#'          yvars = starts_with("Petal"),
#'          type = "crisp")
#'
#' # *** Example of fuzzy patterns:
#' # create fuzzy sets from Sepal columns
#' fuzzyIris <- partition(iris,
#'                        starts_with("Sepal"),
#'                        .method = "triangle",
#'                        .breaks = 3)
#'
#' # a simple callback function that computes a weighted mean of a difference of
#' # `xvar` and `yvar`
#' f <- function(d, weights) {
#'     list(m = weighted.mean(d[[1]] - d[[2]], w = weights),
#'          w = sum(weights))
#' }
#'
#' # call f() for each fuzzy condition created from column fuzzy sets whose
#' # names start with "Sepal"
#' dig_grid(fuzzyIris,
#'          f,
#'          condition = starts_with("Sepal"),
#'          xvars = Petal.Length,
#'          yvars = Petal.Width,
#'          type = "fuzzy")
#' @export
dig_grid <- function(x,
                     f,
                     condition = where(is.logical),
                     xvars = where(is.numeric),
                     yvars = where(is.numeric),
                     disjoint = var_names(colnames(x)),
                     excluded = NULL,
                     allow = "all",
                     na_rm = FALSE,
                     type = "crisp",
                     min_length = 0L,
                     max_length = Inf,
                     min_support = 0.0,
                     max_support = 1.0,
                     max_results = Inf,
                     verbose = FALSE,
                     threads = 1L,
                     error_context = list(arg_x = "x",
                                          arg_f = "f",
                                          arg_condition = "condition",
                                          arg_xvars = "xvars",
                                          arg_yvars = "yvars",
                                          arg_disjoint = "disjoint",
                                          arg_excluded = "excluded",
                                          arg_allow = "allow",
                                          arg_na_rm = "na_rm",
                                          arg_type = "type",
                                          arg_min_length = "min_length",
                                          arg_max_length = "max_length",
                                          arg_min_support = "min_support",
                                          arg_max_support = "max_support",
                                          arg_max_results = "max_results",
                                          arg_verbose = "verbose",
                                          arg_threads = "threads",
                                          call = current_env())) {
    .must_be_flag(na_rm,
                  arg = error_context$arg_na_rm,
                  call = error_context$call)
    .must_be_enum(type, c("crisp", "fuzzy"),
                  arg = error_context$arg_type,
                  call = error_context$call)

    if (type == "crisp") {
        .must_be_function(f,
                          required = c("pd"),
                          optional = c("nd"),
                          arg = error_context$arg_f,
                          call = error_context$call)
    } else {
        .must_be_function(f,
                          required = c("d", "weights"),
                          optional = NULL,
                          arg = error_context$arg_f,
                          call = error_context$call)
    }

    condition <- enquo(condition)

    cols <- .convert_data_to_list(x, error_context = error_context)
    .extract_cols(cols,
                  !!condition,
                  allow_numeric = (type == "fuzzy"),
                  allow_empty = TRUE,
                  error_context = list(arg_selection = error_context$arg_condition,
                                       call = error_context$call))

    xvars <- enquo(xvars)
    yvars <- enquo(yvars)
    grid <- var_grid(x,
                     !!xvars,
                     !!yvars,
                     allow = allow,
                     disjoint = disjoint,
                     error_context = error_context)
    gridattr <- attributes(grid)

    processF <- function(condition, support, result) {
        isnull <- sapply(result, is.null)
        result <- lapply(result[!isnull], as_tibble)
        result <- do.call(rbind, result)

        if (!is.null(result)) {
            cond <- format_condition(names(condition))
            gr <- grid[!isnull, ]
            result <- cbind(condition = rep(cond, nrow(gr)),
                            support = support,
                            gr,
                            result,
                            condition_length = rep(length(condition), nrow(gr)))
        }

        result
    }

    if (type == "fuzzy") {
        # fuzzy variant
        tempF1 <- function(condition, support, weights) {
            result <- apply(grid, 1, function(row) {
                dd <- x[, row, drop = FALSE]
                if (na_rm) {
                    dd <- na.omit(dd)
                    weights <- weights[attr(dd, "na.action")]
                }

                f(d = dd, weights = weights)
            })

            processF(condition, support, result)
        }
        callbackF <- tempF1
    } else if ("nd" %in% formalArgs(f)) {
        # crisp variant with nd
        tempF2 <- function(condition, support, indices) {
            pd <- x[indices, , drop = FALSE]
            nd <- x[!indices, , drop = FALSE]

            result <- apply(grid, MARGIN = 1, simplify = FALSE, FUN = function(row) {
                pdd <- pd[, row, drop = FALSE]
                ndd <- nd[, row, drop = FALSE]
                if (na_rm) {
                    pdd <- na.omit(pdd)
                    ndd <- na.omit(ndd)
                }

                f(pd = pdd, nd = ndd)
            })

            processF(condition, support, result)
        }
        callbackF <- tempF2
    } else {
        # crisp variant without nd
        tempF3 <- function(condition, support, indices) {
            pd <- x[indices, , drop = FALSE]

            result <- apply(grid, MARGIN = 1, simplify = FALSE, FUN = function(row) {
                pdd <- pd[, row, drop = FALSE]
                if (na_rm)
                    pdd <- na.omit(pdd)

                f(pd = pdd)
            })

            processF(condition, support, result)
        }
        callbackF <- tempF3
    }

    res <- dig(x = x,
               f = callbackF,
               condition = !!condition,
               disjoint = disjoint,
               excluded = excluded,
               min_length = min_length,
               max_length = max_length,
               min_support = min_support,
               max_support = max_support,
               max_results = max_results,
               verbose = verbose,
               threads = threads,
               error_context = list(arg_x = error_context$arg_x,
                                    arg_condition = error_context$arg_condition,
                                    arg_disjoint = error_context$arg_disjoint,
                                    arg_excluded = error_context$arg_excluded,
                                    arg_min_length = error_context$arg_min_length,
                                    arg_max_length = error_context$arg_max_length,
                                    arg_min_support = error_context$arg_min_support,
                                    arg_max_support = error_context$arg_max_support,
                                    arg_max_results = error_context$arg_max_results,
                                    arg_verbose = error_context$arg_verbose,
                                    arg_threads = error_context$arg_threads,
                                    call = error_context$call))
    digattr <- attributes(res)
    res <- do.call(rbind, res)

    nugget(res,
           flavour = NULL,
           call_function = "dig_grid",
           call_data = list(nrow = nrow(x),
                            ncol = ncol(x),
                            colnames = as.character(colnames(x))),
           call_args = list(x = deparse(substitute(x)),
                            condition = digattr$call_args$condition,
                            xvars = gridattr$xvars,
                            yvars = gridattr$yvars,
                            disjoint = digattr$call_args$disjoint,
                            excluded = digattr$call_args$excluded,
                            allow = allow,
                            na_rm = na_rm,
                            type = type,
                            min_length = digattr$call_args$min_length,
                            max_length = digattr$call_args$max_length,
                            min_support = digattr$call_args$min_support,
                            max_support = digattr$call_args$max_support,
                            max_results = digattr$call_args$max_results,
                            verbose = digattr$call_args$verbose,
                            threads = digattr$call_args$threads))
}


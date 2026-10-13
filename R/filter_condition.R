#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2026 Michal Burda
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


#' @title Filter rows by whether they satisfy a condition
#'
#' @description
#' Select rows from a matrix or data frame according to the truth degree of a
#' condition. A row satisfies the condition when its truth degree is greater
#' than or equal to `threshold`; a row violates it when its truth degree is
#' less than `threshold`.
#'
#' The condition is evaluated as a conjunction of its predicates, using the
#' t-norm selected by `t_norm`. An empty condition (`"{}"`) has truth degree 1
#' for every row.
#'
#' @param x A matrix or data frame containing predicate truth values. If `x` is
#'   a matrix, it must be numeric (double) or logical. If `x` is a data frame,
#'   all columns must be numeric (double) or logical.
#' @param condition A single character string formatted according to
#'   [format_condition()]. Every predicate mentioned in `condition` must be
#'   present as a column in `x`.
#' @param threshold A double scalar in the interval \eqn{[0, 1]}. Rows with a
#'   truth degree greater than or equal to this value satisfy the condition.
#' @param t_norm A string specifying the triangular norm (t-norm) used to
#'   compute conjunctions of predicate values. Must be one of `"goedel"`
#'   (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"` (Łukasiewicz
#'   t-norm).
#'
#' @return `filter_satisfying()` returns the rows of `x` whose truth degree for
#'   `condition` is at least `threshold`. `filter_violating()` returns the
#'   remaining rows. Both functions preserve whether `x` is a matrix or data
#'   frame.
#'
#' @seealso [fire()], [format_condition()], [parse_condition()], [remove_ill_conditions()]
#'
#' @examples
#' d <- data.frame(
#'   a = c(1, 0.8, 0.5, 0.2, 0),
#'   b = c(0.5, 1, 0.5, 0, 1)
#' )
#'
#' filter_satisfying(d, "{a,b}", threshold = 0.5)
#' filter_violating(d, "{a,b}", threshold = 0.5)
#'
#' @export
filter_satisfying <- function(x,
                              condition,
                              threshold = 0.5,
                              t_norm = "goguen") {
    .filter_condition(x, condition, threshold, t_norm, `>=`)
}


#' @rdname filter_satisfying
#' @export
filter_violating <- function(x,
                             condition,
                             threshold = 0.5,
                             t_norm = "goguen") {
    .filter_condition(x, condition, threshold, t_norm, `<`)
}


.filter_condition <- function(x,
                              condition,
                              threshold,
                              t_norm,
                              compare) {
    cols <- .convert_data_to_list(x,
                                  error_context = list(arg_x = "x",
                                                       call = caller_env()))
    .must_be_character_scalar(condition)
    .must_be_double_scalar(threshold)
    .must_be_in_range(threshold, c(0, 1))
    .must_be_enum(t_norm, c("goguen", "goedel", "lukas"))

    condition <- parse_condition(condition)[[1]]
    undefined <- setdiff(condition, colnames(x))
    if (length(undefined) > 0) {
        details <- paste0("Column {.field ", undefined, "} can't be found.")
        cli_abort(c("Can't find some column names in {.arg x} that correspond to all predicates in {.arg condition}.",
                    "i" = "Consider using {.fun remove_ill_conditions} to remove conditions with undefined predicates.",
                    ..error_details(details)),
                  call = caller_env())
    }

    degrees <- if (length(condition) == 0) {
        rep(1, nrow(x))
    } else {
        fns <- list(goguen = .pgoguen_tnorm,
                    goedel = .pgoedel_tnorm,
                    lukas = .plukas_tnorm)
        do.call(fns[[t_norm]], cols[condition])
    }

    x[compare(degrees, threshold), , drop = FALSE]
}

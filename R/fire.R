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


#' @title Obtain truth-degrees of conditions
#'
#' @description
#' Given a data frame or matrix of truth values for predicates, compute the
#' truth values of a set of conditions expressed as elementary conjunctions.
#'
#' Each element of `condition` must be a character string of the format
#' `"{p1,p2,p3}"`, where `"p1"`, `"p2"`, and `"p3"` are predicate names. The
#' data object `x` must contain columns whose names correspond exactly to all
#' predicates referenced in the conditions. Each condition is evaluated for
#' every row of `x` as a conjunction of its predicates, with the conjunction
#' operation determined by the `t_norm` argument. An empty condition (`"{}"`)
#' is always evaluated as 1 (i.e., fully true).
#'
#' @param x A matrix or data frame containing predicate truth values. If `x` is
#'   a matrix, it must be numeric (double) or logical. If `x` is a data frame,
#'   all columns must be numeric (double) or logical.
#' @param condition A character vector of conditions, each formatted according
#'   to [format_condition()]. For example, `"{p1,p2,p3}"` represents a
#'   condition composed of three predicates `"p1"`, `"p2"`, and `"p3"`. Every
#'   predicate mentioned in `condition` must be present as a column in `x`.
#' @param t_norm A string specifying the triangular norm (t-norm) used to
#'   compute conjunctions of predicate values. Must be one of `"goedel"`
#'   (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"` (Łukasiewicz
#'   t-norm).
#'
#' @return A numeric matrix with entries in the interval \eqn{[0, 1]} giving
#'   the truth degrees of the conditions. The matrix has `nrow(x)` rows and
#'   `length(condition)` columns. The element in row *i* and column *j*
#'   corresponds to the truth degree of the *j*-th condition evaluated on the
#'   *i*-th row of `x`.
#'
#' @seealso [format_condition()], [partition()]
#'
#' @author Michal Burda
#'
#' @examples
#' d <- data.frame(
#'   a = c(1, 0.8, 0.5, 0.2, 0),
#'   b = c(0.5, 1, 0.5, 0, 1),
#'   c = c(0.9, 0.9, 0.1, 0.8, 0.7)
#' )
#'
#' # Evaluate conditions with different t-norms
#' fire(d, c("{a,c}", "{}", "{a,b,c}"), t_norm = "goguen")
#' fire(d, c("{a,c}", "{a,b}"), t_norm = "goedel")
#' fire(d, c("{b,c}"), t_norm = "lukas")
#'
#' @export
fire <- function(x,
                 condition,
                 t_norm = "goguen") {

    cols <- .convert_data_to_list(x,
                                  error_context = list(arg_x = "x",
                                                       call = current_env()))

    .must_be_character_vector(condition)
    .must_be_enum(t_norm, c("goguen", "goedel", "lukas"))

    fns <- list(goguen = .pgoguen_tnorm,
                goedel = .pgoedel_tnorm,
                lukas = .plukas_tnorm)
    f <- fns[[t_norm]]

    condition <- parse_condition(condition)
    predicates <- unique(unlist(condition))
    undefined <- setdiff(predicates, colnames(x))
    if (length(undefined) > 0) {
        details <- paste0("Column {.var ", undefined, "} can't be found.")
        cli_abort(c("Can't find some column names in {.arg x} that correspond to all predicates in {.arg condition}.",
                    "i" = "Consider using {.fn remove_ill_conditions()} to remove conditions with undefined predicates.",
                    ..error_details(details)))
    }

    res <- lapply(condition, function(cond) {
        if (length(cond) <= 0) {
            return(rep(1, nrow(x)))
        }

        do.call(f, x[cond])
    })

    res <- do.call(cbind, res)
    if (is.null(res)) {
        res <- matrix(1, ncol = 0, nrow = nrow(x))
    }

    res
}

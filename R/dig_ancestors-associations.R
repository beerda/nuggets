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


#' @title Dig ancestors of an association rule
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Searches for all association rules that are ancestors of the given association
#' rule, i.e. all rules whose antecedent is a subset of the antecedent of the
#' given rule and whose consequent is equal to the consequent of the given rule.
#' The search is performed using the same `disjoint`, `excluded`, and `t_norm`
#' parameters as the original search that produced the given rule.
#'
#' @param x A nugget of flavour `associations` containing a single association rule.
#'      (Typically created with [dig_associations()].)
#' @param data a matrix or data frame with data to search in. The matrix must be
#'      numeric (double) or logical. If `x` is a data frame then each column
#'      must be either numeric (double) or logical.
#' @param ... further arguments (currently not used).
#' @return A nugget of flavour `associations` containing all association rules that are
#'      ancestors of the given rule `x`.
#' @author Michal Burda
#' @seealso [dig_associations()]
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' rules <- dig_associations(d,
#'                           antecedent = !starts_with("mpg"),
#'                           consequent = starts_with("mpg"),
#'                           min_support = 0.3,
#'                           min_confidence = 0.8)
#' r <- rules[1, ]  # get first rule
#' anc <- dig_ancestors(r, d)
#' @rdname dig_ancestors
#' @method dig_ancestors associations
#' @export
dig_ancestors.associations <- function(x,
                                       data,
                                       ...) {
    .must_be_nugget(x, "associations")
    .must_have_n_rows(x, 1)
    .must_have_column(x, "antecedent")
    .must_have_column(x, "consequent")

    ante <- parse_condition(x$antecedent)[[1]]
    cons <- parse_condition(x$consequent)[[1]]
    aa <- attributes(x)

    dig_associations(data,
                     antecedent = all_of(ante),
                     consequent = all_of(cons),
                     disjoint = aa$call_args$disjoint,
                     excluded = aa$call_args$excluded,
                     min_length = 0,
                     max_length = Inf,
                     min_coverage = 0,
                     min_support = 0,
                     min_confidence = 0,
                     t_norm = aa$call_args$t_norm,
                     max_results = Inf,
                     error_context = list(arg_x = "data",
                                          arg_antecedent = "internal `ante`",
                                          arg_consequent = "internal `cons`",
                                          arg_disjoint = "attributes(x)$call_args$disjoint",
                                          arg_excluded = "attributes(x)$call_args$excluded",
                                          arg_t_norm = "attributes(x)$call_args$t_norm",
                                          call = current_env()))
}

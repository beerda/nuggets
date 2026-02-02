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


#' @title Remove invalid conditions from a list
#'
#' @description
#' From a given list of character vectors, remove those elements that are not
#' valid conditions.
#'
#' A valid condition is a character vector of predicates, where each predicate
#' corresponds to a column name in the supplied data frame or matrix. Empty
#' character vectors and `NULL` elements are also considered valid conditions.
#'
#' @details
#' This function acts as a simple filter around [is_condition()]. It checks
#' each element of `x` against the column names of `data` and removes those
#' that contain invalid predicates. The result preserves only valid conditions
#' and discards the invalid ones.
#'
#' @param x A list of character vectors, each representing a condition.
#' @param data A matrix or data frame whose column names define valid
#'   predicates.
#'
#' @return A list containing only those elements of `x` that are valid
#'   conditions.
#'
#' @seealso [is_condition()]
#'
#' @author Michal Burda
#'
#' @examples
#' d <- data.frame(foo = 1:5, bar = 1:5, blah = 1:5)
#'
#' conds <- list(c("foo", "bar"), "blah", "invalid", character(0), NULL)
#' remove_ill_conditions(conds, d)
#' # keeps "foo","bar"; "blah"; empty; NULL
#'
#' @export

remove_ill_conditions <- function(x, data) {
    .must_be_list_of_characters(x, null_elements = TRUE)
    .must_be_matrix_or_data_frame(data)

    x[is_condition(x, data)]
}

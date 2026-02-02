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


#' @title Check whether a list of character vectors contains valid conditions
#'
#' @description
#' A valid condition is a character vector of predicate names, where each
#' predicate corresponds to a column name in a given data frame or matrix.
#' This function verifies that each element of a list `x` contains only valid
#' predicates that match column names of `data`.
#'
#' Special cases:
#' * An empty character vector (`character(0)`) is considered a valid condition
#'   and always passes the check.
#' * A `NULL` element is treated the same as an empty character vector, i.e.,
#'   it is also a valid condition.
#'
#' @param x A list of character vectors, each representing a condition.
#' @param data A matrix or data frame whose column names define valid
#'   predicates.
#'
#' @return A logical vector with one element for each condition in `x`. An
#'   element is `TRUE` if the corresponding condition is valid, i.e. all of its
#'   predicates are column names of `data`. Otherwise, it is `FALSE`.
#'
#' @seealso [remove_ill_conditions()], [format_condition()]
#' @author Michal Burda
#'
#' @examples
#' d <- data.frame(foo = 1:5, bar = 1:5, blah = 1:5)
#'
#' is_condition(list("foo"), d)
#' is_condition(list(c("bar", "blah"), NULL, c("foo", "bzz")), d)
#'
#' @export

is_condition <- function(x, data) {
    .must_be_list_of_characters(x, null_elements = TRUE)
    .must_be_matrix_or_data_frame(data)

    vapply(x,
           function(condition) all(condition %in% colnames(data)),
           logical(1))
}

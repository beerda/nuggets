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


#' Format a vector of predicates into a condition string
#'
#' Convert a character vector of predicate names into a standardized string
#' representation of a condition. Predicates are concatenated with commas and
#' enclosed in curly braces. This formatting ensures consistency when storing
#' or comparing conditions in other functions.
#'
#' @param condition A character vector of predicate names to be formatted. If
#'   `NULL` or of length zero, the result is `"{}"`, representing an empty
#'   condition that is always true.
#'
#' @return A character scalar containing the formatted condition string.
#'
#' @seealso [parse_condition()], [fire()]
#'
#' @author Michal Burda
#'
#' @examples
#' format_condition(NULL)
#' format_condition(character(0))
#' format_condition(c("a", "b", "c"))
#'
#' @export

format_condition <- function(condition) {
    .must_be_character_vector(condition, null = TRUE)

    paste0("{", paste0(sort(condition), collapse = ","), "}")
}

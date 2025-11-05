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


#' Extract variable names from predicate names
#'
#' This function extracts the variable part from a character vector of
#' predicate names. Each element of `x` is expected to follow the pattern
#' `<varname>=<value>`, where `<varname>` is a variable name and `<value>` is
#' the associated value.
#'
#' If an element does not contain an equal sign (`=`), the entire string is
#' returned unchanged.
#'
#' @details
#' This function is the counterpart to [values()], which extracts the value
#' part of predicates. Together, `var_names()` and [values()] provide a
#' convenient way to split predicate strings into their variable and value
#' components.
#'
#' @param x A character vector of predicate names.
#'
#' @return A character vector containing the `<varname>` parts of predicate
#'   names in `x`. If an element does not contain `=`, the entire string is
#'   returned as is. If `x` is `NULL`, the function returns `NULL`. If `x` has
#'   length zero (`character(0)`), the function returns `character(0)`.
#'
#' @seealso [values()]
#'
#' @author Michal Burda
#'
#' @examples
#' var_names(c("a=1", "a=2", "b=x", "b=y"))
#' # returns c("a", "a", "b", "b")
#'
#' var_names(c("a", "b=3"))
#' # returns c("a", "b")
#'
#' var_names(character(0))
#' # returns character(0)
#'
#' var_names(NULL)
#' # returns character(0)
#'
#' @export

var_names <- function(x) {
    .must_be_character_vector(x, null = TRUE)

    if (is.null(x))
        return(NULL)

    sub("=.*", "", x)
}

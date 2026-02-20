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


#' @title Convert condition strings into lists of predicate vectors
#'
#' @description
#' Parse a character vector of conditions into a list of predicate vectors.
#' Each element of the list corresponds to one condition. A condition is a
#' string of predicates separated by commas and enclosed in curly braces, as
#' produced by [format_condition()]. The function splits each string into its
#' component predicates.
#'
#' If multiple vectors of conditions are provided via `...`, they are combined
#' element-wise. The result is a single list where each element is formed by
#' merging the predicates from the corresponding elements of all input
#' vectors. If the input vectors differ in length, shorter ones are recycled.
#'
#' Empty conditions (`"{}"`) are parsed as empty character vectors
#' (`character(0)`).
#'
#' @param ... One or more character vectors of conditions to be parsed.
#' @param .sort Logical flag indicating whether the predicates in each result
#'   should be sorted alphabetically. Defaults to `FALSE`.
#'
#' @return A list of character vectors, where each element corresponds to one
#'   condition and contains the parsed predicates.
#'
#' @seealso [format_condition()], [is_condition()], [fire()]
#'
#' @author Michal Burda
#'
#' @examples
#' parse_condition(c("{a}", "{x=1, z=2, y=3}", "{}"))
#'
#' # Merge conditions from multiple vectors element-wise
#' parse_condition(c("{b}", "{x=1, z=2, y=3}", "{q}", "{}"),
#'                 c("{a}", "{v=10, w=11}",    "{}",  "{r,s,t}"))
#'
#' # Sorting predicates within each condition
#' parse_condition("{z,y,x}", .sort = TRUE)
#'
#' @export
parse_condition <- function(...,
                            .sort = FALSE) {
    .must_be_flag(.sort)

    dots <- list(...)

    if (length(dots) <= 0) {
        return(list())
    }

    test <- sapply(dots, is.character)
    if (!isTRUE(all(test))) {
        types <- sapply(dots, function(i) class(i)[1])
        details <- paste0("Argument {.val ", seq_along(types), "} is a {.cls ", types, "}.")
        details <- details[!test]
        cli_abort(c("Arguments {.arg ...} must be character vectors.",
                    ..error_details(details)),
                  call = current_env())
    }

    if (length(dots) > 1) {
        res <- lapply(dots, .parse_condition)
        res <- do.call(mapply, c(list(c), res, list(SIMPLIFY = FALSE)))
    } else {
        res <- .parse_condition(dots[[1]])
    }

    if (.sort) {
        res <- lapply(res, sort, na.last = TRUE)
    }

    res
}

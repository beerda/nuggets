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


#' @title Shorten predicates within conditions
#'
#' @description
#' This function takes a character vector of conditions and shortens the
#' predicates within each condition according to a specified method.
#'
#' Each element of `x` must be a condition formatted as a string, e.g.
#' `"{a=1,b=100,c=3}"` (see [format_condition()]). The function then
#' shortens the predicates in each condition based on the selected `method`:
#'
#' - `"letters"`: predicates are replaced with single letters from the
#'   English alphabet, starting with `A` for the first distinct predicate;
#' - `"abbrev4"`: predicates are abbreviated to at most 4 characters using
#'   [base::abbreviate()];
#' - `"abbrev8"`: predicates are abbreviated to at most 8 characters using
#'   [base::abbreviate()];
#' - `"none"`: no shortening is applied; predicates remain unchanged.
#'
#' @param x A character vector of conditions, each formatted as a string
#'   (e.g., `"{a=1,b=100,c=3}"`).
#' @param method A character scalar specifying the shortening method. Must be
#'   one of `"letters"`, `"abbrev4"`, `"abbrev8"`, or `"none"`. Defaults to
#'   `"letters"`.
#'
#' @return A character vector of conditions with predicates shortened
#'   according to the specified method.
#'
#' @details
#' Predicate shortening is useful for visualization or reporting, especially
#' when original predicate names are long or complex. Note that shortening is
#' applied consistently across all conditions in `x`.
#'
#' @seealso [format_condition()], [parse_condition()], [is_condition()],
#'   [remove_ill_conditions()], [base::abbreviate()]
#'
#' @author Michal Burda
#'
#' @examples
#' shorten_condition(c("{a=1,b=100,c=3}", "{a=2}", "{b=100,c=3}"),
#'                   method = "letters")
#'
#' shorten_condition(c("{helloWorld=1}", "{helloWorld=2}", "{c=3,helloWorld=1}"),
#'                   method = "abbrev4")
#'
#' shorten_condition(c("{helloWorld=1}", "{helloWorld=2}", "{c=3,helloWorld=1}"),
#'                   method = "abbrev8")
#'
#' shorten_condition(c("{helloWorld=1}", "{helloWorld=2}"),
#'                   method = "none")
#'
#' @export

shorten_condition <- function(x,
                              method = "letters") {
    .must_be_character_vector(x, null = TRUE)
    .must_be_enum(method, c("letters", "abbrev4", "abbrev8", "none"))

    if (is.null(x)) {
        return(NULL)
    }
    if (length(x) == 0) {
        return(character(0))
    }
    if (method == "none") {
        return(x)
    }

    parsed <- parse_condition(x)
    predicates <- unique(unlist(parsed))

    if (method == "letters") {
        if (length(predicates) > length(LETTERS)) {
            cli_abort(c("The number of unique values in {.arg x} is greater than {length(LETTERS)}.",
                        "x" = "You can use {.fn shorten_condition} with {.val method = 'abbrev4'} or {.val method = 'abbrev8'} to shorten the condition."))
        }
        dict <- setNames(LETTERS[seq_along(predicates)], predicates)

    } else {
        minlen <- ifelse(method == "abbrev4", 4, 8)
        n <- var_names(predicates)
        n <- abbreviate(n, minlength = minlen)
        v <- values(predicates)
        v <- gsub(" ", "", v, fixed = TRUE)
        nx <- paste0(n, "=", v)
        dict <- setNames(nx, predicates)
    }

    res <- lapply(parsed, function(cond) { format_condition(dict[cond]) })

    unlist(res, use.names = FALSE)
}

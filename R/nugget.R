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


#' Create a nugget object of a given flavour
#'
#' Construct a nugget object, which is an S3 object used to store and
#' represent results (e.g., rules or patterns) in the `nuggets` framework.
#'
#' A nugget is technically a tibble (or data frame) that inherits from both
#' the `"nugget"` class and, optionally, a flavour-specific S3 class. This
#' allows distinguishing different types of nuggets (flavours) while still
#' supporting generic methods for all nuggets.
#'
#' @details
#' Each nugget stores additional provenance information in attributes:
#' * `"call_function"` — the name of the function that created the nugget.
#' * `"call_args"` — the list of arguments passed to that function.
#'
#' These attributes make it possible to reconstruct or track how the nugget
#' was created, which supports reproducibility, transparency, and debugging.
#' For example, one can inspect `attr(n, "call_args")` to recover the original
#' parameters used to mine the patterns.
#'
#' @param x An object with rules or patterns, typically a tibble or data frame.
#'   If `NULL`, it will be converted to an empty tibble.
#' @param flavour A character string specifying the flavour of the nugget, or
#'   `NULL` if no flavour should be assigned. If given, the returned object
#'   will inherit from both `"nugget"` and the specified flavour class.
#' @param call_function A character scalar giving the name of the function that
#'   created the nugget. Stored as an attribute for provenance.
#' @param call_data A list containing information about the data that was
#'   passed to the function which created the nugget. Stored as an attribute
#'   for reproducibility.
#' @param call_args A list of arguments that were passed to the function which
#'   created the nugget. Stored as an attribute for reproducibility.
#'
#' @return A tibble object that is an S3 subclass of `"nugget"` and, if
#'   specified, the given `flavour` class. The object also contains attributes
#'   `"call_function"` and `"call_args"` describing its provenance.
#'
#' @seealso [is_nugget()]
#'
#' @author Michal Burda
#'
#' @examples
#' df <- data.frame(lhs = c("a", "b"), rhs = c("c", "d"))
#' n <- nugget(df,
#'             flavour = "rules",
#'             call_function = "example_function",
#'             call_data = list(ncol = 2,
#'                              nrow = 2,
#'                              colnames = c("lhs", "rhs")),
#'             call_args = list(data = "mydata"))
#'
#' inherits(n, "nugget")      # TRUE
#' inherits(n, "rules")       # TRUE
#' attr(n, "call_function")   # "dig_example_function"
#' attr(n, "call_args")       # list(data = "mydata")
#'
#' @export
nugget <- function(x,
                   flavour,
                   call_function,
                   call_data,
                   call_args) {
    .must_be_character_scalar(flavour, null = TRUE)
    .must_be_character_scalar(call_function)
    .must_be_list(call_data)
    .must_be_list(call_args)

    if (is.null(x) || is.data.frame(x)) {
        x <- as_tibble(x)
    }

    if (!inherits(x, "nugget")) {
        class(x) <- c("nugget", class(x))
    }
    if (!is.null(flavour) && !inherits(x, flavour)) {
        class(x) <- c(flavour, class(x))
    }

    attr(x, "call_function") <- call_function
    attr(x, "call_data") <- call_data
    attr(x, "call_args") <- call_args

    x
}

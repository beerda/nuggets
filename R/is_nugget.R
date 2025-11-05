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


#' Test whether an object is a nugget
#'
#' Check if the given object is a nugget, i.e. an object created by
#' [nugget()]. If a `flavour` is specified, the function returns `TRUE` only
#' if the object is a nugget of the given flavour.
#'
#' Technically, nuggets are implemented as S3 objects. An object is considered
#' a nugget if it inherits from the S3 class `"nugget"`. It is a nugget of a
#' given flavour if it inherits from both the specified `flavour` class and
#' the `"nugget"` class.
#'
#' @param x An object to be tested.
#' @param flavour Optional character string specifying the required flavour of
#'   the nugget. If `NULL` (default), the function checks only whether `x` is
#'   a nugget of any flavour.
#'
#' @return A logical scalar: `TRUE` if `x` is a nugget (and of the specified
#'   flavour, if given), otherwise `FALSE`.
#'
#' @seealso [nugget()]
#' @author Michal Burda
#' @export
is_nugget <- function(x, flavour = NULL) {
    .must_be_character_scalar(flavour, null = TRUE)

    inherits(x, "nugget") &&
        (is.null(flavour) || inherits(x, flavour))
}

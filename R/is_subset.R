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


#' Determine whether one vector is a subset of another
#'
#' Check if all elements of `x` are also contained in `y`. This is equivalent
#' to testing whether `setdiff(x, y)` is empty.
#'
#' @param x The first vector.
#' @param y The second vector.
#'
#' @return A logical scalar. Returns `TRUE` if `x` is a subset of `y`, i.e. all
#'   elements of `x` are also elements of `y`. Returns `FALSE` otherwise.
#'
#' @details
#' * If `x` is empty, the result is always `TRUE` (the empty set is a subset of
#'   any set).
#' * If `y` is empty and `x` is not, the result is `FALSE`.
#' * Duplicates in `x` are ignored; only set membership is tested.
#' * `NA` values are treated as ordinary elements. In particular, `NA` in `x`
#'   is considered a subset element only if `NA` is also present in `y`.
#'
#' @seealso [setdiff()], [intersect()], [union()]
#'
#' @author Michal Burda
#'
#' @examples
#' is_subset(1:3, 1:5)               # TRUE
#' is_subset(c(2, 5), 1:4)           # FALSE
#' is_subset(numeric(0), 1:5)        # TRUE
#' is_subset(1:3, numeric(0))        # FALSE
#' is_subset(c(1, NA), c(1, 2, NA))  # TRUE
#' is_subset(c(NA), 1:5)             # FALSE
#'
#' @export
is_subset <- function(x, y) {
    .must_be_vector(x, null = TRUE)
    .must_be_vector(y, null = TRUE)

    length(setdiff(x, y)) == 0L
}

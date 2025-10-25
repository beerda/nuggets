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


#' Test whether a vector is almost constant
#'
#' Check if a vector contains (almost) the same value in the majority of its
#' elements. The function returns `TRUE` if the proportion of the most frequent
#' value in `x` is greater than or equal to the specified `threshold`.
#'
#' This is useful for detecting low-variability or degenerate variables, which
#' may be uninformative in modeling or analysis.
#'
#' @param x A vector to be tested.
#' @param threshold A numeric scalar in the interval \eqn{[0,1]} specifying the
#'   minimum required proportion of the most frequent value. Defaults to 1.
#' @param na_rm Logical; if `TRUE`, `NA` values are removed before computing
#'   proportions. If `FALSE`, `NA` is treated as an ordinary value, so a large
#'   number of `NA`s can cause the function to return `TRUE`.
#'
#' @return A logical scalar. Returns `TRUE` in the following cases:
#'   * `x` is empty or has length one.
#'   * `x` contains only `NA` values.
#'   * The proportion of the most frequent value in `x` is greater than or
#'     equal to `threshold`.
#'   Otherwise, returns `FALSE`.
#'
#' @seealso [remove_almost_constant()], [unique()], [table()]
#'
#' @author Michal Burda
#'
#' @examples
#' is_almost_constant(1)
#' is_almost_constant(1:10)
#' is_almost_constant(c(NA, NA, NA), na_rm = TRUE)
#' is_almost_constant(c(NA, NA, NA), na_rm = FALSE)
#' is_almost_constant(c(NA, NA, NA, 1, 2), threshold = 0.5, na_rm = FALSE)
#' is_almost_constant(c(NA, NA, NA, 1, 2), threshold = 0.5, na_rm = TRUE)
#'
#' @export
is_almost_constant <- function(x,
                               threshold = 1.0,
                               na_rm = FALSE) {
    .must_be_vector_or_factor(x, null = TRUE)
    .must_be_flag(na_rm)
    .must_be_double_scalar(threshold)
    .must_be_in_range(threshold, c(0, 1))

    if (length(x) <= 1) {
        return(TRUE)
    }

    tab <- table(x, useNA = "no")
    if (length(tab) <= 0) {
        return(TRUE)
    }

    max_count <- max(tab)

    if (na_rm) {
        maxrel_count <- max_count / sum(tab)

    } else {
        na_count <- sum(is.na(x))
        max_count <- max(max_count, na_count)
        maxrel_count <- max_count / length(x)
    }

    maxrel_count >= threshold
}
